#include "i_imgutil.h"

static inline u32 i_imgutil_make_sat_masks_v1
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
        u8* nc = (u8*)needle;
        u8 r_lo = subu8(nc[2], t.r); //saturated subtract
        u8 r_hi = addu8(nc[2], t.r); //saturated add
        u8 g_lo = subu8(nc[1], t.g); //saturated subtract
        u8 g_hi = addu8(nc[1], t.g); //saturated add
        u8 b_lo = subu8(nc[0], t.b); //saturated subtract
        u8 b_hi = addu8(nc[0], t.b); //saturated add
        u8* nlc = (u8*)needle_lo;
        u8* nhc = (u8*)needle_hi;
        nlc[3] = (u8)0x00; nlc[2] = r_lo; nlc[1] = g_lo; nlc[0] = b_lo; 
        nhc[3] = (u8)0xff; nhc[2] = r_hi; nhc[1] = g_hi; nhc[0] = b_hi;
        needle++;
        needle_hi++;
        needle_lo++;
        pixelcount--;
    }
    return 0;
}

#if defined(MARCH_x86_64_v4) || defined(MARCH_x86_64_v3) || defined(MARCH_x86_64_v2)
static inline u32 i_imgutil_make_sat_masks_v2
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
        // load a vector's worth of needle
        n128 = _mm_loadu_si128((__m128i*)needle);
        // add t values to needle using saturation
        __m128i nh   = _mm_adds_epu8(n128, tv.m128i);
        // store the hi mask
        _mm_storeu_si128((__m128i*)needle_hi, nh);

        needle     += vecsize;
        needle_hi  += vecsize;
        needle_lo  += vecsize;
        pixelcount -= vecsize;
    }
    return i_imgutil_make_sat_masks_v1(needle, pixelcount, needle_lo, needle_hi, tv);
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
    return i_imgutil_make_sat_masks_v2(needle, pixelcount, needle_lo, needle_hi, tv);
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
    return i_imgutil_make_sat_masks_v3(needle, pixelcount, needle_lo, needle_hi, tv);
}
#endif

#if defined(MARCH_x86_64_v4)
    #define i_imgutil_make_sat_masks i_imgutil_make_sat_masks_v4
#elif defined(MARCH_x86_64_v3)
    #define i_imgutil_make_sat_masks i_imgutil_make_sat_masks_v3
#elif defined(MARCH_x86_64_v2)
    #define i_imgutil_make_sat_masks i_imgutil_make_sat_masks_v2
#elif defined(MARCH_x86_64_v1)
    #define i_imgutil_make_sat_masks i_imgutil_make_sat_masks_v1
#endif

u32 imgutil_make_sat_masks (
    u32* __restrict needle, 
            i32  pixelcount,
    u32* __restrict needle_lo,
    u32* __restrict needle_hi,
    u8      t
) {
    vec v;
    v.__mvec = _mvec_set1_epi32(0xff << 24  | t << 16 | t << 8 | t);
    return i_imgutil_make_sat_masks(needle, pixelcount, needle_lo, needle_hi, v);
}
