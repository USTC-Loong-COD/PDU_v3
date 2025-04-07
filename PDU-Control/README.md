# Commands
- `ri <addr.> [<count> = 1]`: read instructions
- `wi <addr.> [<count> = 1]`: write .
- `rd <addr.> [<count> = 1]`: read datas
- `wd <addr.> [<count> = 1]`: write .
- `rr`: read registers
- `bs <addr.>`: breakpoint set
- `bc <id>`: breakpoint clear
- `bl`: breakpoint list
- `step`: step (inst.'s)
- `run`: run
- `reset`: reset

# Instruction Set

- `lui`
- `addi`
- `add`
- `bne`
- `beq`
- `lw`
- `sw`
- `jalr`
- `jal`

# Address space

- `0x0~0x3FFF`: data memory
- `0x4000-0x43FF`: inst. memory
- `0x4400-0x47FF`: others

# mabi=ilp32