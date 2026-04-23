#include "exception.h"
#include "mmu.h"
#include "uart.h"

void kernel_main(void)
{
    volatile unsigned long *const invalid_addr = (volatile unsigned long *)0x80000000UL;

    exception_init();
    mmu_init();

    uart_puts("mmu on (identity map)\n");
    uart_puts("hello world\n");
    uart_puts("triggering out-of-bounds memory access...\n");

    *invalid_addr = 0xdeadbeefUL;

    uart_puts("unexpected: access succeeded\n");

    for (;;) {
        __asm__ volatile ("wfe");
    }
}
