/*
    copying a 3840x2160 bitmap

*** 2-socket xeon gold 6256 (cascade lake, 12 cores each) (2021 desktop) 
    threads:                                24        12        8         4         2
    psabi level 4 (avx512):           715.61us  870.93us 844.00us 1454.70us 2660.17us    
    psabi level 3 (avx2):             675.59us  816.24us 803.22us 1221.63us 2217.07us
    psabi level 2 (sse4.2):           664.56us  833.88us 782.84us 1190.55us 2265.51us
    psabi level 1 (sse2, no popcnt):  663.21us  816.52us 806.64us 1198.03us 2266.57us
    psabi level 0 (scalar only code): 692.27us  840.97us 831.17us 1397.86us 2411.49us

    intel core i9 12900h (alder lake, 6p&8e cores) (2023 alienware x15 r2)
    threads:                                   14         7         4
    psabi level 4 (avx512):                   n/a       n/a       n/a
    psabi level 3 (avx2):               1148.11us  895.74us  963.76us
    psabi level 2 (sse4.2):             1167.68us  915.58us 1050.42us
    psabi level 1 (sse2, no popcnt):    1193.32us  912.41us 1047.78us
    psabi level 0 (scalar only code):   1212.42us 1076.43us 1329.08us

*** intel xeon d-1540 (broadwell-de, 8 cores) (cca. 2016 supermicro x10sdv-tln4f)
    threads:                                   8         4         2
    psabi level 4 (avx512):                  n/a       n/a       n/a
    psabi level 3 (avx2):              3787.74us 3635.94us 4223.40us
    psabi level 2 (sse4.2):            3373.25us 3614.86us 4251.88us
    psabi level 1 (sse2, no popcnt):   3386.67us 3607.09us 4248.53us
    psabi level 0 (scalar only code):  3390.67us 3711.62us 4731.66us
         
*** 2-socket intel xeon e5-2687w (sandy bridge ep, 10 cores each) (2014 desktop)
    threads:                                  20        10         8         4         2
    psabi level 4 (avx512):                  n/a       n/a       n/a       n/a       n/a
    psabi level 3 (avx2):              1711.79us 1797.60us 1812.59us 2069.82us 2866.35us
    psabi level 2 (sse4.2):            1711.28us 1799.54us 1818.53us 2076.74us 2858.15us
    psabi level 1 (sse2, no popcnt):   1711.22us 1796.32us 1816.56us 2068.15us 2856.54us
    psabi level 0 (scalar only code):  1709.45us 1801.45us 1830.57us 2153.73us 2911.41us

    intel core i5 8250u (kaby lake-r, 4 cores) (2017 system76 galago pro)
    threads:                                  4
    psabi level 4 (avx512):                 n/a
    psabi level 3 (avx2):             3906.25us
    psabi level 2 (sse4.2):           3623.19us
    psabi level 1 (sse2, no popcnt):  3599.71us
    psabi level 0 (scalar only code): 3465.00us

    intel core i7 8650u (coffee lake-u/y, 4 cores) (2018 surface book 2)
    threads:                                  4
    psabi level 4 (avx512):                 n/a
    psabi level 3 (avx2):             5170.63us
    psabi level 2 (sse4.2):           4826.25us
    psabi level 1 (sse2, no popcnt):  4859.09us
    psabi level 0 (scalar only code): 4480.29us

    intel core 2 duo t7700 (merom, 2 cores) (2007 macbook pro a1229)
    threads:                                  2
    psabi level 4 (avx512):                 n/a
    psabi level 3 (avx2):                   n/a
    psabi level 2 (sse4.2):                 n/a
    psabi level 1 (sse2, no popcnt):    26.39ms
    psabi level 0 (scalar only code):   63.68ms
*/

#include "i_imgutil_blit.c"
#include "../submodules/multithread/multithread.h"

typedef struct {
    i32     thread_idx;
    mt_ctx* ctx;
    argb*   dst;
    i32     dx;
    i32     dy;
    i32     dstride;
    argb*   src;
    i32     sx;
    i32     sy;
    i32     sstride;
    i32     w;
    i32     h;
} blit_thread_ctx;

// NOTE: do not use the MSPOOL implementation with this worker, as the threadid
// passed to this function will always be -1. 
static __stdcall void blit_worker(ptr param, i32 thread_idx) {
    blit_thread_ctx* ctx = (blit_thread_ctx*)param;
    // calculate the scanlines we're responsible for
    i32 current_scanline = thread_idx * ctx->h / ctx->ctx->num_threads;
    i32 ending_scanline  = (thread_idx + 1) * ctx->h / ctx->ctx->num_threads;

    // calculate the pointers to the first pixel we're responsible for
    argb* src = ctx->src + (current_scanline + ctx->sy) * ctx->sstride + ctx->sx;
    argb* dst = ctx->dst + (current_scanline + ctx->dy) * ctx->dstride + ctx->dx;

    // enter a loop to blit one line at a time inside
    while (current_scanline < ending_scanline) {     
        imgutil_blit_line(dst, src, ctx->w);
        current_scanline++;
        src += ctx->sstride;
        dst += ctx->dstride;
    }
}

i32 imgutil_blit_multi (
    mt_ctx* ctx,
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

    // context for worker threads
    blit_thread_ctx tctx = {
        .thread_idx = 0,                // start at the top
        .ctx        = ctx,              // the multithreading context
        .dst        = dst,              // the destination
        .dx         = dx,               // the destination x
        .dy         = dy,               // the destination y
        .dstride    = dstride,          // the destination stride
        .src        = src,              // the source
        .sx         = sx,               // the source x
        .sy         = sy,               // the source y
        .sstride    = sstride,          // the source stride
        .w          = w,                // the width
        .h          = h                 // the height
    };
    // run the workers
    ctx->mt_run(ctx, blit_worker, &tctx);
    return 1;

}
