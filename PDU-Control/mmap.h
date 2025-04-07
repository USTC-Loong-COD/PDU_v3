#ifndef __MMAP_H__
#define __MMAP_H__

#define IMEM_BASE 0x00000000
#define IMEM_SIZE 0x00004000
#define DMEM_BASE 0x00004000
#define DMEM_SIZE 0x00008000
#define PERIPH_BASE 0x00008000
#define PERIPH_SIZE 0x00000400

// Data memory
// Stack starts
#define STACK_START 0x00004000
// Stack size
#define STACK_END 0x00006000
// Heap starts
#define HEAP_START 0x00006000
// Heap size
#define HEAP_END 0x00008000

// UART registers
#define UART_BASE 0x00008000
// RX_READY: Read-only, 1 if RX is ready to read, 0 if acked
#define UART_RX_DATA_READY ((volatile unsigned int *)(UART_BASE + 0x00))
// RX_DATA: Read-only, byte received in RX
#define UART_RX_DATA ((volatile unsigned int *)(UART_BASE + 0x04))
// RX_ACK: Read-write, set to 1 to ack, 0 if ack received
#define UART_RX_ACK ((volatile unsigned int *)(UART_BASE + 0x08))
// TX_READY: Read-only, set to 1 to ack, 0 if ack received
#define UART_TX_ACK ((volatile unsigned int *)(UART_BASE + 0x10))
// TX_DATA: Read-write, byte to transmit
#define UART_TX_DATA ((volatile unsigned int *)(UART_BASE + 0x14))
// TX_ACK: Read-write, 1 if data is ready to transmit, 0 if acked
#define UART_TX_DATA_READY ((volatile unsigned int *)(UART_BASE + 0x18))

