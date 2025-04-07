#include "abort.h"
#include "uart_io.h"

void abort() {
    uart_puts("PDU aborted.\n\r");
    while(1);
}