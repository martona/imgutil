#include "i_imgutil_blit.c"
/*
    copying a 3840x2160 bitmap
    -- conclusion is that AVX512 = bad for plain copying.
    -- apparently it blocks port 1 on the cpu on many
    -- architectures. should not use it for this purpose.
         
*** xeon gold 6256 (cascade lake) (2021 desktop) 
    psabi level 4 (avx512):             5550.68us
    psabi level 3 (avx2):               4548.87us
    psabi level 2 (sse4.2):             4548.84us
    psabi level 1 (sse2, no popcnt):    4582.27us
    psabi level 0 (scalar only code):   5325.60us

    intel core i9 12900h (alder lake) (2023 alienware x15 r2)
    psabi level 4 (avx512):                   n/a
    psabi level 3 (avx2):               2585.32us
    psabi level 2 (sse4.2):             2637.13us
    psabi level 1 (sse2, no popcnt):    2608.24us
    psabi level 0 (scalar only code):   3270.11us

*** intel xeon d-1540 (broadwell-de, 8 cores) (cca. 2016 supermicro x10sdv-tln4f)
    psabi level 4 (avx512):                  n/a
    psabi level 3 (avx2):              6772.29us
    psabi level 2 (sse4.2):            6818.38us
    psabi level 1 (sse2, no popcnt):   6836.74us
    psabi level 0 (scalar only code):  7426.55us
         
*** intel xeon e5-2687w (sandy bridge ep) (2014 desktop)
    psabi level 4 (avx512):                  n/a
    psabi level 3 (avx2):              5328.44us
    psabi level 2 (sse4.2):            5374.31us
    psabi level 1 (sse2, no popcnt):   5322.71us
    psabi level 0 (scalar only code):  5362.73us

    intel core i5 8250u (kaby lake-r) (2017 system76 galago pro)
    psabi level 4 (avx512):                  n/a
    psabi level 3 (avx2):              3863.99us
    psabi level 2 (sse4.2):            3924.65us
    psabi level 1 (sse2, no popcnt):   3652.30us
    psabi level 0 (scalar only code):  4317.79us

    intel core i7 8650u (coffee lake-u/y) (2018 surface book 2)
    psabi level 4 (avx512):                  n/a
    psabi level 3 (avx2):              4672.90us
    psabi level 2 (sse4.2):            4703.67us
    psabi level 1 (sse2, no popcnt):   4757.37us
    psabi level 0 (scalar only code):  5165.29us

    intel core 2 duo t7700 (merom) (2007 macbook pro a1229)
    psabi level 4 (avx512):                  n/a
    psabi level 3 (avx2):                    n/a
    psabi level 2 (sse4.2):                  n/a
    psabi level 1 (sse2, no popcnt):     28.82ms
    psabi level 0 (scalar only code):    28.08ms
*/

i32 imgutil_blit (
    argb* dst, i32 dx, i32 dy, i32 dstride,
    argb* src, i32 sx, i32 sy, i32 sstride,
    i32 w, i32 h)
{
    // some basic sanity checks.
    // we dont know the size of the images, 
    // so we can't do much more
    if (!dst || !src)
        return 0;
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
