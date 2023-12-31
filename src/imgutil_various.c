#include "i_imgutil.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// check if two color channel values match within the allowed tolerance t
static inline i32 i_imgutil_channel_match(i32 a, i32 b, i32 t) {
    // clang 17 optimizes this well, but gcc 13.2 uses a branch:
    // return (i32)((a - t) <= b) && ((a + t) >= b);

    // this is branchless on both, and same number of ops.
    // mindblown.gif
    // same code on clang as above, actually.
    i32 c = a - b;
    return ((c >= 0) ? c : -c) <= t;}

// check if two pixels match each other within the allowed tolerance t
static inline u32 i_imgutil_pixels_match(argb p1, argb p2, i32 t) {
    // binary & on purpose
    return i_imgutil_channel_match(p1.r, p2.r, t) &
           i_imgutil_channel_match(p1.g, p2.g, t) & 
           i_imgutil_channel_match(p1.b, p2.b, t);
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
i32 imgutil_replace_color(argb* ptr, i32 width, i32 height, i32 stride, argb cold, argb cnew, i32 tolerance) {
    argb* end = ptr + height * stride;
    i32 clr_replaced = 0;
    while (ptr < end) {
        argb* end2 = ptr + width;
        while (ptr < end2) {
            if (i_imgutil_pixels_match(*ptr, cold, tolerance)) {
                clr_replaced++;
                *ptr = cnew;
            }
            ptr++;
        }
        ptr += stride - width;
    }
    return clr_replaced;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void imgutil_fill(argb* ptr, i32 width, i32 height, i32 stride, argb c, i32 x, i32 y, i32 w, i32 h) {
    argb* end = ptr + (y + h) * stride + x;
    ptr += y * stride + x;
    while (ptr < end) {
        argb* end2 = ptr + w;
        while (ptr < end2) {
            *ptr = c;
            ptr++;
        }
        ptr += stride - w;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void imgutil_grayscale(argb* ptr, i32 width, i32 height, i32 stride) {
    argb* end = ptr + height * stride;
    while (ptr < end) {
        argb* end2 = ptr + width;
        while (ptr < end2) {
            i32 r = ptr->r;
            i32 g = ptr->g;
            i32 b = ptr->b;
            i32 avg = (r + g + b) / 3;
            ptr->r = avg;
            ptr->g = avg;
            ptr->b = avg;
            ptr++;
        }
        ptr += stride - width;
    }
}
