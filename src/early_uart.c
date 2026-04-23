#include "early_uart.h"

#define UART0_BASE 0x09000000UL
#define UARTDR     ((volatile unsigned int *)(UART0_BASE + 0x00))
#define UARTFR     ((volatile unsigned int *)(UART0_BASE + 0x18))
#define UARTFR_TXFF (1u << 5)

void early_uart_putc(char ch)
{
    if (ch == '\n') {
        early_uart_putc('\r');
    }

    while ((*UARTFR & UARTFR_TXFF) != 0u) {
    }

    *UARTDR = (unsigned int)ch;
}

void early_uart_puts(const char *s)
{
    while (*s != '\0') {
        early_uart_putc(*s++);
    }
}

void early_uart_put_hex(unsigned long value)
{
    static const char digits[] = "0123456789abcdef";
    int shift;

    early_uart_puts("0x");

    for (shift = (int)(sizeof(unsigned long) * 8U) - 4; shift >= 0; shift -= 4) {
        early_uart_putc(digits[(value >> (unsigned int)shift) & 0xfUL]);
    }
}
