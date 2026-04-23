#ifndef UART_H
#define UART_H

void uart_putc(char ch);
void uart_puts(const char *s);
void uart_put_hex(unsigned long value);

#endif
