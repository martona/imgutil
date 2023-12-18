#include "i_imgutil.h"

// basic version without instruction set requirements
static inline u32 i_imgutil_pixelmatchcount_v1
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
        u8 r =   ((u8*)*haystack)[2];
        u8 g =   ((u8*)*haystack)[1];
        u8 b =   ((u8*)*haystack)[0];
        (*haystack)++;
        u8 rl =  ((u8*)*needle_lo)[2];
        u8 gl =  ((u8*)*needle_lo)[1];
        u8 bl =  ((u8*)*needle_lo)[0];
        (*needle_lo)++;
        u8 rh =  ((u8*)*needle_hi)[2];
        u8 gh =  ((u8*)*needle_hi)[1];
        u8 bh =  ((u8*)*needle_hi)[0];
        (*needle_hi)++;
        if ((r <= rh) && (r >= rl) && 
            (g <= gh) && (g >= gl) && 
            (b <= bh) && (b >= bl))
            ret++;
        w--;
    }
    return ret;
}

#if defined(MARCH_x86_64_v4) || defined(MARCH_x86_64_v3) || defined(MARCH_x86_64_v2)
static inline u32 i_imgutil_pixelmatchcount_v2
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
    while (w > (vecsize - 1)) {
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
    ret += i_imgutil_pixelmatchcount_v1(haystack, w, needle_lo, needle_hi);
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
    while (w > (vecsize - 1)) {
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
    ret += i_imgutil_pixelmatchcount_v2(haystack, w, needle_lo, needle_hi);
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
    while (w > (vecsize - 1)) {
        // get precomputed low values
        __m512i nl = _mm512_loadu_si512((__m512i*)*needle_lo);
        // get precomputed high values
        __m512i nh = _mm512_loadu_si512((__m512*)*needle_hi);
        // load a vector's worth of haystack
        __m512i h512 = _mm512_loadu_si512((__m512i*)*haystack);
        // compare haystack to needle low (this gives us 4 bits per pixel in the mask; one for each channel)
        __mmask64 lres = _mm512_cmpge_epu8_mask(h512, nl);
        // compare haystack to needle high
        __mmask64 mboth = _mm512_mask_cmp_epu8_mask(lres, h512, nh, _MM_CMPINT_LE);
        //expand every bit of the mask into 8 so we get a __m512i 
        __m512i vboth = _mm512_movm_epi8(mboth);
        // compare this with the all-1 mask on a 32-bit basis
        __mmask16 bits = _mm512_cmpeq_epi32_mask(vboth, _mm512_set1_epi32(-1));
        // count the number of 1-bits in the result
        ret += imgutil_popcount((u32)bits);
        *needle_lo += vecsize;
        *needle_hi += vecsize;
        *haystack  += vecsize;
        w -= vecsize;
    }
    ret += i_imgutil_pixelmatchcount_v3(haystack, w, needle_lo, needle_hi);
    return ret;
}
#endif