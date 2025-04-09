// ====================================================================
// PDU v3 Basic settings
// PDU v3 基础设置
// Authors: 
//      Entwinedime(TH20030818@mail.ustc.edu.cn)   
//      wintermelon008(jundongw@mail.ustc.edu.cn)
//      
// ====================================================================


// ============================== Step 1 ==============================
// COMMENT ONE of the two lines below.
// 请根据自己使用的指令集注释下面两行中的一行。
// 例如，使用 LA 指令集的需要注释 `define INSTRUCTION_SET_RISCV
//      使用 RV 指令集的需要注释 `define INSTRUCTION_SET_LOONGARCH

`define INSTRUCTION_SET_LOONGARCH
`define INSTRUCTION_SET_RISCV

// ============================== Step 2 ==============================
// 请将 <your_path_to_workspace> 设定为项目的绝对路径(PDU_v3 所在路径)。例如：
// [vvvvv 仅供示例，请不要直接复制 vvvvv]
// `define PDU_IMEM_FILE "C:/Users/abcde/Desktop/PDU_v3/vsrc/inits/pdu_inits/riscv/pdu_imem.ini"
// [^^^^^ 仅供示例，请不要直接复制 ^^^^^]

`ifdef INSTRUCTION_SET_RISCV
`ifndef INSTRUCTION_SET_LOONGARCH
    `define PDU_IMEM_FILE "<your_path_to_workspace>/vsrc/inits/pdu_inits/riscv/pdu_imem.ini"
    `define PDU_DMEM_FILE "<your_path_to_workspace>/vsrc/inits/pdu_inits/riscv/pdu_dmem.ini"
`endif
`endif
`ifdef INSTRUCTION_SET_LOONGARCH
`ifndef INSTRUCTION_SET_RISCV
    `define PDU_IMEM_FILE "<your_path_to_workspace>/vsrc/inits/pdu_inits/loongarch/pdu_imem.ini"
    `define PDU_DMEM_FILE "<your_path_to_workspace>/vsrc/inits/pdu_inits/loongarch/pdu_dmem.ini"
`endif
`endif

`define CPU_IMEM_FILE "<your_path_to_workspace>/vsrc/inits/cpu_inits/instr.ini"
`define CPU_DMEM_FILE "<your_path_to_workspace>/vsrc/inits/cpu_inits/data.ini"

// ============================== Step 3 ==============================
// If you choose to use FPGAOL, then COMMENT the line below.
// 如果你在 FPGAOL 上使用 PDU v3，请将下面这行代码**注释**
// 如果你在物理开发板上使用 PDU v3，请将下面这行代码**取消注释**

// `define PHYSICAL_BOARD

// ============================== Step 4 ==============================
// 依据自己的实际需要设定下面的参数
// CSG324 板子的波特率为 115200，FGG484 板子的波特率为 9600
// 时钟频率为 100MHz

`define UART_CNT_FULL   867
`define UART_CNT_HALF   433  

// =========================== unchangeable ===========================

`ifdef INSTRUCTION_SET_RISCV
`ifndef INSTRUCTION_SET_LOONGARCH
    `define IMEM_START_ADDR 32'H00400000
    `define DMEM_START_ADDR 32'H10010000
`endif
`endif
`ifdef INSTRUCTION_SET_LOONGARCH
`ifndef INSTRUCTION_SET_RISCV
    `define IMEM_START_ADDR 32'H1C000000
    `define DMEM_START_ADDR 32'H1C800000
`endif
`endif