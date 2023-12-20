
#pragma once
#ifdef __GNUC__
#include <emmintrin.h>
#include <immintrin.h>
#include <x86intrin.h>
#else //assume microsoft
#include <intrin.h>
#endif

#if !defined(MARCH_x86_64_v4) && !defined(MARCH_x86_64_v3) && \
    !defined(MARCH_x86_64_v2) && !defined(MARCH_x86_64_v1) && \
    !defined(MARCH_x86_64_v0)
    #error "MARCH_x86_64_vx not defined"
#endif

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

#ifndef min
#define min(a, b) (a < b ? a : b)
#endif
#ifndef max
#define max(a, b) (a > b ? a : b)
#endif

// this vec union is of the appropriate size based on the MARCH_* definition
// note that V4 code uses V3, V2, and V1, and V3 code uses V2 and V1, etc...
typedef union {
#if defined(MARCH_x86_64_v4)    
    __m512i m512i;
    __m512  m512;
#endif    
#if defined(MARCH_x86_64_v3) || defined(MARCH_x86_64_v4)
    __m256i m256i;
    __m256  m256;
#endif
#if defined(MARCH_x86_64_v1) || defined(MARCH_x86_64_v2) || defined(MARCH_x86_64_v3) || defined(MARCH_x86_64_v4)
    __m128i m128i;
    __m128  m128;
#endif
    argb    margb;
} vec;

// https://stackoverflow.com/questions/32945410/
// some badly needed intrinsics for unsigned 8-bit comparisons
#define _mm_cmpge_epu8(a, b) _mm_cmpeq_epi8(_mm_max_epu8(a, b), a)
#define _mm_cmple_epu8(a, b) _mm_cmpge_epu8(b, a)
#define _mm_cmpgt_epu8(a, b) _mm_xor_si128(_mm_cmple_epu8(a, b), _mm_set1_epi8(-1))
#define _mm_cmplt_epu8(a, b) _mm_cmpgt_epu8(b, a)
// and the avx2 version
#define _mm256_cmpge_epu8(a, b) _mm256_cmpeq_epi8(_mm256_max_epu8(a, b), a)
#define _mm256_cmple_epu8(a, b) _mm256_cmpge_epu8(b, a)
#define _mm256_cmpgt_epu8(a, b) _mm256_xor_si128(_mm256_cmple_epu8(a, b), _mm256_set1_epi8(-1))
#define _mm256_cmplt_epu8(a, b) _mm256_cmpgt_epu8(b, a)

#include "i_imgutil_debruijn.h"

