#include <stdio.h>

#if defined(__HEADLESS__)
    #define printf_(a) 0
#else
    #define printf_(a) printf a
#endif

/* =====================================================================================
https://gitlab.com/x86-psABIs/x86-64-ABI/-/blob/master/x86-64-ABI/low-level-sys-info.tex
Baseline            | CMOV cmov
                    | CX8 cmpxchg8b
                    | FPU fld
                    | FXSR fxsave
                    | MMX emms
                    | OSFXSR fxsave
                    | SCE syscall
                    | SSE cvtss2si
                    | SSE2 cvtpi2pd
x86-64-v2           | CMPXCHG16B cmpxchg16b
                    | LAHF - SAHF lahf
                    | POPCNT popcnt
                    | SSE3 addsubpd
                    | SSE4_1 blendpd
                    | SSE4_2 pcmpestri
                    | SSSE3 phaddd
x86-64-v3           | AVX vzeroall
                    | AVX2 vpermd
                    | BMI1 andn
                    | BMI2 bzhi
                    | F16C vcvtph2ps
                    | FMA vfmadd132pd
                    | LZCNT lzcnt
                    | MOVBE movbe
                    | OSXSAVE xgetbv
x86-64-v4           | AVX512F kmovw
                    | AVX512BW vdbpsadbw
                    | AVX512CD vplzcntd
                    | AVX512DQ vpmullq
                    | AVX512VL
====================================================================================== */

typedef enum {
    reg_EAX = 0,
    reg_EBX,
    reg_ECX,
    reg_EDX
} register_idx;

typedef struct {
    #if !defined(__HEADLESS__)
    const char*     feature;
    #endif
    unsigned int    eax_value;
    unsigned int    reg;
    unsigned int    bit;
    unsigned int    psabi_level;
} cpu_feature_info;

/*
https://en.wikipedia.org/wiki/CPUID
https://www.felixcloutier.com/x86/cpuid
https://gcc.gnu.org/git/?p=gcc.git;a=blob;f=gcc/config/i386/cpuid.h
*/

static inline cpu_feature_info* get_feature_info(int idx) {
    // this is tucked into a function so it doesn't get exported
    // into a label in the binary
    static cpu_feature_info cpu_features[] = {
    #if defined(__HEADLESS__)
        // baseline requirements
        {1,          reg_EDX, 1<< 0, 1}, {1,          reg_EDX, 1<< 8, 1},
        {1,          reg_EDX, 1<<11, 1}, {1,          reg_EDX, 1<<15, 1},
        {1,          reg_EDX, 1<<24, 1}, {1,          reg_EDX, 1<<23, 1},
        {1,          reg_EDX, 1<<24, 1}, {1,          reg_EDX, 1<<25, 1},
        {1,          reg_EDX, 1<<26, 1},
        // v2 requirements
        {1,          reg_ECX, 1<< 0, 2}, {1,          reg_ECX, 1<<13, 2},
        {1,          reg_ECX, 1<<19, 2}, {1,          reg_ECX, 1<<20, 2},
        {1,          reg_ECX, 1<<23, 2}, {0x80000001, reg_ECX, 1<< 0, 2},
        // v3 requirements
        {1,          reg_ECX, 1<<12, 3}, {1,          reg_ECX, 1<<22, 3},
        {1,          reg_ECX, 1<<27, 3}, {1,          reg_ECX, 1<<28, 3},
        {1,          reg_ECX, 1<<29, 3}, {0x80000001, reg_ECX, 1<< 5, 3},
        {7,          reg_EBX, 1<< 3, 3}, {7,          reg_EBX, 1<< 5, 3},
        {7,          reg_EBX, 1<< 8, 3},
        // v4 requirements
        {7,          reg_EBX, 1<<16, 4}, {7,          reg_EBX, 1<<17, 4},
        {7,          reg_EBX, 1<<28, 4}, {7,          reg_EBX, 1<<30, 4},
        {7,          reg_EBX, 1<<31, 4},
    #else
        // baseline requirements
        {"FPU",      1,          reg_EDX, 1<< 0, 1},{"CX8",      1,          reg_EDX, 1<< 8, 1},
        {"SCE",      1,          reg_EDX, 1<<11, 1},{"CMOV",     1,          reg_EDX, 1<<15, 1},
        {"OSFXSR",   1,          reg_EDX, 1<<24, 1},{"MMX",      1,          reg_EDX, 1<<23, 1},
        {"FXSR",     1,          reg_EDX, 1<<24, 1},{"SSE",      1,          reg_EDX, 1<<25, 1},
        {"SSE2",     1,          reg_EDX, 1<<26, 1},
        // v2 requirements
        {"SSE3",     1,          reg_ECX, 1<< 0, 2},{"CX16",     1,          reg_ECX, 1<<13, 2},
        {"SSE4_1",   1,          reg_ECX, 1<<19, 2},{"SSE4_2",   1,          reg_ECX, 1<<20, 2},
        {"POPCNT",   1,          reg_ECX, 1<<23, 2},{"LAHF",     0x80000001, reg_ECX, 1<< 0, 2},
        // v3 requirements
        {"FMA",      1,          reg_ECX, 1<<12, 3},{"MOVBE",    1,          reg_ECX, 1<<22, 3},
        {"OSXSAVE",  1,          reg_ECX, 1<<27, 3},{"AVX",      1,          reg_ECX, 1<<28, 3},
        {"F16C",     1,          reg_ECX, 1<<29, 3},{"LZCNT",    0x80000001, reg_ECX, 1<< 5, 3},
        {"BMI1",     7,          reg_EBX, 1<< 3, 3},{"AVX2",     7,          reg_EBX, 1<< 5, 3},
        {"BMI2",     7,          reg_EBX, 1<< 8, 3},
        // v4 requirements
        {"AVX512F",  7,          reg_EBX, 1<<16, 4},{"AVX512DQ", 7,          reg_EBX, 1<<17, 4},
        {"AVX512CD", 7,          reg_EBX, 1<<28, 4},{"AVX512BW", 7,          reg_EBX, 1<<30, 4},
        {"AVX512VL", 7,          reg_EBX, 1<<31, 4},
    //  induce failure when debugging (itanium only flag)
    //  {"NX",       1,              reg_EDX,   1<<20, 2},
    #endif
    };
    if (idx < 0 || idx >= sizeof(cpu_features) / sizeof(cpu_feature_info))
        return 0;
    return &cpu_features[idx];
}    

typedef union {
    struct {
        unsigned  eax;
        unsigned  ebx;
        unsigned  ecx;
        unsigned  edx;
    };
    unsigned int array[4];
} cpuid_output;
