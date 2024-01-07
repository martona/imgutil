/*
    3840x2160 haystack 64x64 needle located in the bottom right corner

    xeon gold 6256 (cascade lake)
    psabi level 4 (avx512):              167.2ms
    psabi level 3 (avx2):                297.8ms
    psabi level 2 (sse4.2):              511.0ms
    psabi level 1 (sse2, no popcnt):    1234.4ms
    psabi level 0 (scalar only code):   1078.2ms

    intel core i9 12900h (alder lake)
    psabi level 4 (avx512):                  n/a
    psabi level 3 (avx2):                214.9ms
    psabi level 2 (sse4.2):              366.1ms
    psabi level 1 (sse2, no popcnt):     779.0ms
    psabi level 0 (scalar only code):    725.4ms

    intel xeon e5-2687w (sandy bridge ep)
    psabi level 4 (avx512):                  n/a
    psabi level 3 (avx2):               463.09ms
    psabi level 2 (sse4.2):             854.17ms
    psabi level 1 (sse2, no popcnt):   1802.00ms
    psabi level 0 (scalar only code):  1625.00ms

    intel core i5 8250u (kaby lake-r)
    psabi level 4 (avx512):                  n/a
    psabi level 3 (avx2):               389.46ms
    psabi level 2 (sse4.2):             662.00ms
    psabi level 1 (sse2, no popcnt):   1597.75ms
    psabi level 0 (scalar only code):  1378.75ms

    intel core i7 8650u (coffee lake-u/y)
    psabi level 4 (avx512):                 n/a
    psabi level 3 (avx2):              356.27ms
    psabi level 2 (sse4.2):            632.75ms
    psabi level 1 (sse2, no popcnt):  1519.50ms
    psabi level 0 (scalar only code): 1301.00ms

    intel core 2 duo t7700 (merom)
    psabi level 4 (avx512):                 n/a
    psabi level 3 (avx2):                   n/a
    psabi level 2 (sse4.2):                 n/a
    psabi level 1 (sse2, no popcnt):  9187.98ms
    psabi level 0 (scalar only code): 7093.98ms
*/

#include "i_imgutil.h"

typedef struct {
    argb* haystack;         // the haystack image buffer; assumed flat 32-bit RGB or ARGB
    i32   haystack_w;       // width of the image
    i32   haystack_h;       // height of the image
    argb* needle_lo;        // pre-made mask where each each pixel channel is the low value
    argb* needle_hi;        // pre-made mask where each each pixel channel is the high value
    i32   needle_w;         // width of the image
    i32   needle_h;         // height of the image
    i8    pctmatchreq;      // minimum percentage of pixels to match from needle
    i32   force_topleft;    // force top left pixel to match before determining percentages
    i32   needle_pixels;    // number of pixels in the needle
    i32   pixels_needed;    // number of pixels needed to match the percentage
    vec   nl;               // needle low vector
    vec   nh;               // needle high vector
} i_imgsrch_ctx;

/*  important: if we can ensure that needle, needle_lo, needle_hi AND haystack
    are all allocated to a size that is a multiple of the vector size (so 64 bytes 
    covers all of them), then we can simplify the cleanup code in the vector
    loops. pixelmatchcount, pixelscan and make_sat_masks all would benefit from this. */

static inline argb* i_imgutil_imgsrch_haystackline_forcetopleft (
    i_imgsrch_ctx* ctx,     // parameters
    i32*  ppixels_matched,  // optional pointer to store the number of pixels matched)
    i32   haystack_row      // row to start searching from
)
{
    argb* pixels     = ctx->haystack + haystack_row * ctx->haystack_w;
    argb* pixels_max = pixels + ctx->haystack_w - ctx->needle_w;
    while (pixels <= pixels_max) {
        i32 row_pixels_left = (i32)(pixels_max - pixels);
        // allow an extra pixel to the right so a rightmost needle's first column can be found
        argb* pfound = i_imgutil_pixel_scan(pixels, ctx->nl, ctx->nh, row_pixels_left + 1);
        if (pfound) {
            pixels = pfound;
            argb* ptr_needle_lo  = ctx->needle_lo;
            argb* ptr_needle_hi  = ctx->needle_hi;
            argb* inner_haystack = pixels;
            i32   pixels_tomatch = ctx->pixels_needed;
            i32   pixels_left    = ctx->needle_pixels;
            while (pixels_left && pixels_left >= pixels_tomatch) {
                i32 matched     = i_imgutil_pixelmatchcount(&inner_haystack, ctx->needle_w, &ptr_needle_lo, &ptr_needle_hi);
                pixels_tomatch -= matched;
                pixels_left    -= ctx->needle_w;
                inner_haystack += ctx->haystack_w - ctx->needle_w;
            }
            if (pixels_tomatch <= 0) {
                if (ppixels_matched)
                    *ppixels_matched = ctx->pixels_needed - pixels_tomatch;
                return pixels;
            }
            pixels++;
        } else {
            break;
        }
    }
    return 0;
}

