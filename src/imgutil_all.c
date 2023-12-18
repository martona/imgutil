#include "i_imgutil.h"

// include every implementation file so we can produce a single object file
#include "imgutil_various.c"
#include "i_imgutil_make_sat_masks.c"
#include "i_imgutil_pixelmatchcount.c"
#include "i_imgutil_pixelscan.c"
#include "i_imgutil_imgsrch.c"

// an exported function to allow the caller to verify that this object file
// contains the correct psabi level implementation
u32 get_blob_psabi_level() {
    if (sizeof(vec) == sizeof(__m512i))
        return 4;
    if (sizeof(vec) == sizeof(__m256i))
        return 3;
    if (sizeof(vec) == sizeof(__m128i))    
        return 2;
    if (sizeof(vec) == sizeof(argb))
        return 1;
    return 0;
}
