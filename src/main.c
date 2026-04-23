#include "exception.h"
#include "mmu.h"

#define UART0_BASE 0x09000000UL
#define UARTDR     ((volatile unsigned int *)(UART0_BASE + 0x00))
#define UARTFR     ((volatile unsigned int *)(UART0_BASE + 0x18))
#define UARTFR_TXFF (1u << 5)

static void uart_putc(char ch)
{
    if (ch == '\n') {
        uart_putc('\r');
    }

    while ((*UARTFR & UARTFR_TXFF) != 0u) {
    }

    *UARTDR = (unsigned int)ch;
}

static void uart_puts(const char *s)
{
    while (*s != '\0') {
        uart_putc(*s++);
    }
}

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
