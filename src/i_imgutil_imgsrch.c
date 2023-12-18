
#if defined (MARCH_x86_64_v4)
    #define i_imgutil_pixel_scan        i_imgutil_pixel_scan_v4
    #define i_imgutil_pixelmatchcount   i_imgutil_pixelmatchcount_v4
#elif defined (MARCH_x86_64_v3)
    #define i_imgutil_pixel_scan        i_imgutil_pixel_scan_v3
    #define i_imgutil_pixelmatchcount   i_imgutil_pixelmatchcount_v3
#elif defined (MARCH_x86_64_v2)
    #define i_imgutil_pixel_scan        i_imgutil_pixel_scan_v2
    #define i_imgutil_pixelmatchcount   i_imgutil_pixelmatchcount_v2
#elif defined (MARCH_x86_64_v1)
    #define i_imgutil_pixel_scan        i_imgutil_pixel_scan_v1
    #define i_imgutil_pixelmatchcount   i_imgutil_pixelmatchcount_v1
#else
    #error "Error: MARCH_x86_64_vx not defined"
#endif

argb* imgutil_imgsrch (
    argb* haystack,      // the haystack image buffer; assumed flat 32-bit RGB or ARGB
    i32   haystack_w,    // width of the image
    i32   haystack_h,    // height of the image
    argb* needle_lo,     // pre-made mask where each each pixel channel is the low value
    argb* needle_hi,     // pre-made mask where each each pixel channel is the high value
    i32   needle_w,      // width of the image
    i32   needle_h,      // height of the image
    i8    pctmatchreq,   // minimum percentage of pixels to match from needle
    i32   force_topleft) // force top left pixel to match before determining percentages
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
            i32 togo = (i32)(pixels_max - pixels);
            argb* pfound = force_topleft ?
                i_imgutil_pixel_scan(pixels, nl, nh, togo)
                :
                pixels;
            if (pfound) {
                argb* ptr_needle_lo  = needle_lo;
                argb* ptr_needle_hi  = needle_hi;
                argb* inner_haystack = pixels;
                i32   pixels_tomatch = pixels_needed;
                i32   pixels_left    = needle_pixels;
                while (pixels_left >= pixels_tomatch) {
                    pixels_tomatch -= i_imgutil_pixelmatchcount(&inner_haystack, needle_w, &ptr_needle_lo, &ptr_needle_hi);
                    pixels_left -= needle_w;
                    inner_haystack += (haystack_w - needle_w);
                }
                if (pixels_tomatch <= 0)
                    return pixels;
                pixels++;
            } else {
                pixels += haystack_w;
            }
        }
    }
    return 0;
}
