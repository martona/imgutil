#include "i_imgutil_blit.c"
/*
    notes on performance:

    on my xeon gold 6256 (cascade lake), with a 3840x2160 image being copied, the
    following timings were observed on average over 5000 runs:

    psabi level 4 (avx512):              168.22us
    psabi level 3 (avx2):                512.82us
    psabi level 2 (sse4.1):              510.57us
    psabi level 1 (sse2, no popcnt):    1006.85us
    psabi level 0 (scalar only code):   2197.80us

    on intel core i9 12900h (alder lake), with the same inputs:

    psabi level 4 (avx512):                   n/a
    psabi level 3 (avx2):                179.46us
    psabi level 2 (sse4.1):              315.07us
    psabi level 1 (sse2, no popcnt):     321.98us
    psabi level 0 (scalar only code):   1181.75us
*/

i32 imgutil_blit (
    argb* dst, i32 dx, i32 dy, i32 dstride,
    argb* src, i32 sx, i32 sy, i32 sstride,
    i32 w, i32 h)
{
    // some basic sanity checks.
    // we dont know the size of the images, 
    // so we can't do much more
    if (dx < 0 || sx < 0 || dy < 0 || sy < 0)
        return 0;
    if (w <= 0 || h <= 0)
        return 0;

    argb* d = dst + dy * dstride + dx;
    argb* s = src + sy * sstride + sx;
    for (i32 y = 0; y < h; y++) {
        imgutil_blit_line(dst, src, w);
        d += dstride;
        s += sstride;
    }
    return 1;
}
