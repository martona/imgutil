#include "i_imgutil.h"

// the basic version that doesn't require a special CPU
// instruction set.
// returns a pointer to the first occurrence of a pixel 
// on the given scanline, or zero if none found.

__attribute__((optimize("no-tree-vectorize")))
static inline argb* i_imgutil_pixel_scan_v0
(   
    argb* __restrict p,
    vec nl, vec nh,
    i32 w
)
{
    argb l = nl.margb, h = nh.margb;
    while (w >= 1) {
        argb s = *p;
        if ((s.r <= h.r) && (s.r >= l.r) && 
            (s.g <= h.g) && (s.g >= l.g) && 
            (s.b <= h.b) && (s.b >= l.b))
            return p;
        // i32 cond_r = ((u32)s.r - (u32)l.r) <= ((u32)h.r - (u32)l.r);
        // i32 cond_g = ((u32)s.g - (u32)l.g) <= ((u32)h.g - (u32)l.g);
        // i32 cond_b = ((u32)s.b - (u32)l.b) <= ((u32)h.b - (u32)l.b);
        // if (cond_r & cond_g & cond_b)
        //     return p;
        p++;
        w--;
    }
    return 0;
}

#if defined(MARCH_x86_64_v4) || defined(MARCH_x86_64_v3) || defined(MARCH_x86_64_v2) || defined(MARCH_x86_64_v1)
// SSE implementation, psabi level 1 and 2 are essentially the same.
static inline argb* i_imgutil_pixel_scan_v12
(   
    argb*  __restrict p,
    vec nl, vec nh,
    i32 w
)
{
    // number of 32-bit pixels in a vector
    i32 vecsize = (sizeof(__m128i) / sizeof(i32));

    // don't scan pixels we can't swallow into a vector
    while (w >= vecsize) {
        // load a vector's worth of haystack
        __m128i h128 = _mm_loadu_si128((__m128i*)p);
        // compare haystack to needle low
        __m128i lres = _mm_cmpge_epu8(h128, nl.m128i);
        // compare haystack to needle high
        __m128i hres = _mm_cmple_epu8(h128, nh.m128i);
        // see where both operations were true
        __m128i both = _mm_and_si128(lres, hres);
        // compare this with the all-1 mask on a 32-bit basis
        __m128i vres = _mm_cmpeq_epi32(both, _mm_set1_epi32(-1));
        // condense the result into one bit per byte comparison
        u32 bits = _mm_movemask_epi8(vres);
        // if we have a hit...
        if (bits) 
            // count trailing zeroes in mask (as a 16-bit value)
            // and divide by 4 to get the index of the pixel that matched
            return p + imgutil_ctz16(bits) / 4;
        p += vecsize;
        w -= vecsize;
    }
    // handle the remaining pixels, we only have 3 or fewer, so we can
    // just do them one by one
    while (w) {
        // load a vector's worth of haystack
        __m128i h128 = _mm_loadu_si32(p);
        // compare haystack to needle low
        __m128i lres = _mm_cmpge_epu8(h128, nl.m128i);
        // compare haystack to needle high
        __m128i hres = _mm_cmple_epu8(h128, nh.m128i);
        // see where both operations were true
        __m128i both = _mm_and_si128(lres, hres);
        // compare this with the all-1 mask on a 32-bit basis
        __m128i vres = _mm_cmpeq_epi32(both, _mm_set1_epi32(-1));
        // condense the result into one bit per byte comparison
        u32 bits = _mm_movemask_epi8(vres);
        // only need to test one bit
        if (bits & 1) 
            return p;
        p++;
        w--;
    }
    // nothing found
    return 0;
}
#endif

