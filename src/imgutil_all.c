#include "i_imgutil.h"

// include every implementation file so we can produce a single object file
#include "imgutil_various.c"
#include "i_imgutil_make_sat_masks.c"
#include "i_imgutil_pixelmatchcount.c"
#include "i_imgutil_pixelscan.c"
#include "i_imgutil_imgsrch.c"
#include "i_imgutil_imgsrch_multi.c"
#include "i_imgutil_blit.c"

// an exported function to allow the caller to verify that this object file
// contains the correct psabi level implementation
u32 get_blob_psabi_level() {
    #if   defined(MARCH_x86_64_v4)
        return 4;
    #elif defined(MARCH_x86_64_v3)
        return 3;
    #elif defined(MARCH_x86_64_v2)  
        return 2;
    #elif defined(MARCH_x86_64_v1)  
        return 1;
    #elif defined(MARCH_x86_64_v0)
        return 0;
    #endif
}
