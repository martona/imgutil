#include "i_imgutil.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// check if two color channel values match within the allowed tolerance t
static inline i32 i_imgutil_channel_match(i32 a, i32 b, i32 t) {
    // clang 17 optimizes this well, but gcc 13.2 uses a branch:
    // return (i32)((a - t) <= b) && ((a + t) >= b);

    // this is branchless on both, and same number of ops.
    // mindblown.gif
    // same code on clang as above, actually.
    int c = a - b;
    return ((c >= 0) ? c : -c) <= t;}

i32 imgutil_channel_match(i32 a, i32 b, i32 t) {
    return i_imgutil_channel_match(a, b, t);
}

// check if two pixels match each other within the allowed tolerance t
static inline u32 i_imgutil_pixels_match(argb p1, argb p2, i32 t) {
    return i_imgutil_channel_match(p1.r, p2.r, t) && 
           i_imgutil_channel_match(p1.g, p2.g, t) && 
           i_imgutil_channel_match(p1.b, p2.b, t);
}

u32 imgutil_pixels_match(argb p1, argb p2, i32 t) {
    return i_imgutil_pixels_match(p1, p2, t);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
static inline i32 i_imgutil_column_uniform(
    argb* ptr, i32 width, i32 height, 
    argb  refc, i32 x, i32 tolerance, 
    i32 ymin, i32 ymax) 
{
    argb* end = ptr + x + ymax * width;
    ptr += x;
    ptr += ymin * width;
    while (ptr < end) {
        if (!i_imgutil_pixels_match(*ptr, refc, tolerance))
            return 0;
        ptr += width;
    }
    return 1;
}

u32 imgutil_column_uniform(
    argb* ptr, i32 width, i32 height, 
    argb refc, i32 x, i32 tolerance, 
    i32 ymin, i32 ymax) 
{
    return i_imgutil_column_uniform(ptr, width, height, refc, x, tolerance, ymin, ymax);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
static inline i32 i_imgutil_row_uniform(
    argb* ptr, i32 width, i32 height, 
    argb refc, i32 y, i32 tolerance, 
    i32 xmin, i32 xmax) 
{
    argb* end = ptr + y * width + xmax;
    ptr += y * width;
    ptr += xmin;
    while (ptr < end) {
        if (!i_imgutil_pixels_match(*ptr, refc, tolerance))
            return 0;
        ptr++;
    }
    return 1;
}

i32 imgutil_row_uniform(
    argb* ptr, i32 width, i32 height, 
    argb refc, i32 y, i32 tolerance, 
    i32 xmin, i32 xmax)
{
    return i_imgutil_row_uniform(ptr, width, height, refc, y, tolerance, xmin, xmax);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
argb* imgutil_makebw(argb* start, u32 w, u32 h, u8 threshold) {
    argb* end = start + w * h;
    argb* current = start;
    u32 t = threshold * 3;
    argb black = {0xff, 0x00, 0x00, 0x00};
    argb white = {0xff, 0xff, 0xff, 0xff};
    while (current < end) {
        argb c = *current;
        u32 s = c.r + c.g + c.b;
        *current = s < threshold ? black : white;
        current++;
    }
    return current;
}