#if defined(MARCH_x86_64_v4) || defined(MARCH_x86_64_v3)
static inline argb* i_imgutil_pixel_scan_v3
(   
    argb*  __restrict p,
    vec nl, vec nh,
    i32 w
)
{
    // number of 32-bit pixels in a vector
    i32 vecsize = (sizeof(__m256i) / sizeof(i32));
    // don't scan pixels we can't swallow into a vector
    while (w >= vecsize) {
        // load a vector's worth of haystack
        __m256i h256 = _mm256_loadu_si256((__m256i*)p);
        // compare haystack to needle low
        __m256i lres = _mm256_cmpge_epu8(h256, nl.m256i);
        // compare haystack to needle high
        __m256i hres = _mm256_cmple_epu8(h256, nh.m256i);
        // see where both operations were true
        __m256i both = _mm256_and_si256(lres, hres);
        // compare this with the all-1 mask on a 32-bit basis
        __m256i vres = _mm256_cmpeq_epi32(both, _mm256_set1_epi32(-1));
        // condense the result into one bit per byte comparison
        u32 bits = _mm256_movemask_epi8(vres);
        // if we have a hit...
        if (bits) 
            // count trailing zeroes in mask (as a 32-bit value)
            // we get 1 bit for each color channel, and we want
            // pixels, so divide by 4
            return p + imgutil_ctz32(bits) / 4;
        p += vecsize;
        w -= vecsize;
    }
    return i_imgutil_pixel_scan_v12(p, nl, nh, w);
}
#endif


#if defined(MARCH_x86_64_v4)
static inline argb* i_imgutil_pixel_scan_v4
(   
    argb*  __restrict p,
    vec nl, vec nh,
    i32 w
)
{
    // number of 32-bit pixels in a vector
    i32 vecsize = (sizeof(__m512i) / sizeof(i32));
    // don't scan pixels we can't swallow into a vector
    while (w >= vecsize) {
        // load a vector's worth of haystack
        __m512i h512 = _mm512_loadu_si512((__m512i*)p);
        // compare haystack to needle low
        __mmask64 lres = _mm512_cmpge_epu8_mask(h512, nl.m512i);
        // compare haystack to needle high
        __mmask64 mboth = _mm512_mask_cmp_epu8_mask(lres, h512, nh.m512i, _MM_CMPINT_LE);
        //expand every bit of the mask into 8 so we get a __m512i 
        __m512i vboth = _mm512_movm_epi8(mboth);
        // compare this with the all-1 mask on a 32-bit basis.
        // (the initialization of the -1 mask is both very quick and optimized
        // to the outside of the loop))
        __mmask16 bits = _mm512_cmpeq_epi32_mask(vboth, _mm512_set1_epi32(-1));
        // if we have a hit...
        if (bits)
            // count trailing zeroes in mask (as a 16-bit value)
            // to get the index of the pixel that matched
            return p + imgutil_ctz16(bits);
        p += vecsize;
        w -= vecsize;
    }
    // cleanup any remaining pixels
    if (w) {
        //16-bit mask for loading the last w pixels;
        i16 mask = (1 << w) - 1;
        //perform the load; this looks like it might reach beyond
        //the bounds of memory this code is allowed to access, but 
        //masked-off areas do not generate faults
        __m512i h512 = _mm512_maskz_loadu_epi32(_cvtu32_mask16((u32)mask), p);
        // compare haystack to needle low
        __mmask64 lres = _mm512_cmpge_epu8_mask(h512, nl.m512i);
        // compare haystack to needle high
        __mmask64 mboth = _mm512_mask_cmp_epu8_mask(lres, h512, nh.m512i, _MM_CMPINT_LE);
        //expand every bit of the mask into 8 so we get a __m512i
        __m512i vboth = _mm512_movm_epi8(mboth);
        // compare this with the all-1 mask on a 32-bit basis.
        __mmask16 bits = _mm512_cmpeq_epi32_mask(vboth, _mm512_set1_epi32(-1));
        // mask off anything that was beyond our reach due to the mask used
        bits &= mask;
        // if we have a hit...
        if (bits)
            // count trailing zeroes in mask (as a 16-bit value)
            // to get the index of the pixel that matched
            return p + imgutil_ctz16(bits);
    }
    return 0;
}
#endif
