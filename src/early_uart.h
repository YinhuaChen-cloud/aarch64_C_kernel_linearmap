#ifndef EARLY_UART_H
#define EARLY_UART_H

void early_uart_putc(char ch);
void early_uart_puts(const char *s);
void early_uart_put_hex(unsigned long value);

#endif
