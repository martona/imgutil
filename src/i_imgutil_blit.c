#include "i_imgutil.h"

#ifndef _IMGUTIL_BLIT_INCLUDED
#define _IMGUTIL_BLIT_INCLUDED

static inline i32 imgutil_blit_line_v0 (argb* d, argb* s, i32 w) {
    while (w) {
        *d++ = *s++;
        w--;
    }   
    return 1;
}

#if defined(MARCH_x86_64_v1) || defined(MARCH_x86_64_v2) || defined(MARCH_x86_64_v3) || defined(MARCH_x86_64_v4)
static inline void imgutil_blit_line_v12 (argb* d, argb* s, i32 w) {
    i32 vecsize = (sizeof(__m128i) / sizeof(i32));
    while (w >= vecsize) {
        __m128i s128 = _mm_loadu_si128((__m128i*)s);
        _mm_storeu_si128((__m128i*)d, s128);
        d += vecsize;
        s += vecsize;
        w -= vecsize;
    }
    imgutil_blit_line_v0(d, s, w);
}
#endif

#if defined(MARCH_x86_64_v3)
static inline void imgutil_blit_line_v3 (argb* d, argb* s, i32 w) {
    i32 vecsize = (sizeof(__m256i) / sizeof(i32));
    while (w >= vecsize) {
        __m256i s256 = _mm256_loadu_si256((__m256i*)s);
        _mm256_storeu_si256((__m256i*)d, s256);
        d += vecsize;
        s += vecsize;
        w -= vecsize;
    }
    // there are 256-bit masked loads and stores, but they require
    // avx512, so we just fall back to the v12 code
    imgutil_blit_line_v12(d, s, w);
}
#endif

// to me it's very surprising that this is about 20% slower than the v3 code
// on the only system i was able to benchmark it on (xeon gold 6256). 
#if defined(MARCH_x86_64_v4)
static inline void imgutil_blit_line_v4 (argb* d, argb* s, i32 w) {
    i32 vecsize = (sizeof(__m512i) / sizeof(i32));
    while (w >= vecsize) {
        __m512i s512 = _mm512_loadu_si512((__m512i*)s);
        _mm512_storeu_si512((__m512i*)d, s512);
        d += vecsize;
        s += vecsize;
        w -= vecsize;
    }
    if (w) {
        // avx512 masks are awesome
        i16 mask = (1 << w) - 1;
        // neithher masked loads nor masked stores generate faults when
        // "accessing" memory with a 0 corresponding mask bit, which
        // makes this cleanup code very simple
        __m512i s512 = _mm512_maskz_loadu_epi32(_cvtu32_mask16(mask), s);
        _mm512_mask_storeu_epi32(d, _cvtu32_mask16(mask), s512);
    }
}
#endif

#if defined(MARCH_x86_64_v0)
#define imgutil_blit_line imgutil_blit_line_v0
#elif defined(MARCH_x86_64_v1)
#define imgutil_blit_line imgutil_blit_line_v12
#elif defined(MARCH_x86_64_v2)
#define imgutil_blit_line imgutil_blit_line_v12
#elif defined(MARCH_x86_64_v3)
#define imgutil_blit_line imgutil_blit_line_v3
#elif defined(MARCH_x86_64_v4)
#define imgutil_blit_line imgutil_blit_line_v4
#else
#error "No implementation for imgutil_blit_line"
#endif

#endif // _IMGUTIL_BLIT_INCLUDED