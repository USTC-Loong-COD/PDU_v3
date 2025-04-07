#ifndef __UART_IO_H__
#define __UART_IO_H__

#include "macros.h"

void uart_init();

int uart_getc();
void uart_getline(char * _buf, unsigned long _size);
bool uart_get_uint32(unsigned int * _hex);
void uart_putc(int _c);
void uart_puts(char * _s);
void uart_put_uint32_hex(unsigned int _x);
void uart_put_uint32_hex8(unsigned int _x);

#endif // __UART_IO_H__