#include "char.h"
#include "uart_io.h"
#include "memory.h"
#include "mmap.h"

void uart_init() {
    *UART_TX_DATA_READY = 0;
    *UART_RX_ACK = 0;
}

int uart_getc() {
    while(!*UART_RX_DATA_READY);
    int res = load_byte_volatile(UART_RX_DATA);
    *UART_RX_ACK = 1;
    while(*UART_RX_DATA_READY);
    *UART_RX_ACK = 0;

    uart_putc(res);

    return res;
}

bool uart_get_uint32(unsigned int * _hex) {
    int c;
    while(is_ws(c = uart_getc()));
    if(c == '0' && uart_getc() == 'x') {
        *_hex = 0;
        int count = 0;
        while(count < 8 && is_hex(c = uart_getc())) {
            *_hex <<= 4;
            if(c >= '0' && c <= '9') {
                *_hex += c - '0';
            }
            else if(c >= 'a' && c <= 'f') {
                *_hex += c - 'a' + 10;
            }
            else {
                *_hex += c - 'A' + 10;
            }
            count++;
        }
        if(count == 8 && is_hex(uart_getc())) {
            uart_puts("\n\rNumber out of range of 32-bit unsigned integer\n\r");
            return false;
        }
        return true;
    }
    if(is_digit(c)) {
        *_hex = c - '0';
        while(is_digit(c = uart_getc())) {
            if(*_hex > 429496729 || *_hex == 429496729 && c > '5') {
                uart_puts("\n\rNumber out of range of 32-bit unsigned integer\n\r");
                return false;
            }
            *_hex *= 10;
            *_hex += c - '0';
        }
        return true;
    }
    uart_puts("\n\rUnexpected character: ");
    uart_putc(c);
    uart_puts("\n\r");
    return false;
}

void uart_getline(char * _buf, unsigned long _size) {
    unsigned long i = 0;
    while(i < _size - 1) {
        store_byte(_buf + i, uart_getc());
        if(load_byte(_buf + i) == '\n') {
            store_byte(_buf + i, '\0');
            break;
        }
        i++;
    }
    store_byte(_buf + i, '\0');;
}

void uart_putc(int _c) {
    while(*UART_TX_ACK);
    store_byte_volatile(UART_TX_DATA, _c);
    *UART_TX_DATA_READY = 1;
    while(!*UART_TX_ACK);
    *UART_TX_DATA_READY = 0;
}

void uart_puts(char * _s) {
    while(load_byte(_s)) {
        uart_putc(load_byte(_s));
        _s++;
    }
}

void uart_put_uint32_hex(unsigned int _x) {
    if(_x == 0) {
        uart_putc('0');
        return;
    }
    char buf[8];
    int i = 0;
    while(_x) {
        int temp = _x & 0xF;
        if(temp < 10) {
            store_byte(buf + i, temp + '0');
        }
        else {
            store_byte(buf + i, temp + 'A' - 10);
        }
        _x >>= 4;
        i++;
    }
    while(i) {
        uart_putc(load_byte(buf + --i));
    }
}

void uart_put_uint32_hex8(unsigned int _x) {
    uart_puts("0x");
    char buf[8];
    for(int i = 0; i < 8; i++) {
        store_byte(buf + i, '0');
    }
    int i = 0;
    while(_x) {
        int temp = _x & 0xF;
        if(temp < 10) {
            store_byte(buf + i, temp + '0');
        }
        else {
            store_byte(buf + i, temp + 'A' - 10);
        }
        _x >>= 4;
        i++;
    }
    for(i = 7; i >= 0; i--) {
        uart_putc(load_byte(buf + i));
    }
}