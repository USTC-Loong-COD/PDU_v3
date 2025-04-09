/*
cpu_controller registers list
20240806
==================================================================================================================================================
|Register Name -----------------|Offset(ADDR)---|PDU R&W Mode ------|Connection Type -----------|Description
CORE_BASE                       0x00008100
CORE_COMMAND                    +0x00           Read-write          Local register(One hot)     Command to core
[10 : 0] -> {[10]READ_INSTRUCTION, [9]WRITE_INSTRUCTION, [8]READ_DATA, [7]WRITE_DATA, [6]READ_REGISTER, [5]BREAKPOINT_SET, 
[4]BREAKPOINT_DELETE, [3]BREAKPOINT_LIST, [2]STEP, [1]RUN, [0]RESET}

CORE_ACK                        +0x04           Read-only           Local register(Flag)        1 if command is acknowledged
CORE_INST_ADDR                  +0x10           Read-write          Register to CPU-IMEM        Address to read/write CPU-IMEM
CORE_INST_READ                  +0x14           Read-only           Wire from CPU-IMEM          Data read from CPU-IMEM[CORE_INST_ADDR]
CORE_INST_WRITE                 +0x18           Read-write          Register to CPU-IMEM        Data to write to CPU-IMEM[CORE_INST_ADDR]
CORE_DATA_ADDR                  +0x20           Read-write          Register to CPU-DMEM        Address to read/write CPU-DMEM
CORE_DATA_READ                  +0x24           Read-only           Wire from CPU-DMEM          Data read from CPU-DMEM[CORE_DATA_ADDR]
CORE_DATA_WRITE                 +0x28           Read-write          Register to CPU-DMEM        Data to write to CPU-DMEM[CORE_DATA_ADDR]

CORE_NEW_BREAKPOINT_ADDR        +0x30           Read-write          Local register              Address of the breakpoint to create
CORE_NEW_BREAKPOINT_ID          +0x34           Read-only           Local register              Id of the created breakpoint
CORE_BREAKPOINT_SET             +0x38           Read-only           Local register(Flag)        1 if the breakpoint was created
CORE_DELETE_BREAKPOINT_ID       +0x40           Read-write          Local register              Id of the breakpoint to delete
CORE_DELETE_BREAKPOINT_ADDR     +0x44           Read-only           Local register              Address of the deleted breakpoint
CORE_BREAKPOINT_DELETED         +0x48           Read-only           Local register(Flag)        1 if breakpoint was deleted
CORE_BREAKPOINT_IDS             +0x4C           Read-only           Local register              List of active breakpoints
[7 : 0] -> [ID7, ID6, ID5, ID4, ID3, ID2, ID1, ID0], 1 if the breakpoint is activated

CORE_BREAK                      +0x50           Read-only           Local register              The breakpoint id that was hit, or 8 if halted
CORE_CURRENT_PC                 +0x54           Read-only           Register from CPU-PC        Current program counter
CORE_BREAKPOINT_ADDR0           +0x60           Read-only           Local register              Address of breakpoint 0
...                             ...             ...                 ...                         ...
CORE_BREAKPOINT_ADDR7           +0x7C           Read-only           Local register              Address of breakpoint 7
CORE_REG0                       +0x80           Read-only           Wire from CPU-RF            RegisterFile[0]
...                             ...             ...                 ...                         ...
CORE_REG31                      +0xFC           Read-only           Wire from CPU-RF            RegisterFile[31]
==================================================================================================================================================
*/

