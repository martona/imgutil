#include "i_imgutil.h"

// the scalar version should never be used other than for falling through
static inline u32 i_imgutil_pixelmatchcount_v0
(
    argb** __restrict  haystack,    //pointer to haystack array
    i32 w,                          //width of the array in 32-bit pixels
    argb** __restrict  needle_lo,   //precomputed low values for the entire needle array
    argb** __restrict  needle_hi    //precomputed high values for the entire needle array
)
{
    // pixel match count to be returned
    u32 ret = 0;
    while (w > 0) {
        argb s = **haystack;
        argb l = **needle_lo;
        argb h = **needle_hi;
        (*haystack)++;
        (*needle_lo)++;
        (*needle_hi)++;
        // GCC and clang produce code for this with 5 branches:
        // if ((s.r <= h.r) && (s.r >= l.r) && 
        //     (s.g <= h.g) && (s.g >= l.g) && 
        //     (s.b <= h.b) && (s.b >= l.b))
        //     ret++;

        // this is branchless and runs in 70% of the time:        
        i32 cond_r = ((i32)s.r - (i32)l.r) <= ((i32)h.r - (i32)l.r);
        i32 cond_g = ((i32)s.g - (i32)l.g) <= ((i32)h.g - (i32)l.g);
        i32 cond_b = ((i32)s.b - (i32)l.b) <= ((i32)h.b - (i32)l.b);
        ret += (cond_r & cond_g & cond_b);

        w--;
    }
    return ret;
}

#if defined(MARCH_x86_64_v4) || defined(MARCH_x86_64_v3) || defined(MARCH_x86_64_v2) || defined(MARCH_x86_64_v1)
// this is the same for v1 and v2, with the only difference being the unavailability of
// popcnt in v1, so we have a software implementation through the macro. it is, however,
// a massive speed penalty.
static inline u32 i_imgutil_pixelmatchcount_v12
(
    argb** __restrict  haystack,    //pointer to haystack array
    i32 w,                          //width of the array in 32-bit pixels
    argb** __restrict  needle_lo,   //precomputed low values for the entire needle array
    argb** __restrict  needle_hi    //precomputed high values for the entire needle array
)
{
    // pixel match count to be returned
    u32 ret = 0;
    // number of 32-bit pixels in a vector
    i32 vecsize = (sizeof(__m128i) / sizeof(i32));
    // don't scan pixels we can't swallow into a vector
    while (w >= vecsize) {
        // get precomputed low values
        __m128i nl = _mm_loadu_si128((__m128i*) * needle_lo);
        *needle_lo += vecsize;
        // get precomputed hight values
        __m128i nh = _mm_loadu_si128((__m128i*) * needle_hi);
        *needle_hi += vecsize;

        // load a vector's worth of haystack
        __m128i h128 = _mm_loadu_si128((__m128i*) * haystack);
        *haystack += vecsize;

        // compare haystack to needle low
        __m128i lres = _mm_cmpge_epu8(h128, nl);
        // compare haystack to needle high
        __m128i hres = _mm_cmple_epu8(h128, nh);
        // see where both operations were true
        __m128i both = _mm_and_si128(lres, hres);
        // compare this with the all-1 mask on a 32-bit basis
        __m128i vres = _mm_cmpeq_epi32(both, _mm_set1_epi32(-1));

        // condense the result into one bit per byte comparison
        u32 mres = _mm_movemask_epi8(vres);
        // count the number of bits from this mask and divide by 4 to get matching pixel count
        // (we get 1 bit for every byte from movemask_epi8)
        ret += imgutil_popcount(mres) / 4;
        w -= vecsize;
    }
    while (w) {
        __m128i nl   = _mm_loadu_si32(*needle_lo);
        __m128i nh   = _mm_loadu_si32(*needle_hi);
        __m128i h128 = _mm_loadu_si32(*haystack);
        __m128i lres = _mm_cmpge_epu8(h128, nl);
        __m128i hres = _mm_cmple_epu8(h128, nh);
        __m128i both = _mm_and_si128(lres, hres);
        __m128i vres = _mm_cmpeq_epi32(both, _mm_set1_epi32(-1));
        u32 mres = _mm_movemask_epi8(vres);
        ret += (mres & 1);
        (*needle_lo)++;
        (*needle_hi)++;
        (*haystack)++;
        w--;
    }
    return ret;
}
#endif

