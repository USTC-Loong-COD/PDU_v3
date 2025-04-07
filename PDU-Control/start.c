#include "mmap.h"

#define STR(x) #x
#define XSTR(x) STR(x)

extern void memory_init();
extern void uart_init();
extern int main();

[[gnu::naked]] void start() {
    // initialize sp: 0x800
    __asm__ volatile("li sp, " XSTR(STACK_END));

    // initialize memory
    __asm__ volatile("call memory_init");
    __asm__ volatile("call uart_init");

    // call main
    __asm__ volatile("call main");
}
