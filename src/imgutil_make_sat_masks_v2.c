#define MARCH_x86_64_v2

#include "i_imgutil.h"
#include "i_imgutil_make_sat_masks.c"

u32 imgutil_make_sat_masks_v2(u32* __restrict needle, i32 needle_pixels, u32* __restrict needle_lo, u32* __restrict needle_hi, u8 t) {
    __m128i tv = _mm128_set1_epi32(0xff << 24  | t  << 16 | t  << 8 | t );
    return i_imgutil_make_sat_masks_v2(needle, needle_pixels, needle_lo, needle_hi, tv);
}
