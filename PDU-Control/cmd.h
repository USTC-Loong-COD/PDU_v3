#ifndef __CMD_H__
#define __CMD_H__

#include "macros.h"

typedef enum {
    READ_INSTRUCTION,
    WRITE_INSTRUCTION,
    READ_DATA,
    WRITE_DATA,
    READ_REGISTER,
    BREAKPOINT_SET,
    BREAKPOINT_DELETE,
    BREAKPOINT_LIST,
    STEP,
    RUN,
    RESET,
    NONE
} CommandName;

typedef struct {
    CommandName __cmdName;
    unsigned int __args[2];
} Command;

bool read_command(Command * _cmd);
void execute_command(Command * _cmd);

void read_instruction(unsigned int _addr, unsigned int _count);
void write_instruction(unsigned int _addr, unsigned int _count);
void read_data(unsigned int _addr, unsigned int _count);
void write_data(unsigned int _addr, unsigned int _count);
void read_register();
void breakpoint_set(unsigned int _addr);
void breakpoint_delete(unsigned int _id);
void breakpoint_list();
void step(unsigned int _count);
void run();
void reset();

#endif // __CMD_H__