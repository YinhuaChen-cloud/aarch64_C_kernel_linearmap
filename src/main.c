#include "uart.h"

void main(void)
{
    uart_puts("hello from main\n");

    for (;;) {
        __asm__ volatile ("wfe");
    }
}
