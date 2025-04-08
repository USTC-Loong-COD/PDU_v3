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
// `define INSTRUCTION_SET_LOONGARCH
`define INSTRUCTION_SET_RISCV

// ============================== Step 2 ==============================
// 请将 <your_path_to_workspace> 设定为项目的绝对路径(PDU_v3 所在路径)。例如：
// [vvvvv 仅供示例，请不要直接复制 vvvvv]
// `define PDU_IMEM_FILE "C:/Users/abcde/Desktop/PDU_v3/vsrc/inits/pdu_inits/riscv/pdu_imem.ini"
// [^^^^^ 仅供示例，请不要直接复制 ^^^^^]

`ifdef INSTRUCTION_SET_RISCV
    `define PDU_IMEM_FILE "<your_path_to_workspace>/vsrc/inits/pdu_inits/riscv/pdu_imem.ini"
    `define PDU_DMEM_FILE "<your_path_to_workspace>/vsrc/inits/pdu_inits/riscv/pdu_dmem.ini"
`endif
`ifdef INSTRUCTION_SET_LOONGARCH
    `define PDU_IMEM_FILE "<your_path_to_workspace>/vsrc/inits/pdu_inits/loongarch/pdu_imem.ini"
    `define PDU_DMEM_FILE "<your_path_to_workspace>/vsrc/inits/pdu_inits/loongarch/pdu_dmem.ini"
`endif

`define CPU_IMEM_FILE "C:/Users/19043/Desktop/PDU_v3/vsrc/inits/cpu_inits/cpu_imem.ini"
`define CPU_DMEM_FILE "C:/Users/19043/Desktop/PDU_v3/vsrc/inits/cpu_inits/cpu_dmem.ini"

// ============================== Step 3 ==============================
// If you choose to use FPGAOL, then COMMENT the line below.
// 如果你在 FPGAOL 上使用 PDU v3，请将下面这行代码**注释**

`define PHYSICAL_BOARD