static inline argb* i_imgutil_imgsrch_haystackline (
    i_imgsrch_ctx* ctx,     // parameters
    i32*  ppixels_matched,  // optional pointer to store the number of pixels matched)
    i32   haystack_row      // row to start searching from
)
{
    argb* pixels     = ctx->haystack + haystack_row * ctx->haystack_w;
    argb* pixels_max = pixels + ctx->haystack_w - ctx->needle_w;
    while (pixels <= pixels_max) {
        i32 row_pixels_left = (i32)(pixels_max - pixels);
        argb* ptr_needle_lo  = ctx->needle_lo;
        argb* ptr_needle_hi  = ctx->needle_hi;
        argb* inner_haystack = pixels;
        i32   pixels_tomatch = ctx->pixels_needed;
        i32   pixels_left    = ctx->needle_pixels;
        while (pixels_left && pixels_left >= pixels_tomatch) {
            i32 matched     = i_imgutil_pixelmatchcount(&inner_haystack, ctx->needle_w, &ptr_needle_lo, &ptr_needle_hi);
            pixels_tomatch -= matched;
            pixels_left    -= ctx->needle_w;
            inner_haystack += ctx->haystack_w - ctx->needle_w;
        }
        if (pixels_tomatch <= 0) {
            if (ppixels_matched)
                *ppixels_matched = ctx->pixels_needed - pixels_tomatch;
            return pixels;
        }
        pixels++;
    }
}

argb* imgutil_imgsrch (
    argb* haystack,       // the haystack image buffer; assumed flat 32-bit RGB or ARGB
    i32   haystack_w,     // width of the image
    i32   haystack_h,     // height of the image
    argb* needle_lo,      // pre-made mask where each each pixel channel is the low value
    argb* needle_hi,      // pre-made mask where each each pixel channel is the high value
    i32   needle_w,       // width of the image
    i32   needle_h,       // height of the image
    i8    pctmatchreq,    // minimum percentage of pixels to match from needle
    i32   force_topleft,  // force top left pixel to match before determining percentages
    i32*  ppixels_matched // optional pointer to store the number of pixels matched)
)
{
    if (!haystack || !needle_lo || !needle_hi)
        return 0;
    i_imgsrch_ctx ctx       = {
        .haystack           = haystack,
        .haystack_w         = haystack_w,
        .haystack_h         = haystack_h,
        .needle_lo          = needle_lo,
        .needle_hi          = needle_hi,
        .needle_w           = needle_w,
        .needle_h           = needle_h,
        .pctmatchreq        = pctmatchreq,
        .force_topleft      = force_topleft || (pctmatchreq == 100),
        .needle_pixels      = needle_w * needle_h,
        .pixels_needed      = needle_w * needle_h * pctmatchreq / 100,
    };
    if (ctx.force_topleft) {
        //top left pixel from both upper and lower masks into two vectors
        ctx.nl.__mvec = _mvec_set1_epi32(0x00 << 24  | needle_lo[0].r << 16 | needle_lo[0].g << 8 | needle_lo[0].b);
        ctx.nh.__mvec = _mvec_set1_epi32(0xff << 24  | needle_hi[0].r << 16 | needle_hi[0].g << 8 | needle_hi[0].b);
        for (i32 haystack_row = 0; haystack_row <= (haystack_h - needle_h); haystack_row++) {
            argb* result = i_imgutil_imgsrch_haystackline_forcetopleft(&ctx, ppixels_matched, haystack_row);
            if (result)
                return result;
        }
    } else {
        for (i32 haystack_row = 0; haystack_row <= (haystack_h - needle_h); haystack_row++) {
            argb* result = i_imgutil_imgsrch_haystackline(&ctx, ppixels_matched, haystack_row);
            if (result)
                return result;
        }
    }
    return 0;
}
