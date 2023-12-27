/*


*/
#include <emmintrin.h>
#include <immintrin.h>
#include <stdio.h>
#include <time.h>

typedef unsigned long long  u64;
typedef unsigned int        u32;
typedef unsigned short      u16;
typedef unsigned char        u8;
typedef long long           i64;
typedef int                 i32;
typedef short               i16;
typedef char                 i8;

typedef union {
    u32 u32;
    struct {
        u8 b;
        u8 g;
        u8 r;
        u8 a;
    };
} argb;

static inline void blit_line_v3 (argb* d, argb* s, i32 w) {
    i32 vecsize = (sizeof(__m256i) / sizeof(i32));
    while (w >= vecsize) {
        __m256i s256 = _mm256_loadu_si256((__m256i*)s);
        _mm256_storeu_si256((__m256i*)d, s256);
        d += vecsize;
        s += vecsize;
        w -= vecsize;
        asm("");                        // -O3 please
    }
}

static inline void blit_line_v4 (argb* d, argb* s, i32 w) {
    i32 vecsize = (sizeof(__m512i) / sizeof(i32));
    while (w >= vecsize) {
        __m512i s512 = _mm512_loadu_si512((__m512i*)s);
        _mm512_storeu_si512((__m512i*)d, s512);
        d += vecsize;
        s += vecsize;
        w -= vecsize;
        asm("");                        // -O3 please
    }
}

#if defined(MARCH_x86_64_v4)
#define blit_line blit_line_v4
#elif defined(MARCH_x86_64_v3)
#define blit_line blit_line_v3
#else
#error "No implementation for blit_line"
#endif

static void blit (
    argb* dst, i32 dx, i32 dy, i32 dstride,
    argb* src, i32 sx, i32 sy, i32 sstride,
    i32 w, i32 h, i32 i)
{
    argb* d = dst + dy * dstride + dx;
    argb* s = src + sy * sstride + sx;

    for (i32 y = 0; y < h; y++) {
        s[0].u32 = i;                     // -O3 please don't optimize the whole thing away
        blit_line(d, s, w);
        d += dstride;
        s += sstride;
    }
}

int main(int argc, char** argv) {
    i32 w = 3840;
    i32 h = 2160;
    argb* src = malloc(w * h * sizeof(argb));
    argb* dst = malloc(w * h * sizeof(argb));
    clock_t start = clock();
    clock_t total_time = CLOCKS_PER_SEC * 5;
    i32 i = 0;
    while (clock() - start < total_time) {
        blit(dst, 0, 0, w, src, 0, 0, w, w, h, i);
        i++;
    }
    clock_t end = clock();
    printf("%d iterations, %fus per iteration\n", i, (end - start) * 1000 / (double)i);
    return dst[0].u32;                  // -O3 please don't optimize the whole thing away
}