// Students' core control registers
#define CORE_BASE 0x00008100
// COMMAND: Read-write, command to execute
// [10 : 0] -> {READ_INSTRUCTION, WRITE_INSTRUCTION, READ_DATA, WRITE_DATA, READ_REGISTER, BREAKPOINT_SET, BREAKPOINT_DELETE, BREAKPOINT_LIST, STEP, RUN, RESET}
#define CORE_COMMAND ((volatile unsigned int *)(CORE_BASE + 0x00))
// ACK: Read-only, 1 if command is acked
#define CORE_ACK ((volatile unsigned int *)(CORE_BASE + 0x04))
// INST_ADDR: Read-write, address to read/write instruction
#define CORE_INST_ADDR ((volatile unsigned int *)(CORE_BASE + 0x10))
// INST_READ: Read-only, data read from INST_ADDR
#define CORE_INST_READ ((volatile unsigned int *)(CORE_BASE + 0x14))
// INST_WRITE: Read-write, data to write to INST_ADDR
#define CORE_INST_WRITE ((volatile unsigned int *)(CORE_BASE + 0x18))
// DATA_ADDR: Read-write, address to read/write data
#define CORE_DATA_ADDR ((volatile unsigned int *)(CORE_BASE + 0x20))
// DATA_READ: Read-only, data read from DATA_ADDR
#define CORE_DATA_READ ((volatile unsigned int *)(CORE_BASE + 0x24))
// DATA_WRITE: Read-write, data to write to DATA_ADDR
#define CORE_DATA_WRITE ((volatile unsigned int *)(CORE_BASE + 0x28))
// NEW_BREAKPOINT_ADDRESS: Read-write, address to set breakpoint
#define CORE_NEW_BREAKPOINT_ADDR ((volatile unsigned int *)(CORE_BASE + 0x30))
// NEW_BREAKPOINT_ID: Read-only, id of the new breakpoint
#define CORE_NEW_BREAKPOINT_ID ((volatile unsigned int *)(CORE_BASE + 0x34))
// BREAKPOINT_SET: Read-only, 1 if breakpoint was set
#define CORE_BREAKPOINT_SET ((volatile unsigned int *)(CORE_BASE + 0x38))
// DELETE_BREAKPOINT_ID: Read-write, id of the breakpoint to delete
#define CORE_DELETE_BREAKPOINT_ID ((volatile unsigned int *)(CORE_BASE + 0x40))
// DELETE_BREAKPOINT_ADDRESS: Read-only, address of the deleted breakpoint
#define CORE_DELETE_BREAKPOINT_ADDR ((volatile unsigned int *)(CORE_BASE + 0x44))
// BREAKPOINT_DELETED: Read-only, 1 if breakpoint was deleted
#define CORE_BREAKPOINT_DELETED ((volatile unsigned int *)(CORE_BASE + 0x48))
// BREAKPOINT_IDS: Read-only, list of active breakpoints
// [7 : 0]: [ID7, ID6, ID5, ID4, ID3, ID2, ID1, ID0]
#define CORE_BREAKPOINT_IDS ((volatile unsigned int *)(CORE_BASE + 0x4C))
// BREAK: Read-only, the breakpoint number that was hit, or 8 if halted
#define CORE_BREAK ((volatile unsigned int *)(CORE_BASE + 0x50))
// CURRENT_PC: Read-only, current program counter
#define CORE_CURRENT_PC ((volatile unsigned int *)(CORE_BASE + 0x54))
// BREAKPOINT_ADDRESS0: Read-only, list of active breakpoints
#define CORE_BREAKPOINT_ADDR0 ((volatile unsigned int *)(CORE_BASE + 0x60))
// BREAKPOINT_ADDRESS1: Read-only, list of active breakpoints
#define CORE_BREAKPOINT_ADDR1 ((volatile unsigned int *)(CORE_BASE + 0x64))
// BREAKPOINT_ADDRESS2: Read-only, list of active breakpoints
#define CORE_BREAKPOINT_ADDR2 ((volatile unsigned int *)(CORE_BASE + 0x68))
// BREAKPOINT_ADDRESS3: Read-only, list of active breakpoints
#define CORE_BREAKPOINT_ADDR3 ((volatile unsigned int *)(CORE_BASE + 0x6C))
// BREAKPOINT_ADDRESS4: Read-only, list of active breakpoints
#define CORE_BREAKPOINT_ADDR4 ((volatile unsigned int *)(CORE_BASE + 0x70))
// BREAKPOINT_ADDRESS5: Read-only, list of active breakpoints
#define CORE_BREAKPOINT_ADDR5 ((volatile unsigned int *)(CORE_BASE + 0x74))
// BREAKPOINT_ADDRESS6: Read-only, list of active breakpoints
#define CORE_BREAKPOINT_ADDR6 ((volatile unsigned int *)(CORE_BASE + 0x78))
// BREAKPOINT_ADDRESS7: Read-only, list of active breakpoints
#define CORE_BREAKPOINT_ADDR7 ((volatile unsigned int *)(CORE_BASE + 0x7C))
// REG0: Read-only, register 0
#define CORE_REG0 ((volatile unsigned int *)(CORE_BASE + 0x80))
// REG1: Read-only, register 1
#define CORE_REG1 ((volatile unsigned int *)(CORE_BASE + 0x84))
// REG2: Read-only, register 2
#define CORE_REG2 ((volatile unsigned int *)(CORE_BASE + 0x88))
// REG3: Read-only, register 3
#define CORE_REG3 ((volatile unsigned int *)(CORE_BASE + 0x8C))
// REG4: Read-only, register 4
#define CORE_REG4 ((volatile unsigned int *)(CORE_BASE + 0x90))
// REG5: Read-only, register 5
#define CORE_REG5 ((volatile unsigned int *)(CORE_BASE + 0x94))
// REG6: Read-only, register 6
#define CORE_REG6 ((volatile unsigned int *)(CORE_BASE + 0x98))
// REG7: Read-only, register 7
#define CORE_REG7 ((volatile unsigned int *)(CORE_BASE + 0x9C))
// REG8: Read-only, register 8
#define CORE_REG8 ((volatile unsigned int *)(CORE_BASE + 0xA0))
// REG9: Read-only, register 9
#define CORE_REG9 ((volatile unsigned int *)(CORE_BASE + 0xA4))
// REG10: Read-only, register 10
#define CORE_REG10 ((volatile unsigned int *)(CORE_BASE + 0xA8))
// REG11: Read-only, register 11
#define CORE_REG11 ((volatile unsigned int *)(CORE_BASE + 0xAC))
// REG12: Read-only, register 12
#define CORE_REG12 ((volatile unsigned int *)(CORE_BASE + 0xB0))
// REG13: Read-only, register 13
#define CORE_REG13 ((volatile unsigned int *)(CORE_BASE + 0xB4))
// REG14: Read-only, register 14
#define CORE_REG14 ((volatile unsigned int *)(CORE_BASE + 0xB8))
// REG15: Read-only, register 15
#define CORE_REG15 ((volatile unsigned int *)(CORE_BASE + 0xBC))
// REG16: Read-only, register 16
#define CORE_REG16 ((volatile unsigned int *)(CORE_BASE + 0xC0))
// REG17: Read-only, register 17
#define CORE_REG17 ((volatile unsigned int *)(CORE_BASE + 0xC4))
// REG18: Read-only, register 18
#define CORE_REG18 ((volatile unsigned int *)(CORE_BASE + 0xC8))
// REG19: Read-only, register 19
#define CORE_REG19 ((volatile unsigned int *)(CORE_BASE + 0xCC))
// REG20: Read-only, register 20
#define CORE_REG20 ((volatile unsigned int *)(CORE_BASE + 0xD0))
// REG21: Read-only, register 21
#define CORE_REG21 ((volatile unsigned int *)(CORE_BASE + 0xD4))
// REG22: Read-only, register 22
#define CORE_REG22 ((volatile unsigned int *)(CORE_BASE + 0xD8))
// REG23: Read-only, register 23
#define CORE_REG23 ((volatile unsigned int *)(CORE_BASE + 0xDC))
// REG24: Read-only, register 24
#define CORE_REG24 ((volatile unsigned int *)(CORE_BASE + 0xE0))
// REG25: Read-only, register 25
#define CORE_REG25 ((volatile unsigned int *)(CORE_BASE + 0xE4))
// REG26: Read-only, register 26
#define CORE_REG26 ((volatile unsigned int *)(CORE_BASE + 0xE8))
// REG27: Read-only, register 27
#define CORE_REG27 ((volatile unsigned int *)(CORE_BASE + 0xEC))
// REG28: Read-only, register 28
#define CORE_REG28 ((volatile unsigned int *)(CORE_BASE + 0xF0))
// REG29: Read-only, register 29
#define CORE_REG29 ((volatile unsigned int *)(CORE_BASE + 0xF4))
// REG30: Read-only, register 30
#define CORE_REG30 ((volatile unsigned int *)(CORE_BASE + 0xF8))
// REG31: Read-only, register 31
#define CORE_REG31 ((volatile unsigned int *)(CORE_BASE + 0xFC))

// Strudents' core address space
#define CORE_IMEM_START 0x00400000
#define CORE_IMEM_END 0x00400800
#define CORE_DMEM_START 0x10010000
#define CORE_DMEM_END 0x10010800

// commands
#define COMMAND_NONE ((unsigned int)0)
#define COMMAND_READ_INSTRUCTION ((unsigned int)(1 << 10))
#define COMMAND_WRITE_INSTRUCTION ((unsigned int)(1 << 9))
#define COMMAND_READ_DATA ((unsigned int)(1 << 8))
#define COMMAND_WRITE_DATA ((unsigned int)(1 << 7))
#define COMMAND_READ_REGISTER ((unsigned int)(1 << 6))
#define COMMAND_BREAKPOINT_SET ((unsigned int)(1 << 5))
#define COMMAND_BREAKPOINT_DELETE ((unsigned int)(1 << 4))
#define COMMAND_BREAKPOINT_LIST ((unsigned int)(1 << 3))
#define COMMAND_STEP ((unsigned int)(1 << 2))
#define COMMAND_RUN ((unsigned int)(1 << 1))
#define COMMAND_RESET ((unsigned int)(1 << 0))

#endif // __MMAP_H__