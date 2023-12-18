#include <stdio.h>
#include "imgutil_cpuid.h"

//https://stackoverflow.com/questions/6121792/
static inline unsigned int cpuid(cpuid_output* out, unsigned int info_type) {
    __asm__ (
        "cpuid\n"                               // eax = info_type
        : "=a" (out->eax), "=b" (out->ebx), "=c" (out->ecx), "=d" (out->edx) 
        : "a" (info_type), "c" (0)              // info_type is input, and ecx needs to be zero for some info leafs
        : "cc"                                  // clobbered register                     
    );
    return out->eax;                            // Return eax
}

static inline unsigned int cpuid_max_extended() {
    cpuid_output cpuinfo;                       
    cpuid(&cpuinfo, 0x80000000);                // Get max extended function
    return cpuinfo.eax;                         
}

static inline unsigned int cpuid_max_basic() {
    cpuid_output cpuinfo;                       
    cpuid(&cpuinfo, 0);                         // Get max basic function                                
    return cpuinfo.eax;                         
}

static inline unsigned int cpuid_available() {
    // this is probably the most unnecessary 
    // check in the world; checking for cpuid
    // on a 64-bit CPU is really... i don't
    // know what to call it. still, do it 
    // the old way, right?
    unsigned int __eax = 0;
    __asm__  (
        "pushfq\n"                             // Save EFLAGS
        "pushfq\n"                             // Store EFLAGS
        "xorl $0x00200000, (%%esp)\n"          // Invert the ID bit in stored EFLAGS
        "popfq\n"                              // Load stored EFLAGS (with ID bit inverted)
        "pushfq\n"                             // Store EFLAGS again (ID bit may or may not be inverted)
        "popq %%rax\n"                         // eax = modified EFLAGS (ID bit may or may not be inverted)
        "xorl (%%esp), %%eax\n"                // eax = whichever bits were changed
        "popfq\n"                              // Restore original EFLAGS
        "andl $0x00200000, %%eax\n"            // eax = zero if ID bit can't be changed, else non-zero
        : "=a" (__eax)                         // output operands
        :                                      // input operands
        : "cc"                                 // clobbered register
    );
    return __eax != 0;
}

static inline int cpuid_feature_available(int info_type, int reg, int bit) {
    cpuid_output cpuinfo;
    static unsigned int last_info_type = -1;
    if (last_info_type != info_type) {
        cpuid(&cpuinfo, info_type);            
        last_info_type = info_type;
    }
    return (cpuinfo.array[reg] & bit) != 0;           
}

int get_cpu_psabi_level() {

    if (!cpuid_available())
        return 0;

    unsigned int max_basic       = cpuid_max_basic();
    unsigned int max_extended    = cpuid_max_extended();
    
    int level = 0;
    cpu_feature_info* feature = NULL;
    for (int i = 0; feature = get_feature_info(i); i++) {
        if (feature->psabi_level > level) {
            level = feature->psabi_level;
            printf_(("Level %d features:\n", level));
        }
        printf_(("%*s:", 12, feature->feature));
        if (    
                (
                    (feature->eax_value > (unsigned int)0x80000000) && 
                    (max_extended < feature->eax_value)
                ) || (
                    (feature->eax_value < (unsigned int)0x80000000) &&
                    (max_basic < feature->eax_value)
                )
            ) 
        {
            printf_((" can not query\n"));
            return level-1;
        }
        if (!cpuid_feature_available(feature->eax_value, feature->reg, feature->bit)) {
            printf_((" not available\n"));
            return level-1;
        }
        printf_((" OK\n"));
    }
    return level;
}

#if !defined(__HEADLESS__)
int main() {
    printf("CPU PSABI level: %d\n", get_cpu_psabi_level());
    return 0;
}
#endif
