#include "i_imgutil.h"

i32 imgutil_blit (
    argb* dst, i32 dx, i32 dy, i32 dstride,
    argb* src, i32 sx, i32 sy, i32 sstride,
    i32 w, i32 h)
{
    if (dx < 0 || sx < 0 || dy < 0 || sy < 0)
        return 0;
    if (w < 0 || h < 0)
        return 0;
   
    argb* d = dst + dy * dstride + dx;
    argb* s = src + sy * sstride + sx;
    for (i32 y = 0; y < h; y++) {
        for (i32 x = 0; x < w; x++) {
            *d++ = *s++;
        }
        d += dstride - w;
        s += sstride - w;
    }
    return 1;
}

//TODO: vectorize this