#include "uart.h"

#define UART0_BASE 0x09000000UL
#define UARTDR     ((volatile unsigned int *)(UART0_BASE + 0x00))
#define UARTFR     ((volatile unsigned int *)(UART0_BASE + 0x18))
#define UARTFR_TXFF (1u << 5)

void uart_putc(char ch)
{
    if (ch == '\n') {
        uart_putc('\r');
    }

    while ((*UARTFR & UARTFR_TXFF) != 0u) {
    }

    *UARTDR = (unsigned int)ch;
}

void uart_puts(const char *s)
{
    while (*s != '\0') {
        uart_putc(*s++);
    }
}

void uart_put_hex(unsigned long value)
{
    static const char digits[] = "0123456789abcdef";
    int shift;

    uart_puts("0x");

    for (shift = (int)(sizeof(unsigned long) * 8U) - 4; shift >= 0; shift -= 4) {
        uart_putc(digits[(value >> (unsigned int)shift) & 0xfUL]);
    }
}
