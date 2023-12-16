#define MARCH_x86_64_V1

#include "i_imgutil.h"
#include "i_imgutil_make_sat_masks.c"

u32 imgutil_make_sat_masks_v1(u32* __restrict needle, i32 needle_pixels, u32* __restrict needle_lo, u32* __restrict needle_hi, u8 t) {
    return i_imgutil_make_sat_masks_v1(needle, needle_pixels, needle_lo, needle_hi, t);
}