module CPU_ctrl (
    input                   [ 0 : 0]            sys_clk             ,
    input                   [ 0 : 0]            sys_rst             ,

    // PDU
    input                   [31 : 0]            interface_addr      ,
    output          reg     [31 : 0]            interface_rdata     ,
    input                   [31 : 0]            interface_wdata     ,
    input                   [ 0 : 0]            interface_we        ,

    // MEM
    output                  [31 : 0]            imem_addr           ,
    output                  [31 : 0]            imem_wdata          ,
    input                   [31 : 0]            imem_rdata          ,
    output          reg     [ 0 : 0]            imem_we             ,

    output                  [31 : 0]            dmem_addr           ,
    output                  [31 : 0]            dmem_wdata          ,
    input                   [31 : 0]            dmem_rdata          ,
    output          reg     [ 0 : 0]            dmem_we             ,

    // With students' CPU
    // Control signals
    output          reg     [ 0 : 0]            cpu_rst             ,
    output          reg     [ 0 : 0]            cpu_global_en       ,

    // Commit signals
    input                   [ 0 : 0]            cpu_commit_en       ,
    input                   [31 : 0]            cpu_commit_pc       ,
    input                   [31 : 0]            cpu_commit_instr    ,
    input                   [ 0 : 0]            cpu_commit_halt     ,

    // RF debug signals
    output                  [ 4 : 0]            cpu_reg_ra          ,
    input                   [31 : 0]            cpu_reg_rd   
);

    localparam CORE_BASE                            = 32'H00008100;
    localparam CORE_COMMAND_OFFSET                  = 8'H00;
    localparam CORE_ACK_OFFSET                      = 8'H04;
    localparam CORE_INST_ADDR_OFFSET                = 8'H10;
    localparam CORE_INST_READ_OFFSET                = 8'H14;
    localparam CORE_INST_WRITE_OFFSET               = 8'H18;
    localparam CORE_DATA_ADDR_OFFSET                = 8'H20;
    localparam CORE_DATA_READ_OFFSET                = 8'H24;
    localparam CORE_DATA_WRITE_OFFSET               = 8'H28;
    localparam CORE_NEW_BREAKPOINT_ADDR_OFFSET      = 8'H30;
    localparam CORE_NEW_BREAKPOINT_ID_OFFSET        = 8'H34;
    localparam CORE_BREAKPOINT_SET_OFFSET           = 8'H38;
    localparam CORE_DELETE_BREAKPOINT_ID_OFFSET     = 8'H40;
    localparam CORE_DELETE_BREAKPOINT_ADDR_OFFSET   = 8'H44;
    localparam CORE_BREAKPOINT_DELETED_OFFSET       = 8'H48;
    localparam CORE_BREAKPOINT_IDS_OFFSET           = 8'H4C;
    localparam CORE_BREAK_OFFSET                    = 8'H50;
    localparam CORE_CURRENT_PC_OFFSET               = 8'H54;
    localparam CORE_BREAKPOINT_ADDR_OFFSET          = 8'H60;
    localparam CORE_REG_OFFSET                      = 8'H80;

/* ------------------------ cpu controller registers ------------------------ */

    reg  [31 : 0] core_command;
    reg  [ 0 : 0] core_ack;
    reg  [31 : 0] core_inst_addr;
    wire [31 : 0] core_inst_read;
    reg  [31 : 0] core_inst_write;
    reg  [31 : 0] core_data_addr;
    wire [31 : 0] core_data_read;
    reg  [31 : 0] core_data_write;
    reg  [31 : 0] core_new_breakpoint_addr;
    reg  [ 2 : 0] core_new_breakpoint_id;
    reg  [ 0 : 0] core_breakpoint_is_set;
    reg  [ 2 : 0] core_delete_breakpoint_id;
    reg  [31 : 0] core_delete_breakpoint_addr;
    reg  [ 0 : 0] core_breakpoint_is_deleted;
    wire [ 7 : 0] core_breakpoint_ids;
    reg  [ 3 : 0] core_break;
    reg  [31 : 0] core_current_pc;
    wire [31 : 0] core_breakpoint_addr;
    wire [31 : 0] core_reg_rd;

    reg  [31 : 0] reg_breakpoint_addr [7 : 0];
    reg  [ 7 : 0] reg_breakpoint_valid;

