#include <stdio.h>

int main()
{
    while(1)
    {
        // As of May 2021, FastModel models activity count for instruction in simple way.
 
        // Instruction with activity count 1
        __asm__ volatile("fmov d0,xzr");
        __asm__ volatile("fmov d1,xzr");
        __asm__ volatile("fmul d2,d0,d1");
        __asm__ volatile("fmov d2,xzr");
  
        __asm__ volatile("fmov d0,xzr");
        __asm__ volatile("fmov d1,xzr");
        __asm__ volatile("fmov d2,xzr");
        __asm__ volatile("fmadd d3,d2,d1,d0");
  
        // Instruction with activity count 2
        __asm__ volatile("ptrue   p0.s, ALL");
        __asm__ volatile("index   z10.s, #10,13");
        __asm__ volatile("index   z11.s, #12,7");
        __asm__ volatile("ucvtf   v10.4s, v10.4s");
        __asm__ volatile("ucvtf   v11.4s, v11.4s");
        __asm__ volatile("fadd v0.4s, v10.4s, v11.4s");
    }
}
