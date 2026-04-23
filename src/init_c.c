#include "exception.h"
#include "early_uart.h"
#include "mmu.h"

extern void head_jump_to_main(void);

static void jump_to_high_head(void)
{
    __asm__ volatile (
        "ldr x16, =head_jump_to_main\n"
        "blr x16\n"
        :
        :
        : "x16", "x30", "memory");
}

void init_c(void)
{
    volatile unsigned long *const translation_fault_addr = (volatile unsigned long *)0x80000000UL;
    volatile unsigned long *const dram_oob_addr = (volatile unsigned long *)0xa0000000UL;

    exception_init();
    mmu_init();

    early_uart_puts("mmu on (identity map)\n");
    early_uart_puts("hello world\n");
    early_uart_puts("test 1: trigger translation fault at 0x80000000\n");
    *translation_fault_addr = 0xdeadbeefUL;
    early_uart_puts("returned after test 1\n");

    early_uart_puts("test 2: trigger DRAM out-of-range access at 0xa0000000\n");
    *dram_oob_addr = 0xcafebabeUL;
    early_uart_puts("returned after test 2\n");

    jump_to_high_head();

    for (;;) {
        __asm__ volatile ("wfe");
    }
}