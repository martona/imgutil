#include "i_imgutil.h"
#include "../submodules/multithread/multithread.h"

typedef struct {
    i32     scanline;
    ptr     result;
    i32     pixels_matched;
    i32     result_lock;
    mt_ctx* ctx;
    argb*   haystack;
    i32     haystack_w;
    i32     haystack_h;
    argb*   needle_lo;
    argb*   needle_hi;
    i32     needle_w;
    i32     needle_h;
    i8      pctmatchreq;
    i32     force_topleft;
} thread_ctx;

static void imgutil_imgsrch_worker(ptr param) {
    thread_ctx* ctx = (thread_ctx*)param;
    // we get the quality of the match in here
    i32 pixels_matched = 0;
    // reserve a scan line
    while (1) {     
        i32 scanline = __atomic_fetch_add(&ctx->scanline, 1, __ATOMIC_SEQ_CST);
        // we might be done
        if (scanline > ctx->haystack_h - ctx->needle_h)
            return;
        // just one line, i promise
        argb* result = imgutil_imgsrch(
            ctx->haystack + scanline * ctx->haystack_w, // adjusted for the thread's state
            ctx->haystack_w,                            // copy verbatim
            ctx->needle_h,                              // only do one scanline
            ctx->needle_lo,                             // copy verbatim
            ctx->needle_hi,                             // copy verbatim
            ctx->needle_w,                              // copy verbatim
            ctx->needle_h,                              // copy verbatim                      
            ctx->pctmatchreq,                           // copy verbatim
            ctx->force_topleft,                         // copy verbatim
            &pixels_matched                             // return pixels matched
        );
        if (result) {
            // like a record baby, right round round round
            while (__atomic_test_and_set(&ctx->result_lock, __ATOMIC_SEQ_CST)) {
            }
            // if we have a better match than what's in there already, replace it
            if (pixels_matched > ctx->pixels_matched) {
                ctx->pixels_matched = pixels_matched;
                ctx->result = result;
            }
            __atomic_clear(&ctx->result_lock, __ATOMIC_SEQ_CST);
            // do we have a perfect match?
            if (pixels_matched >= ctx->needle_w * ctx->needle_h) {
                // then tell everyone we're done
                // (i mean it's a bit of a hack, but it works)
                __atomic_store_n(&ctx->scanline, ctx->haystack_h, __ATOMIC_SEQ_CST);
            }
        }
    }
}

argb* imgutil_imgsrch_multi (
    mt_ctx* ctx,
    argb*   haystack,      // the haystack image buffer; assumed flat 32-bit RGB or ARGB
    i32     haystack_w,    // width of the image
    i32     haystack_h,    // height of the image
    argb*   needle_lo,     // pre-made mask where each each pixel channel is the low value
    argb*   needle_hi,     // pre-made mask where each each pixel channel is the high value
    i32     needle_w,      // width of the image
    i32     needle_h,      // height of the image
    i8      pctmatchreq,   // minimum percentage of pixels to match from needle
    i32     force_topleft, // force top left pixel to match before determining percentages
    i32*    ppixels_matched// optional pointer to store the number of pixels matched)
)
{
    // this is the context the guy above us expects
    thread_ctx tctx = {
        .scanline       = 0,                // the threads will compete to increase this up to haystack_h - needle_h
        .result         = 0,                // this is the output, reflecting the best match found
        .pixels_matched = 0,                // the quality of the best match
        .result_lock    = 0,                // spinlock guarding the two previous fields
        .ctx            = ctx,              // a copy of the mt_ctx we were given
        .haystack       = haystack,         // haystack bits, and...
        .haystack_w     = haystack_w,       // blah
        .haystack_h     = haystack_h,       // blah
        .needle_lo      = needle_lo,        // blah
        .needle_hi      = needle_hi,        // blah
        .needle_w       = needle_w,         // blah
        .needle_h       = needle_h,         // blah
        .pctmatchreq    = pctmatchreq,      // percentage of pixels to match
        .force_topleft  = force_topleft     // force top left pixel to match before determining percentages?
    };
    // run the workers
    ctx->mt_run_threads(ctx, imgutil_imgsrch_worker, &tctx);
    // return the result
    if (ppixels_matched)
        *ppixels_matched = tctx.pixels_matched;
    return tctx.result;
}
