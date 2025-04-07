#include "cmd.h"
#include "macros.h"
#include "memory.h"
#include "uart_io.h"

int main() {
    while(1) {
        uart_puts("\e[7mPDU > \e[0m");

        Command * cmd = (Command *)malloc(sizeof(Command));

        // read command
        bool commandRead = read_command(cmd);

        // parse and execute
        if(commandRead == false) continue;

        execute_command(cmd);

        free(cmd);
    }
}