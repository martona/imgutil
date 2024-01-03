#include "i_imgutil_blit.c"
/*
    notes on performance:

    on my xeon gold 6256 (cascade lake), with a 3840x2160 image being copied, the
    following timings were observed on average over 5000 runs:

    psabi level 4 (avx512):             5643.34us
    psabi level 3 (avx2):               4520.80us
    psabi level 2 (sse4.1):             4721.44us
    psabi level 1 (sse2, no popcnt):    4708.10us
    psabi level 0 (scalar only code):   5175.98us

    intel core i9 12900h (alder lake), with the same inputs:

    psabi level 4 (avx512):                   n/a
    psabi level 3 (avx2):               2585.32us
    psabi level 2 (sse4.1):             2637.13us
    psabi level 1 (sse2, no popcnt):    2608.24us
    psabi level 0 (scalar only code):   3270.11us

    intel xeon e5-2687w (sandy bridge ep)

    psabi level 4 (avx512):                  n/a
    psabi level 3 (avx2):            
    psabi level 2 (sse4.1):          
    psabi level 1 (sse2, no popcnt): 
    psabi level 0 (scalar only code):

    intel core i5 8250u (kaby lake-r, 4 cores):

    psabi level 4 (avx512):                  n/a
    psabi level 3 (avx2):              3863.99us
    psabi level 2 (sse4.1):            3924.65us
    psabi level 1 (sse2, no popcnt):   3652.30us
    psabi level 0 (scalar only code):  4317.79us
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
        imgutil_blit_line(d, s, w);
        d += dstride;
        s += sstride;
    }
    return 1;
}
