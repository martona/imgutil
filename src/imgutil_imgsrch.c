/*
    notes on performance:

    on my xeon gold 6256 (cascade lake), with a 3840x2160 haystack and a 64x64 needle
    located in the bottom right corner of haystack, the following timings were observed 
    on average over 5000 runs:

    psabi level 4 (avx512):              167.2ms
    psabi level 3 (avx2):                297.8ms
    psabi level 2 (sse4.1):              511.0ms
    psabi level 1 (sse2, no popcnt):    1234.4ms
    psabi level 0 (scalar only code):   1078.2ms

    intel core i9 12900h (alder lake), with the same inputs:

    psabi level 4 (avx512):                  n/a
    psabi level 3 (avx2):                214.9ms
    psabi level 2 (sse4.1):              366.1ms
    psabi level 1 (sse2, no popcnt):     779.0ms
    psabi level 0 (scalar only code):    725.4ms

    intel xeon e5-2687w (sandy bridge ep)

    psabi level 4 (avx512):                  n/a
    psabi level 3 (avx2):               463.09ms
    psabi level 2 (sse4.1):             854.17ms
    psabi level 1 (sse2, no popcnt):   1802.00ms
    psabi level 0 (scalar only code):  1625.00ms

    intel core i5 8250u (kaby lake-r, 4 cores):

    psabi level 4 (avx512):                  n/a
    psabi level 3 (avx2):               389.46ms
    psabi level 2 (sse4.1):             662.00ms
    psabi level 1 (sse2, no popcnt):   1597.75ms
    psabi level 0 (scalar only code):  1378.75ms
*/

/*  important: if we can ensure that needle, needle_lo, needle_hi AND haystack
    are all allocated to a size that is a multiple of the vector size (so 64 bytes 
    covers all of them), then we can simplify the cleanup code in the vector
    loops. pixelmatchcount, pixelscan and make_sat_masks all would benefit from this. */

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
    i32 needle_pixels       = needle_w * needle_h;
    i32 pixels_needed       = needle_pixels * pctmatchreq / 100;
    force_topleft           = pctmatchreq == 100 ? 1 : force_topleft;
    //top left pixel from both upper and lower masks into two vectors
    vec nl, nh;
    nl.__mvec = _mvec_set1_epi32(0x00 << 24  | needle_lo[0].r << 16 | needle_lo[0].g << 8 | needle_lo[0].b);
    nh.__mvec = _mvec_set1_epi32(0xff << 24  | needle_hi[0].r << 16 | needle_hi[0].g << 8 | needle_hi[0].b);

    for (i32 haystack_row = 0; haystack_row <= haystack_h - needle_h; haystack_row++) {
        argb* pixels     = haystack + haystack_row * haystack_w;
        argb* pixels_max = pixels + haystack_w - needle_w;
        while (pixels <= pixels_max) {
            i32 row_pixels_left = (i32)(pixels_max - pixels);
            // if we're pixel-matching, allow an extra pixel to the right so a
            // rightmost needle's first column can be found
            argb* pfound = force_topleft ?
                i_imgutil_pixel_scan(pixels, nl, nh, row_pixels_left + 1)
                :
                pixels;
            if (pfound) {
                pixels = pfound;
                #if DEBUG
                // i32 y = haystack_row;
                // i32 x = (i32)(pixels - haystack - haystack_row * haystack_w);
                // printf("pixel found at %d, %d\n", x, y);
                #endif
                argb* ptr_needle_lo  = needle_lo;
                argb* ptr_needle_hi  = needle_hi;
                argb* inner_haystack = pixels;
                i32   pixels_tomatch = pixels_needed;
                i32   pixels_left    = needle_pixels;
                while (pixels_left && pixels_left >= pixels_tomatch) {
                    #if DEBUG
                    i32 needle_y    = (i32)(ptr_needle_lo - needle_lo) / needle_w;
                    #endif
                    i32 matched     = i_imgutil_pixelmatchcount(&inner_haystack, needle_w, &ptr_needle_lo, &ptr_needle_hi);
                    pixels_tomatch -= matched;
                    #if DEBUG
                    // printf("row %d/%d matched %d pixels, need %d more\n", needle_y, needle_h, matched, pixels_tomatch);
                    #endif
                    pixels_left    -= needle_w;
                    inner_haystack += (haystack_w - needle_w);
                }
                if (pixels_tomatch <= 0) {
                    #if DEBUG
                    // printf("found %d pixels out of %d, returning with success\n", pixels_needed, needle_pixels);
                    #endif
                    if (ppixels_matched)
                        *ppixels_matched = pixels_needed - pixels_tomatch;
                    return pixels;
                }
                pixels++;
            } else {
                pixels += haystack_w;
            }
        }
    }
    return 0;
}
