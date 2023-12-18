#include "i_imgutil.h"

// the basic version that doesn't require a special CPU
// instruction set. returns a pointer to the first
// occurrence of a pixel within the given values,
// or zero if none found.

static inline argb* i_imgutil_pixel_scan_v1
(   
    argb* __restrict p,
    vec nl, vec nh,
    i32 w
)
{
    u8 rl = nl.margb.r, rh = nh.margb.r;
    u8 gl = nl.margb.g, gh = nh.margb.g;
    u8 bl = nl.margb.b, bh = nh.margb.b;

    while (w >= 0) {
        u8 r = ((u8*)p)[2];
        u8 g = ((u8*)p)[1];
        u8 b = ((u8*)p)[0];
        if ((r <= rh) && (r >= rl) && 
            (g <= gh) && (g >= gl) && 
            (b <= bh) && (b >= bl))
            return p;
        p++;
        w--;
    }
    return 0;
}

#if defined(MARCH_x86_64_v4) || defined(MARCH_x86_64_v3) || defined(MARCH_x86_64_v2)
static inline argb* i_imgutil_pixel_scan_v2
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
            // count leading zeroes in mask (as a 16-bit value)
            // and divide by 4 to get the index of the pixel that matched
            return p + imgutil_clz16(bits) / 4;
        p += vecsize;
        w -= vecsize;
    }
    return i_imgutil_pixel_scan_v1(p, nl, nh, w);
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
            // count leading zeroes in mask (as a 16-bit value)
            // we get 1 bit for each color channel, and we want
            // pixels, so divide by 4
            return p + imgutil_clz32(bits) / 4;
        p += vecsize;
        w -= vecsize;
    }
    return i_imgutil_pixel_scan_v2(p, nl, nh, w);
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
            // count leading zeroes in mask (as a 16-bit value)
            // to get the index of the pixel that matched
            return p + imgutil_clz16(bits);
        p += vecsize;
        w -= vecsize;
    }
    return i_imgutil_pixel_scan_v3(p, nl, nh, w);
}
#endif
