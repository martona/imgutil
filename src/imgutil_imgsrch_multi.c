/*
    3840x2160 haystack, 64x64 needle located in the bottom right corner

    2-socket xeon gold 6256 (cascade lake, 12 cores each)
    threads:                                  24       12        8        4
    psabi level 4 (avx512):              12.36ms  15.53ms  21.74ms  43.14ms
    psabi level 3 (avx2):                23.35ms  28.90ms  38.46ms  76.23ms
    psabi level 2 (sse4.2):              80.10ms  47.02ms  66.00ms 130.20ms
    psabi level 1 (sse2, no popcnt):     80.63ms 110.39ms 158.22ms 313.44ms
    psabi level 0 (scalar only code):    76.91ms  98.35ms 138.05ms 273.84ms

    intel core i9 12900h (alder lake, 6p&8e cores)
    threads:                                  14        7        4
    psabi level 4 (avx512):                  n/a      n/a      n/a
    psabi level 3 (avx2):                31.75ms  42.28ms  65.34ms
    psabi level 2 (sse4.2):              48.53ms  67.57ms 105.81ms
    psabi level 1 (sse2, no popcnt):     96.46ms 138.89ms 217.39ms
    psabi level 0 (scalar only code):    89.84ms 130.62ms 203.12ms

    2-socket intel xeon e5-2687w (sandy bridge ep, 10 cores each)
    threads:                                  20       10        4
    psabi level 4 (avx512):                  n/a      n/a      n/a
    psabi level 3 (avx2):                41.24ms  45.33ms 116.63ms
    psabi level 2 (sse4.2):              77.65ms  88.54ms 214.17ms
    psabi level 1 (sse2, no popcnt):    163.29ms 183.61ms 458.82ms    
    psabi level 0 (scalar only code):   140.64ms 170.83ms 400.23ms

    intel core i5 8250u (kaby lake-r, 4 cores)
    threads:                                   4
    psabi level 4 (avx512):                  n/a
    psabi level 3 (avx2):               134.87ms
    psabi level 2 (sse4.2):             233.68ms
    psabi level 1 (sse2, no popcnt):    537.50ms
    psabi level 0 (scalar only code):   467.36ms

    intel core i7 8650u (coffee lake-u/y, 4 cores)
    threads:                                  4
    psabi level 4 (avx512):                 n/a
    psabi level 3 (avx2):              131.41ms
    psabi level 2 (sse4.2):            252.35ms
    psabi level 1 (sse2, no popcnt):   515.60ms
    psabi level 0 (scalar only code):  446.58ms

    intel core 2 duo t7700 (merom, 2 cores)
    threads:                                  2
    psabi level 4 (avx512):                 n/a
    psabi level 3 (avx2):                   n/a
    psabi level 2 (sse4.2):                 n/a
    psabi level 1 (sse2, no popcnt):  3351.50ms
    psabi level 0 (scalar only code): 2255.32ms
*/

#include "i_imgutil.h"
#include "../submodules/multithread/multithread.h"

typedef struct {
    i32             scanline;           // the scanline we're working on
    ptr             result;             // the result of the search
    i32             pixels_matched;     // the quality of the match
    i32             result_lock;        // spinlock guarding the two previous fields
    mt_ctx*         ctx;                // a copy of the mt_ctx we were given
    i_imgsrch_ctx   srch_ctx;           // the search context
} thread_ctx;

static void __stdcall imgutil_imgsrch_worker(ptr param, i32 thread_idx) {
    thread_ctx* ctx = (thread_ctx*)param;
    // we get the quality of the match in here
    i32 pixels_matched = 0;
    // reserve a scan line
    while (1) {     
        i32 scanline = __atomic_fetch_add(&ctx->scanline, 1, __ATOMIC_SEQ_CST);
        // we might be done
        if (scanline > ctx->srch_ctx.haystack_h - ctx->srch_ctx.needle_h)
            return;
        // just one line, i promise
        argb* result = 0;
        if (ctx->srch_ctx.force_topleft) {
            result = i_imgutil_imgsrch_haystackline_forcetopleft(
                &ctx->srch_ctx,      // serach parameters
                &pixels_matched,     // pointer to store the number of pixels matched
                scanline
            );
        } else {
            result = i_imgutil_imgsrch_haystackline(
                &ctx->srch_ctx,      // serach parameters
                &pixels_matched,     // pointer to store the number of pixels matched
                scanline
            );
        }
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
            if (pixels_matched >= ctx->srch_ctx.needle_pixels) {
                // then tell everyone we're done
                // (i mean it's a bit of a hack, but it works)
                __atomic_store_n(&ctx->scanline, ctx->srch_ctx.haystack_h, __ATOMIC_SEQ_CST);
            }
        }
    }
}

argb* imgutil_imgsrch_multi (
    mt_ctx* ctx,
    argb*   haystack,           // the haystack image buffer; assumed flat 32-bit RGB or ARGB
    i32     haystack_w,         // width of the image
    i32     haystack_h,         // height of the image
    argb*   needle_lo,          // pre-made mask where each each pixel channel is the low value
    argb*   needle_hi,          // pre-made mask where each each pixel channel is the high value
    i32     needle_w,           // width of the image
    i32     needle_h,           // height of the image
    i8      pctmatchreq,        // minimum percentage of pixels to match from needle
    i32     force_topleft,      // force top left pixel to match before determining percentages
    i32*    ppixels_matched     // optional pointer to store the number of pixels matched)
)
{
    // some basic sanity checks.
    if (!haystack || !needle_lo || !needle_hi)
        return 0;

    // this is the context the guy above us expects
    thread_ctx tctx = {
        .scanline       = 0,                // the threads will compete to increase this up to haystack_h - needle_h
        .result         = 0,                // this is the output, reflecting the best match found
        .pixels_matched = 0,                // the quality of the best match
        .result_lock    = 0,                // spinlock guarding the two previous fields
        .ctx            = ctx,              // a copy of the mt_ctx we were given
    };
    tctx.srch_ctx.haystack        = haystack;
    tctx.srch_ctx.haystack_w      = haystack_w;
    tctx.srch_ctx.haystack_h      = haystack_h;
    tctx.srch_ctx.needle_lo       = needle_lo;
    tctx.srch_ctx.needle_hi       = needle_hi;
    tctx.srch_ctx.needle_w        = needle_w;
    tctx.srch_ctx.needle_h        = needle_h;
    tctx.srch_ctx.pctmatchreq     = pctmatchreq;
    tctx.srch_ctx.force_topleft   = force_topleft || (pctmatchreq == 100);
    tctx.srch_ctx.needle_pixels   = needle_w * needle_h;
    tctx.srch_ctx.pixels_needed   = needle_w * needle_h * pctmatchreq / 100;
    tctx.srch_ctx.nl.__mvec       = _mvec_set1_epi32(0x00 << 24  | needle_lo[0].r << 16 | needle_lo[0].g << 8 | needle_lo[0].b);
    tctx.srch_ctx.nh.__mvec       = _mvec_set1_epi32(0xff << 24  | needle_hi[0].r << 16 | needle_hi[0].g << 8 | needle_hi[0].b);

    // run the workers
    ctx->mt_run(ctx, imgutil_imgsrch_worker, &tctx);
    // return the result
    if (ppixels_matched)
        *ppixels_matched = tctx.pixels_matched;
    return tctx.result;
}
