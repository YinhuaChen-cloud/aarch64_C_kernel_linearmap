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
    uart_puts("hello world\n");

    for (;;) {
        __asm__ volatile ("wfe");
    }
}
