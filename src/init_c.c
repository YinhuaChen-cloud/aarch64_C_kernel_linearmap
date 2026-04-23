#include "exception.h"
#include "mmu.h"
#include "uart.h"

extern void head_jump_to_main(void);

void init_c(void)
{
    volatile unsigned long *const translation_fault_addr = (volatile unsigned long *)0x80000000UL;
    volatile unsigned long *const dram_oob_addr = (volatile unsigned long *)0xa0000000UL;

    exception_init();
    mmu_init();

    uart_puts("mmu on (identity map)\n");
    uart_puts("hello world\n");
    uart_puts("test 1: trigger translation fault at 0x80000000\n");
    *translation_fault_addr = 0xdeadbeefUL;
    uart_puts("returned after test 1\n");

    uart_puts("test 2: trigger DRAM out-of-range access at 0xa0000000\n");
    *dram_oob_addr = 0xcafebabeUL;
    uart_puts("returned after test 2\n");

    head_jump_to_main();

    for (;;) {
        __asm__ volatile ("wfe");
    }
}