/* -------------------------------- read data (interface) ------------------------------- */

    always @(*) begin
        if (interface_addr[7 : 0] >= CORE_BREAKPOINT_ADDR_OFFSET && interface_addr[7 : 0] < CORE_REG_OFFSET) begin
            interface_rdata = core_breakpoint_addr;
        end
        else if (interface_addr[7 : 0] >= CORE_REG_OFFSET) begin
            interface_rdata = core_reg_rd;
        end
        else begin
            case(interface_addr[7 : 0])
                CORE_COMMAND_OFFSET:
                    interface_rdata = core_command;
                CORE_ACK_OFFSET:
                    interface_rdata = {31'B0, core_ack};
                CORE_INST_ADDR_OFFSET:
                    interface_rdata = core_inst_addr;
                CORE_INST_READ_OFFSET:
                    interface_rdata = core_inst_read;
                CORE_INST_WRITE_OFFSET:
                    interface_rdata = core_inst_write;
                CORE_DATA_ADDR_OFFSET:
                    interface_rdata = core_data_addr;
                CORE_DATA_READ_OFFSET:
                    interface_rdata = core_data_read;
                CORE_DATA_WRITE_OFFSET:
                    interface_rdata = core_data_write;
                CORE_NEW_BREAKPOINT_ADDR_OFFSET:
                    interface_rdata = core_new_breakpoint_addr;
                CORE_NEW_BREAKPOINT_ID_OFFSET:
                    interface_rdata = {29'B0, core_new_breakpoint_id};
                CORE_BREAKPOINT_SET_OFFSET:
                    interface_rdata = {31'B0, core_breakpoint_is_set};
                CORE_DELETE_BREAKPOINT_ID_OFFSET:
                    interface_rdata = {29'B0, core_delete_breakpoint_id};
                CORE_DELETE_BREAKPOINT_ADDR_OFFSET:
                    interface_rdata = core_delete_breakpoint_addr;
                CORE_BREAKPOINT_DELETED_OFFSET:
                    interface_rdata = {31'B0, core_breakpoint_is_deleted};
                CORE_BREAKPOINT_IDS_OFFSET:
                    interface_rdata = {24'B0, core_breakpoint_ids};
                CORE_BREAK_OFFSET:
                    interface_rdata = {28'B0, core_break};
                CORE_CURRENT_PC_OFFSET:
                    interface_rdata = core_current_pc;
                default:
                    interface_rdata = 32'h0;
            endcase
        end
    end

/* ------------------------------- write data (interface) ------------------------------- */

    always @(posedge sys_clk) begin
        if (sys_rst) begin
            core_command <= 0;
            core_inst_addr <= 0;
            core_inst_write <= 0;
            core_data_addr <= 0;
            core_data_write <= 0;
            core_new_breakpoint_addr <= 0;
            core_delete_breakpoint_id <= 0;
        end
        else if (interface_we) begin
            case(interface_addr[7 : 0])
                CORE_COMMAND_OFFSET:
                    core_command <= {21'B0, interface_wdata[10 : 0]};
                CORE_INST_ADDR_OFFSET:
                    core_inst_addr <= interface_wdata;
                CORE_INST_WRITE_OFFSET:
                    core_inst_write <= interface_wdata;
                CORE_DATA_ADDR_OFFSET:
                    core_data_addr <= interface_wdata;
                CORE_DATA_WRITE_OFFSET:
                    core_data_write <= interface_wdata;
                CORE_NEW_BREAKPOINT_ADDR_OFFSET:
                    core_new_breakpoint_addr <= interface_wdata;
                CORE_DELETE_BREAKPOINT_ID_OFFSET:
                    core_delete_breakpoint_id <= interface_wdata[2 : 0];
                default: ;
            endcase
        end
    end

/* ------------------------------ state machine ----------------------------- */

    integer i;

    localparam STATE_IDLE               = 2'H0;
    localparam STATE_CORE_STEP          = 2'H1;
    localparam STATE_CORE_RUN           = 2'H2;
    localparam STATE_WAIT_ACK           = 2'H3;

    reg [1 : 0] state_current;
    reg [1 : 0] state_next;

    always @(posedge sys_clk) begin
        if (sys_rst) begin
            state_current <= STATE_IDLE;
        end
        else begin
            state_current <= state_next;
        end
    end

    always @(*) begin
        state_next = state_current;
        imem_we = 1'B0;
        dmem_we = 1'B0;
        core_ack = 1'B0;
        cpu_rst = 1'B0;
        cpu_global_en = 1'B0;
        case (state_current)
            STATE_IDLE:
                begin
                    if (core_command[10]) begin                 // READ_INSTRUCTION
                        state_next = STATE_WAIT_ACK;
                    end
                    if (core_command[9]) begin                  // WRITE_INSTRUCTION
                        imem_we = 1'B1;
                        state_next = STATE_WAIT_ACK;
                    end
                    if (core_command[8]) begin                  // READ_DATA
                        state_next = STATE_WAIT_ACK;
                    end
                    if (core_command[7]) begin                  // WRITE_DATA
                        dmem_we = 1'B1;
                        state_next = STATE_WAIT_ACK;
                    end
                    if (core_command[6]) begin                  // READ_REGISTER
                        state_next = STATE_WAIT_ACK;
                    end
                    if (core_command[5]) begin                  // BREAKPOINT_SET
                        state_next = STATE_WAIT_ACK;
                    end
                    if (core_command[4]) begin                  // BREAKPOINT_DELETE
                        state_next = STATE_WAIT_ACK;
                    end
                    if (core_command[3]) begin                  // BREAKPOINT_LIST
                        state_next = STATE_WAIT_ACK;
                    end
                    if (core_command[2]) begin                  // STEP
                        cpu_global_en = 1'B1;
                        state_next = STATE_CORE_STEP;
                    end
                    if (core_command[1]) begin                  // RUN
                        cpu_global_en = 1'B1;
                        state_next = STATE_CORE_RUN;
                    end
                    if (core_command[0]) begin                  // RESET
                        cpu_rst = 1'B1;
                        state_next = STATE_WAIT_ACK;
                    end
                end
            STATE_CORE_STEP:
                begin
                    cpu_global_en = 1'B1;
                    if (cpu_commit_en) begin
                        cpu_global_en = 1'B0;
                        state_next = STATE_WAIT_ACK;
                    end
                end
            STATE_CORE_RUN:
                begin
                    cpu_global_en = 1'B1;
                    if (cpu_commit_en) begin
                        for (i = 0; i < 8; i = i + 1) begin
                            if (cpu_commit_pc == reg_breakpoint_addr[i] && reg_breakpoint_valid[i]) begin
                                cpu_global_en = 1'B0;
                                state_next = STATE_WAIT_ACK;
                            end
                        end
                    end
                    if (cpu_commit_halt) begin
                        cpu_global_en = 1'B0;
                        state_next = STATE_WAIT_ACK;
                    end
                end
            STATE_WAIT_ACK:
                begin
                    core_ack = 1'B1;
                    if (!(|core_command[10 : 0])) begin
                        state_next = STATE_IDLE;
                    end
                end
        endcase
    end

/* ------------------------------ breakpoint ------------------------------- */

    reg [ 2 : 0] new_breakpoint_id;

    always @(*) begin
        new_breakpoint_id = 0;
        for (i = 7; i >= 0; i = i - 1) begin
            if (!reg_breakpoint_valid[i]) begin
                new_breakpoint_id = i[2 : 0];
            end
        end
    end

    always @(posedge sys_clk) begin
        if (sys_rst) begin
            core_new_breakpoint_id <= 0;
            reg_breakpoint_valid <= 0;
            for (i = 0; i < 8; i = i + 1) begin
                reg_breakpoint_addr[i] <= 0;
            end
            core_breakpoint_is_set <= 0;
            core_delete_breakpoint_addr <= 0;
            core_breakpoint_is_deleted <= 0;
        end
        else if (state_current == STATE_IDLE) begin
            if (core_command[5]) begin  // Add breakpoints
                core_new_breakpoint_id <= new_breakpoint_id;
                if (!(&reg_breakpoint_valid)) begin     // Only add breakpoints while the set isn't full
                    reg_breakpoint_valid[new_breakpoint_id] <= 1'B1;
                    reg_breakpoint_addr[new_breakpoint_id] <= core_new_breakpoint_addr;
                    core_breakpoint_is_set <= 1'B1;
                end
                else begin
                    core_breakpoint_is_set <= 1'B0;
                end
            end 
            else if (core_command[4]) begin  // Delete breakpoints
                if (reg_breakpoint_valid[core_delete_breakpoint_id]) begin
                    reg_breakpoint_valid[core_delete_breakpoint_id] <= 1'B0;
                    core_delete_breakpoint_addr <= reg_breakpoint_addr[core_delete_breakpoint_id];
                    core_breakpoint_is_deleted <= 1'B1;
                end
                else begin
                    core_breakpoint_is_deleted <= 1'B0;
                end
            end
        end
    end

/* ------------------------------ basic connect ----------------------------- */

    assign imem_addr = core_inst_addr;
    assign core_inst_read = imem_rdata;
    assign imem_wdata = core_inst_write;
    assign dmem_addr = core_data_addr;
    assign core_data_read = dmem_rdata;
    assign dmem_wdata = core_data_write;
    assign core_breakpoint_addr = reg_breakpoint_addr[interface_addr[4 : 2]];
    assign core_breakpoint_ids = reg_breakpoint_valid;
    assign cpu_reg_ra = interface_addr[6 : 2];
    assign core_reg_rd = cpu_reg_rd;

    reg [ 2 : 0] breakpoint_hit_id;

    always @(posedge sys_clk) begin
        if (sys_rst) begin
            core_current_pc <= 0;
        end
        else if (cpu_commit_en) begin
            core_current_pc <= cpu_commit_pc;
        end
    end

    always @(*) begin
        breakpoint_hit_id = 0;
        for (i = 0; i < 8; i = i + 1) begin
            if (cpu_commit_pc == reg_breakpoint_addr[i] && reg_breakpoint_valid[i]) begin
                breakpoint_hit_id = i[2 : 0];
            end
        end
    end

    always @(posedge sys_clk) begin
        if (sys_rst) begin
            core_break <= 4'H8;
        end
        else if (cpu_commit_halt) begin
            core_break <= 4'H8;
        end
        else if (cpu_commit_en) begin
            core_break <= {1'B0, breakpoint_hit_id};
        end
    end

endmodule