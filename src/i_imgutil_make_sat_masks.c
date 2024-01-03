#include "i_imgutil.h"

static inline u32 i_imgutil_make_sat_masks_v0
            (
                u32* __restrict needle, 
                         i32  pixelcount,
                u32* __restrict needle_lo,
                u32* __restrict needle_hi,
                vec     tv
            )
{
    argb t = tv.margb;

    while (pixelcount > 0) {
        argb n  = *(argb*)needle;
        argb lo = {a: 0x00, r: subu8(n.r, t.r), g: subu8(n.g, t.g), b: subu8(n.b, t.b)};
        argb hi = {a: 0xff, r: addu8(n.r, t.r), g: addu8(n.g, t.g), b: addu8(n.b, t.b)};
        *(argb*)needle_lo = lo;
        *(argb*)needle_hi = hi;
        needle++;
        needle_hi++;
        needle_lo++;
        pixelcount--;
    }
    return 0;
}

#if defined(MARCH_x86_64_v4) || defined(MARCH_x86_64_v3) || defined(MARCH_x86_64_v2) || defined(MARCH_x86_64_v1)
static inline u32 i_imgutil_make_sat_masks_v12
            (
                u32* __restrict needle, 
                         i32  pixelcount,
                u32* __restrict needle_lo,
                u32* __restrict needle_hi,
                vec     tv 
            )
{
    i32 vecsize      = (sizeof(__m128i)/sizeof(i32));
    // the vector we're adding and subtracting from needle's values
    while (pixelcount >= vecsize) {
        // load a vector's worth of needle
        __m128i n128 = _mm_loadu_si128((__m128i*)needle);
        // subtract t values from needle values using saturation
        __m128i nl   = _mm_subs_epu8(n128, tv.m128i);
        // store the low mask
        _mm_storeu_si128((__m128i*)needle_lo, nl);
        // add t values to needle using saturation
        __m128i nh   = _mm_adds_epu8(n128, tv.m128i);
        // store the hi mask
        _mm_storeu_si128((__m128i*)needle_hi, nh);

        needle     += vecsize;
        needle_hi  += vecsize;
        needle_lo  += vecsize;
        pixelcount -= vecsize;
    }
    // cleanup stuff that won't fit in to the vector (4>pixels)
    while (pixelcount) {
        // basically the same as above, but do one pixel at a time
        // until we finish
        __m128i n128 = _mm_loadu_si32(needle);
        _mm_storeu_si32(needle_lo, _mm_subs_epu8(n128, tv.m128i));
        _mm_storeu_si32(needle_hi, _mm_adds_epu8(n128, tv.m128i));
        needle     ++;
        needle_hi  ++;
        needle_lo  ++;
        pixelcount --;
    }
    return 0;
}
#endif

#if defined(MARCH_x86_64_v4) || defined(MARCH_x86_64_v3)
static inline u32 i_imgutil_make_sat_masks_v3
            (
                u32* __restrict needle, 
                         i32  pixelcount,
                u32* __restrict needle_lo,
                u32* __restrict needle_hi,
                vec     tv
            )
{
    i32 vecsize      = (sizeof(__m256i)/sizeof(i32));
    while (pixelcount >= vecsize) {
        // load a vector's worth of needle
        __m256i n256 = _mm256_loadu_si256((__m256i*)needle);
        // subtract t values from needle values using saturation
        __m256i nl   = _mm256_subs_epu8(n256, tv.m256i);
        // store the low mask
        _mm256_storeu_si256((__m256i*)needle_lo, nl);

        // load a vector's worth of needle
        n256 = _mm256_loadu_si256((__m256i*)needle);
        // add t values to needle using saturation
        __m256i nh   = _mm256_adds_epu8(n256, tv.m256i);
        // store the hi mask
        _mm256_storeu_si256((__m256i*)needle_hi, nh);

        needle     += vecsize;
        needle_hi  += vecsize;
        needle_lo  += vecsize;
        pixelcount -= vecsize;
    }
    return i_imgutil_make_sat_masks_v12(needle, pixelcount, needle_lo, needle_hi, tv);
}
#endif

#if defined(MARCH_x86_64_v4)
static inline u32 i_imgutil_make_sat_masks_v4
            (
                u32* __restrict needle, 
                         i32  pixelcount,
                u32* __restrict needle_lo,
                u32* __restrict needle_hi,
                vec     tv
            )
{
    i32 vecsize      = (sizeof(__m512i)/sizeof(i32));
    while (pixelcount >= vecsize) {
        // load a vector's worth of needle
        __m512i n512 = _mm512_loadu_si512((__m512i*)needle);
        // subtract t values from needle values using saturation
        __m512i nl   = _mm512_subs_epu8(n512, tv.m512i);
        // store the low mask
        _mm512_storeu_si512((__m512i*)needle_lo, nl);
        // load a vector's worth of needle
        n512 = _mm512_loadu_si512((__m512i*)needle);
        // add t values to needle using saturation
        __m512i nh   = _mm512_adds_epu8(n512, tv.m512i);
        // store the hi mask
        _mm512_storeu_si512((__m512i*)needle_hi, nh);
        needle     += vecsize;
        needle_hi  += vecsize;
        needle_lo  += vecsize;
        pixelcount -= vecsize; 
    }
    if (pixelcount) {
        //16-bit mask for loading the last pixelcount pixels
        i16 mask = (1 << pixelcount) - 1;
        // basically the same as above but with masked load/store
        __m512i h512 = _mm512_maskz_loadu_epi32(_cvtu32_mask16(mask), needle);
        __m512i nl   = _mm512_subs_epu8(h512, tv.m512i);
        _mm512_mask_storeu_epi32(needle_lo, _cvtu32_mask16(mask), nl);
        __m512i nh   = _mm512_adds_epu8(h512, tv.m512i);
        _mm512_mask_storeu_epi32(needle_hi, _cvtu32_mask16(mask), nh);
    }
    return 0;
}
#endif

u32 imgutil_make_sat_masks (
    u32* __restrict needle, 
            i32  pixelcount,
    u32* __restrict needle_lo,
    u32* __restrict needle_hi,
    u8      t
) {
    vec v;
    if (needle == 0 || needle_lo == 0 || needle_hi == 0)
        return 0;
    v.__mvec = _mvec_set1_epi32(0xff << 24  | t << 16 | t << 8 | t);
    return i_imgutil_make_sat_masks(needle, pixelcount, needle_lo, needle_hi, v);
}
