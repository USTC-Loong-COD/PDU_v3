GCC := riscv64-unknown-linux-gnu-gcc
OBJDUMP := riscv64-unknown-linux-gnu-objdump
CFALGS := -march=rv32i -mabi=ilp32 -static -nostdlib -nostartfiles
LDFLAGS := -T linker.ld

SRC_FILES := $(filter-out start.c, $(wildcard *.c))

all: PDU-Control PDU-Control-COE

PDU-Control: $(SRC_FILES) start.c
	$(GCC) $(CFALGS) $(LDFLAGS) -o $@.bin start.c $(SRC_FILES)
	$(OBJDUMP) -alD PDU-Control.bin > PDU-Control.objd
	mv PDU-Control.objd ../vsrc/inits

PDU-Control-COE: PDU-Control
	mkdir -p inits
	python3 elf2coe.py --elf PDU-Control.bin --coe pdu_imem.ini --base 0x00000000 --size 0x4000
	mv pdu_imem.ini inits
	python3 elf2coe.py --elf PDU-Control.bin --coe pdu_dmem.ini --base 0x00004000 --size 0x4000
	mv pdu_dmem.ini inits
