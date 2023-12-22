#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <limits.h>

#define MARCH_x86_64_v0
#define DEBUG 1
#include "../src/imgutil_all.c"
#include "../submodules/leanloader/leanloader.c"
#include "../submodules/multithread/multithread.c"

int main(int argc, char* argv[])
{
    leanloader_image_info haystack_info;
    leanloader_image_info needle_info;
    haystack_info.name = u"imgutil_test_haystack_with_needle01.png";
    needle_info.name   = u"imgutil_test_needle01.png";

    if (!leanloader_load(&haystack_info) || !leanloader_load(&needle_info)) {
        printf("Could not load needle or haystack\n");
        return 1;
    }

    u32 needle_size = needle_info.bd.w * needle_info.bd.h;
    argb* needle_lo = (argb*)malloc((needle_size * sizeof(argb) + 63)  & ~63);
    argb* needle_hi = (argb*)malloc((needle_size * sizeof(argb) + 63)  & ~63);

    imgutil_make_sat_masks((u32*)needle_info.bd.ptr, needle_size, (u32*)needle_lo, (u32*)needle_hi, 8);

    mt_ctx* ctx = mt_init_ctx(0);
    int pixels_matched = 0;
    argb* match = imgutil_imgsrch_multi ( ctx,
                                          (argb*)haystack_info.bd.ptr, haystack_info.bd.w, haystack_info.bd.h,
                                          needle_lo, 
                                          needle_hi, 
                                          needle_info.bd.w, needle_info.bd.h, 
                                          95, 1, &pixels_matched);
    u64 match_index = ((u64)match - (u64)haystack_info.bd.ptr) / 4;
    printf("match = %p (%d,%d)\n", match, (u32)(match_index % haystack_info.bd.w), (u32)(match_index / haystack_info.bd.w));
    free(needle_lo);
    free(needle_hi);
    
    mt_deinit_ctx(ctx);

    leanloader_dispose(&haystack_info);
    leanloader_dispose(&needle_info);

    return 0;
}