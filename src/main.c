#include "uart.h"

static const char main_message[] = "hello from main\n";

void main(void)
{
    uart_puts(main_message);

    for (;;) {
        __asm__ volatile ("wfe");
    }
}