#if defined(MARCH_x86_64_v4) || defined(MARCH_x86_64_v3)
// https://stackoverflow.com/questions/77620019/
// the avx check for the final value seems better than the 
// (admittedly more "elegant") bit twiddling solutions
static inline u32 i_imgutil_pixelmatchcount_v3
(
    argb** __restrict  haystack,    //pointer to haystack array
    i32 w,                          //width of the array in 32-bit pixels
    argb** __restrict  needle_lo,   //precomputed low values for the entire needle array
    argb** __restrict  needle_hi    //precomputed high values for the entire needle array
)
{
    // pixel match count to be returned
    u32 ret = 0;
    i32 vecsize = (sizeof(__m256i) / sizeof(i32));
    // don't scan pixels we can't swallow into a vector
    while (w >= vecsize) {
        // get precomputed low values
        __m256i nl = _mm256_loadu_si256((__m256i*)*needle_lo);
        *needle_lo += vecsize;
        // get precomputed hight values
        __m256i nh = _mm256_loadu_si256((__m256i*)*needle_hi);
        *needle_hi += vecsize;

        // load a vector's worth of haystack
        __m256i h256 = _mm256_loadu_si256((__m256i*)*haystack);
        *haystack += vecsize;

        // compare haystack to needle low
        __m256i lres = _mm256_cmpge_epu8(h256, nl);
        // compare haystack to needle high
        __m256i hres = _mm256_cmple_epu8(h256, nh);
        // see where both operations were true
        __m256i both = _mm256_and_si256(lres, hres);
        // compare this with the all-1 mask on a 32-bit basis
        __m256i vres = _mm256_cmpeq_epi32(both, _mm256_set1_epi32(-1));

        // condense the result into one bit per byte comparison
        u32 mres = _mm256_movemask_epi8(vres);
        // count the number of bits from this mask and divide by 4 to get matching pixel count
        // (we get 1 bit for every byte from movemask_epi8)
        ret += imgutil_popcount(mres) / 4;
        w -= vecsize;
    }
    ret += i_imgutil_pixelmatchcount_v12(haystack, w, needle_lo, needle_hi);
    return ret;
}
#endif

#if defined(MARCH_x86_64_v4)
// https://stackoverflow.com/questions/77620019/
// the avx check for the final value seems better than the 
// (admittedly more "elegant") bit twiddling solutions
static inline u32 i_imgutil_pixelmatchcount_v4
(
    argb** __restrict  haystack,    //pointer to haystack array
    i32 w,                          //width of the array in 32-bit pixels
    argb** __restrict  needle_lo,   //precomputed low values for the entire needle array
    argb** __restrict  needle_hi    //precomputed high values for the entire needle array
)
{
    // pixel match count to be returned
    u32 ret = 0;
    i32 vecsize = (sizeof(__m512i) / sizeof(i32));
    // don't scan pixels we can't swallow into a vector
    while (w >= vecsize ) {
        // get precomputed low values
        __m512i nl = _mm512_loadu_si512((__m512i*)*needle_lo);
        // get precomputed high values
        __m512i nh = _mm512_loadu_si512((__m512*)*needle_hi);
        // load a vector's worth of haystack
        __m512i h512 = _mm512_loadu_si512((__m512i*)*haystack);
        // compare haystack to needle low (this gives us 4 bits per pixel in the mask; one for each channel)
        __mmask64 lres = _mm512_cmpge_epu8_mask(h512, nl);
        // compare haystack to needle high where the low comparison was true
        __mmask64 mboth = _mm512_mask_cmp_epu8_mask(lres, h512, nh, _MM_CMPINT_LE);
        //expand every bit of the mask into 8 so the 4-bit-per-pixel results blow up to 32bpp
        __m512i vboth = _mm512_movm_epi8(mboth);
        // compare this with the all-1 mask on a 32-bit basis to get 1 bit per pixel match
        __mmask16 bits = _mm512_cmpeq_epi32_mask(vboth, _mm512_set1_epi32(-1));
        // count the number of 1-bits in the result
        ret += imgutil_popcount((u32)bits);
        *needle_lo += vecsize;
        *needle_hi += vecsize;
        *haystack  += vecsize;
        w -= vecsize;
    }
    // cleanup any remaining pixels
    if (w) {
        //16-bit mask for loading the last w pixels;
        u32 mask = (1 << w) - 1;
        //perform the load; this looks like it might reach beyond
        //the bounds of memory this code is allowed to access, but 
        //masked-off areas do not generate faults
        __m512i h512 = _mm512_maskz_loadu_epi32(_cvtu32_mask16(mask), *haystack);
        // get precomputed low values
        __m512i nl = _mm512_maskz_loadu_epi32(mask, *needle_lo);
        // get precomputed high values
        __m512i nh = _mm512_maskz_loadu_epi32(mask, *needle_hi);
        // compare haystack to needle low (this gives us 4 bits per pixel in the mask; one for each channel)
        __mmask64 lres = _mm512_cmpge_epu8_mask(h512, nl);
        // compare haystack to needle high where the low comparison was true
        __mmask64 mboth = _mm512_mask_cmp_epu8_mask(lres, h512, nh, _MM_CMPINT_LE);
        //expand every bit of the mask into 8 so the 4-bit-per-pixel results blow up to 32bpp
        __m512i vboth = _mm512_movm_epi8(mboth);
        // compare this with the all-1 mask on a 32-bit basis to get 1 bit per pixel match
        __mmask16 bits = _mm512_cmpeq_epi32_mask(vboth, _mm512_set1_epi32(-1));
        // don't let the zero loads affect the result, those are guaranteed to be matches
        bits &= mask;
        // count the number of 1-bits in the result
        ret += imgutil_popcount((u32)bits);
        *needle_lo += w;
        *needle_hi += w;
        *haystack  += w;
    }
    return ret;
}
#endif