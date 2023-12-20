#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <limits.h>
#include <unistd.h>

#define MARCH_x86_64_v2
#define DEBUG 1
#include "../src/imgutil_all.c"
#include "bmp.c"

int main(int argc, char* argv[])
{
    char* haystack_name = "imgutil_test_haystack_with_needle03.bmp";
    char* needle_name = "imgutil_test_needle03.bmp";

    char cwd[PATH_MAX];
    getcwd(cwd, sizeof(cwd));
    printf("cwd = %s\n", cwd);

    BITMAPINFOHEADER haystack_header;
    BITMAPINFOHEADER needle_header;
    argb* haystack = loadbmp(haystack_name, &haystack_header);
    argb* needle   = loadbmp(needle_name,   &needle_header);
    if (!needle || !haystack) {
        printf("Could not load needle or haystack\n");
        return 1;
    }
    i32 haystack_w = haystack_header.biWidth;
    i32 haystack_h = haystack_header.biHeight;
    i32 needle_w   = needle_header.biWidth;
    i32 needle_h   = needle_header.biHeight;

    argb* needle_lo = (argb*)malloc(needle_w * needle_h * sizeof(argb));
    argb* needle_hi = (argb*)malloc(needle_w * needle_h * sizeof(argb));
    imgutil_make_sat_masks((u32*)needle, needle_w * needle_h, (u32*)needle_lo, (u32*)needle_hi, 8);

    argb* match = imgutil_imgsrch ((argb*)haystack, haystack_w, haystack_h, needle_lo, needle_hi, needle_w, needle_h, 100, 0);
    u64 match_index = ((u64)match - (u64)haystack) / 4;
    printf("match = %p (%d,%d)\n", match, (u32)(match_index % haystack_w), (u32)(match_index / haystack_w));

    free(needle);
    free(haystack);

    return 0;
}