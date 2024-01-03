/*
    notes on performance:

    on my 2-socket xeon gold 6256 (cascade lake) with 12 cores each, copying a
    3840x2160 bitmap to a 3840x2160 bitmap, the following timings were observed:

    (0 threads refers to a completely single-threaded implementation with no
    thread scheduling overhead at all)

    threads:                                  0        24        12        8         4
    psabi level 4 (avx512):           5643.34us  660.33us  907.28us 851.21us 1377.41us    
    psabi level 3 (avx2):             4520.80us  623.99us  840.05us 747.94us 1154.73us
    psabi level 2 (sse4.1):           4721.44us  629.88us  813.67us 734.11us 1252.19us
    psabi level 1 (sse2, no popcnt):  4708.10us  618.58us  833.47us 724.22us 1254.71us
    psabi level 0 (scalar only code): 5175.98us  626.80us  878.73us 776.88us 1296.01us

    on intel core i9 12900h (alder lake, 6p&8e cores), with the same inputs:

    threads:                                    0        14         7         4
    psabi level 4 (avx512):                   n/a       n/a       n/a       n/a
    psabi level 3 (avx2):               2585.32us 1148.11us  895.74us  963.76us
    psabi level 2 (sse4.1):             2637.13us 1167.68us  915.58us 1050.42us
    psabi level 1 (sse2, no popcnt):    2608.24us 1193.32us  912.41us 1047.78us
    psabi level 0 (scalar only code):   3270.11us 1212.42us 1076.43us 1329.08us

    intel xeon e5-2687w, 2 sockets, 10 cores each:

    threads:                                  20       10        4
    psabi level 4 (avx512):                  n/a      n/a      n/a
    psabi level 3 (avx2):               
    psabi level 2 (sse4.1):             
    psabi level 1 (sse2, no popcnt):    
    psabi level 0 (scalar only code):   

    threads:                                  4
    psabi level 4 (avx512):                 n/a
    psabi level 3 (avx2):             3906.25us
    psabi level 2 (sse4.1):           3623.19us
    psabi level 1 (sse2, no popcnt):  3599.71us
    psabi level 0 (scalar only code): 3465.00us

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
