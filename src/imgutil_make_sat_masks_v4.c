#define MARCH_x86_64_v4

#include "i_imgutil.h"
#include "i_imgutil_make_sat_masks.c"

u32 imgutil_make_sat_masks_v4(u32* __restrict needle, i32 needle_pixels, u32* __restrict needle_lo, u32* __restrict needle_hi, u8 t) {
    __m512i tv = _mm512_set1_epi32(0xff << 24  | t  << 16 | t  << 8 | t );
    return i_imgutil_make_sat_masks_v4(needle, needle_pixels, needle_lo, needle_hi, tv);
}
