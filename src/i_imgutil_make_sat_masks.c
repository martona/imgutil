#include "i_imgutil.h"

static inline u32 i_imgutil_make_sat_masks_v1
            (
                u32* __restrict needle, 
                         i32  pixelcount,
                u32* __restrict needle_lo,
                u32* __restrict needle_hi,
                u8          t
            )
{
    while (pixelcount > 0) {
        u8* nc = (u8*)needle;
        u8 r_lo = subu8(nc[2], t); //saturated subtract
        u8 r_hi = addu8(nc[2], t); //saturated add
        u8 g_lo = subu8(nc[1], t); //saturated subtract
        u8 g_hi = addu8(nc[1], t); //saturated add
        u8 b_lo = subu8(nc[0], t); //saturated subtract
        u8 b_hi = addu8(nc[0], t); //saturated add
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

static inline u32 i_imgutil_make_sat_masks_v2
            (
                u32* __restrict needle, 
                         i32  pixelcount,
                u32* __restrict needle_lo,
                u32* __restrict needle_hi,
                __m128i       tv
            )
{
    i32 vecsize      = (sizeof(__m128i)/sizeof(i32));
    // the vector we're adding and subtracting from needle's values
    while (pixelcount >= vecsize) {
        // load a vector's worth of needle
        __m128i n128 = _mm_loadu_si128((__m128i*)needle);
        // subtract t values from needle values using saturation
        __m128i nl   = _mm_subs_epu8(n128, tv);
        // store the low mask
        _mm_storeu_si128((__m128i*)needle_lo, nl);

        // load a vector's worth of needle
        n128 = _mm_loadu_si128((__m128i*)needle);
        // add t values to needle using saturation
        __m128i nh   = _mm_adds_epu8(n128, tv);
        // store the hi mask
        _mm_storeu_si128((__m128i*)needle_hi, nh);

        needle    += vecsize;
        needle_hi += vecsize;
        needle_lo += vecsize;
        pixelcount -= vecsize;
    }
    return i_imgutil_make_sat_masks_v1(needle, pixelcount, needle_lo, needle_hi, *((u8*)&tv));
}

static inline u32 i_imgutil_make_sat_masks_v4
            (
                u32* __restrict needle, 
                         i32  pixelcount,
                u32* __restrict needle_lo,
                u32* __restrict needle_hi,
                __m512i       tv
            )
{
    i32 vecsize      = (sizeof(__m512i)/sizeof(i32));
    while (pixelcount >= vecsize) {
        // load a vector's worth of needle
        __m512i n512 = _mm512_loadu_si512((__m512i*)needle);
        // subtract t values from needle values using saturation
        __m512i nl   = _mm512_subs_epu8(n512, tv);
        // store the low mask
        _mm512_storeu_si512((__m512i*)needle_lo, nl);

        // load a vector's worth of needle
        n512 = _mm512_loadu_si512((__m512i*)needle);
        // add t values to needle using saturation
        __m512i nh   = _mm512_adds_epu8(n512, tv);
        // store the hi mask
        _mm512_storeu_si512((__m512i*)needle_hi, nh);

        needle    += vecsize;
        needle_hi += vecsize;
        needle_lo += vecsize;
        pixelcount -= vecsize;
    }
    return i_imgutil_make_sat_masks_v2(needle, pixelcount, needle_lo, needle_hi, *((__m128i*)&tv));
}
