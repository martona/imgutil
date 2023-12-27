/*
    notes on performance:

*/

#include "i_imgutil_blit.c"
#include "../submodules/multithread/multithread.h"

typedef struct {
    i32     scanline;
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

static __stdcall void blit_worker(ptr param) {
    blit_thread_ctx* ctx = (blit_thread_ctx*)param;
    // enter a loop to blit one line at a time inside
    while (1) {     
        i32 scanline = __atomic_fetch_add(&ctx->scanline, 1, __ATOMIC_SEQ_CST);
        // we might be done
        if (scanline >= ctx->h)
            return;
        // just one line, i promise
        argb* src = ctx->src + (scanline + ctx->sy) * ctx->sstride + ctx->sx;
        argb* dst = ctx->dst + (scanline + ctx->dy) * ctx->dstride + ctx->dx;
        imgutil_blit_line(dst, src, ctx->w);
    }
}

i32 imgutil_blit_multi (
    mt_ctx* ctx,
    argb* dst, i32 dx, i32 dy, i32 dstride,
    argb* src, i32 sx, i32 sy, i32 sstride,
    i32 w, i32 h)
{
    // TODO: pick some arbitrary threshold for when to use multithreading
    if (w * h < 1)
        return imgutil_blit(dst, dx, dy, dstride, src, sx, sy, sstride, w, h);

    // context for worker threads
    blit_thread_ctx tctx = {
        .scanline   = 0,                // start at the top
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

