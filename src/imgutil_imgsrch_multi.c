/*
    3840x2160 haystack, 64x64 needle located in the bottom right corner

*** 2-socket xeon gold 6256 (cascade lake, 12 cores each) (2021 desktop)
    threads:                                   24        12         8         4         2
    psabi level 4 (avx512):               11.56ms   15.37ms   20.90ms   40.97ms   80.87ms
    psabi level 3 (avx2):                 21.89ms   28.01ms   37.02ms   73.35ms  143.30ms
    psabi level 2 (sse4.2):               37.98ms   46.43ms   64.09ms  127.33ms  252.33ms
    psabi level 1 (sse2, no popcnt):      77.63ms   99.87ms  141.48ms  279.48ms  558.98ms
    psabi level 0 (scalar only code):    153.38ms  188.61ms  272.98ms  542.18ms 1081.18ms

*** intel core i9 12900h (alder lake, 6p&8e cores) (2023 alienware x15 r2)
    threads:                                   6         4         2
    psabi level 4 (avx512):                  n/a       n/a       n/a
    psabi level 3 (avx2):                45.18ms   64.93ms  117.37ms
    psabi level 2 (sse4.2):              70.64ms  101.88ms  183.57ms
    psabi level 1 (sse2, no popcnt):    133.21ms  188.66ms  344.80ms
    psabi level 0 (scalar only code):   467.36ms  662.12ms 1212.40ms

    intel xeon d-1540 (broadwell-de, 8 cores) (cca. 2016 supermicro x10sdv-tln4f)
    threads:                                   8         4         2
    psabi level 4 (avx512):                  n/a       n/a       n/a
    psabi level 3 (avx2):                93.73ms  164.31ms  468.72ms
    psabi level 2 (sse4.2):             161.28ms  309.69ms  644.49ms
    psabi level 1 (sse2, no popcnt):    304.22ms  598.99ms 1601.49ms
    psabi level 0 (scalar only code):   593.77ms 1152.99ms 2135.66ms

    2-socket intel xeon e5-2687w v3 (sandy bridge ep, 10 cores each) (2014 desktop)
    threads:                                  20       10        8           4          2
    psabi level 4 (avx512):                  n/a       n/a       n/a       n/a        n/a
    psabi level 3 (avx2):                38.45ms   44.38ms   55.45ms  110.71ms   205.63ms
    psabi level 2 (sse4.2):              76.69ms   85.26ms  106.12ms  212.24ms   401.45ms
    psabi level 1 (sse2, no popcnt):    138.88ms  160.15ms  198.30ms  400.22ms   738.85ms
    psabi level 0 (scalar only code):   267.26ms  312.49ms  391.84ms  794.71ms  1484.49ms

    2-socket intel xeon e5-2687w (sandy bridge ep, 8 cores each) (2012 desktop)
    threads:                                  16         8         4         2
    psabi level 4 (avx512):                  n/a       n/a       n/a       n/a
    psabi level 3 (avx2):                    n/a       n/a       n/a       n/a
    psabi level 2 (sse4.2):              90.90ms  105.78ms  206.23ms  401.45ms
    psabi level 1 (sse2, no popcnt):    206.87ms  249.28ms  485.81ms  968.66ms
    psabi level 0 (scalar only code):   168.76ms  201.87ms  394.22ms  763.42ms

    intel core i5 8250u (kaby lake-r, 4 cores) (2017 system76 galago pro)
    threads:                                   4
    psabi level 4 (avx512):                  n/a
    psabi level 3 (avx2):               134.87ms
    psabi level 2 (sse4.2):             233.68ms
    psabi level 1 (sse2, no popcnt):    537.50ms
    psabi level 0 (scalar only code):   467.36ms

    intel core i7 8650u (coffee lake-u/y, 4 cores) (2018 surface book 2)
    threads:                                  4
    psabi level 4 (avx512):                 n/a
    psabi level 3 (avx2):              131.41ms
    psabi level 2 (sse4.2):            252.35ms
    psabi level 1 (sse2, no popcnt):   515.60ms
    psabi level 0 (scalar only code):  446.58ms

*** intel core 2 duo t7700 (merom, 2 cores) (2007 macbook pro a1229)
    threads:                                  2
    psabi level 4 (avx512):                 n/a
    psabi level 3 (avx2):                   n/a
    psabi level 2 (sse4.2):                 n/a
    psabi level 1 (sse2, no popcnt):  3843.98ms
    psabi level 0 (scalar only code): 8014.98ms

*** 2-socket intel xeon x5680 (westmere ep, 6 cores each) (2010 desktop)
    threads:                                 12         8         4         2
    psabi level 4 (avx512):                 n/a       n/a       n/a       n/a
    psabi level 3 (avx2):                   n/a       n/a       n/a       n/a
    psabi level 2 (sse4.2):             92.88ms  138.50ms  272.20ms  528.09ms
    psabi level 1 (sse2, no popcnt):   437.49ms  658.11ms 1246.79ms 2432.32ms
    psabi level 0 (scalar only code): 1015.59ms 1578.24ms 2890.49ms 5905.99ms

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
                &ctx->srch_ctx,      // search parameters
                &pixels_matched,     // pointer to store the number of pixels matched
                scanline
            );
        } else {
            result = i_imgutil_imgsrch_haystackline(
                &ctx->srch_ctx,      // search parameters
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