#ifdef __GNUC__
    #if defined(MARCH_x86_64_v4)
    // avx512 and everything else
        #define imgutil_popcount(a) __builtin_popcount(a)
        #define imgutil_ctz16(a)    __builtin_ctzs(a)
        #define imgutil_ctz32(a)    __builtin_ctz(a)
        #define imgutil_ctz64(a)    __builtin_ctzll(a)
        #define imgutil_clz16(a)    __builtin_clzs(a)
        #define imgutil_clz32(a)    __builtin_clz(a)
        #define imgutil_clz64(a)    __builtin_clzll(a)
        //the member of the vec union that is the appropriate size for this MARCH_* definition
        #define __mvec              m512i
        //and the appropriate set1 function to go with it
        #define _mvec_set1_epi32(a) _mm512_set1_epi32(a)
        #define i_imgutil_make_sat_masks    i_imgutil_make_sat_masks_v4
        #define i_imgutil_pixel_scan        i_imgutil_pixel_scan_v4
        #define i_imgutil_pixelmatchcount   i_imgutil_pixelmatchcount_v4
    #elif defined(MARCH_x86_64_v3)
    // AVX2, clz
        #define imgutil_popcount(a) __builtin_popcount(a)
        #define imgutil_ctz16(a)    __builtin_ctzs(a)
        #define imgutil_ctz32(a)    __builtin_ctz(a)
        #define imgutil_ctz64(a)    __builtin_ctzll(a)
        #define imgutil_clz16(a)    __builtin_clzs(a)
        #define imgutil_clz32(a)    __builtin_clz(a)
        #define imgutil_clz64(a)    __builtin_clzll(a)
        #define __mvec              m256i
        #define _mvec_set1_epi32(a) _mm256_set1_epi32(a)
        #define i_imgutil_make_sat_masks    i_imgutil_make_sat_masks_v3
        #define i_imgutil_pixel_scan        i_imgutil_pixel_scan_v3
        #define i_imgutil_pixelmatchcount   i_imgutil_pixelmatchcount_v3
    #elif defined(MARCH_x86_64_v2)
    // SSE4.2 ; we lose clz but bsr is almost as good, popcnt remains
        #define imgutil_popcount(a) __builtin_popcount(a)
        #define imgutil_ctz16(a)    __bsfd(a)
        #define imgutil_ctz32(a)    __bsfd(a)
        #define imgutil_ctz64(a)    __bsfq(a)
        #define imgutil_clz16(a)    (15 -  _bit_scan_reverse(a)  )
        #define imgutil_clz32(a)    (31 -  _bit_scan_reverse(a)  )
        #if defined(__clang__)
            //NOTE: this is hot garbage for an x86_64_v2 processor,
            //but there's no way i'm writing inline assembler.
            //also, thankfully, this isn't used by the current code, for
            //our purposes we only ever need to count leading zeros on 16 bit
            //results at most (avx512 is 16 32-bit pixels wide)
            //still, wtf u doin clang?
            #define imgutil_clz64(a)    (63 - imgutil_bsrDeBruijn64(a)) 
        #else
            #define imgutil_clz64(a)    (63 - __builtin_ia32_bsrdi(a)) 
        #endif
        #define __mvec              m128i
        #define _mvec_set1_epi32(a) _mm_set1_epi32(a)
        #define i_imgutil_make_sat_masks    i_imgutil_make_sat_masks_v12
        #define i_imgutil_pixel_scan        i_imgutil_pixel_scan_v12
        #define i_imgutil_pixelmatchcount   i_imgutil_pixelmatchcount_v12
    #elif defined(MARCH_x86_64_v1)
        // no popcount, no clz, but have bsr and SSE
        #define imgutil_popcount(a) i_imgutil_popcount(a)
        #define imgutil_ctz16(a)    __bsfd(a)
        #define imgutil_ctz32(a)    __bsfd(a)
        #define imgutil_ctz64(a)    __bsfq(a)
        #define imgutil_clz16(a)    (15 -  _bit_scan_reverse(a)  )
        #define imgutil_clz32(a)    (31 -  _bit_scan_reverse(a)  )
        #define imgutil_clz64(a)    (63 - __builtin_ia32_bsrdi(a)) 
        #define __mvec              m128i
        #define _mvec_set1_epi32(a) _mm_set1_epi32(a)
        #define i_imgutil_make_sat_masks    i_imgutil_make_sat_masks_v12
        #define i_imgutil_pixel_scan        i_imgutil_pixel_scan_v12
        #define i_imgutil_pixelmatchcount   i_imgutil_pixelmatchcount_v12
    #elif defined(MARCH_x86_64_v0)
        // scalar only
        #define imgutil_popcount(a) i_imgutil_popcount(a)
        #define imgutil_ctz16(a)    __bsfd(a)
        #define imgutil_ctz32(a)    __bsfd(a)
        #define imgutil_ctz64(a)    __bsfq(a)
        #define imgutil_clz16(a)    (15 - i_imgutil_bsrDeBruijn32(a))
        #define imgutil_clz32(a)    (31 - i_imgutil_bsrDeBruijn32(a))
        #define imgutil_clz64(a)    (63 - i_imgutil_bsrDeBruijn64(a))
        #define __mvec              margb.u32
        #define _mvec_set1_epi32(a) (u32)(a)
        #define i_imgutil_make_sat_masks    i_imgutil_make_sat_masks_v0
        #define i_imgutil_pixel_scan        i_imgutil_pixel_scan_v0
        #define i_imgutil_pixelmatchcount   i_imgutil_pixelmatchcount_v0
    #endif
#else
    // microsoft compiler, probably
    #define imgutil_popcount(a) _mm_popcnt_u32(a)
    #define imgutil_clz16(a)    __lzcnt16(a)
    #define imgutil_clz32(a)    __lzcnt(a)
    #define imgutil_clz64(a)    __lzcnt64(a)
#endif

static inline u32 i_imgutil_popcount(u32 x) {
    x = x - ((x >> 1) & 0x55555555);
    x = (x & 0x33333333) + ((x >> 2) & 0x33333333);
    x = (x + (x >> 4)) & 0x0F0F0F0F;
    x = x + (x >> 8);
    x = x + (x >> 16);
    return x & 0x0000003F;
}

// saturated 8-bit subtraction
static inline u8 subu8(u8 a, u8 b) {
    u8 c = a - b;
    return c & -(u8)(c <= a);
}

// saturated 8-bit addition
static inline u8 addu8(u8 a, u8 b) {
    u8 c = a + b;
    return c | -(u8)(c < a);
}

