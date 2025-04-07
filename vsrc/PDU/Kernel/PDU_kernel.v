`define PKERNEL_PC_INIT         32'H00000000
`define PKERNEL_STATE_INIT      2'D0
`define PKERNEL_STATE_FETCH     2'D1
`define PKERNEL_STATE_EXEC      2'D2
`define PKERNEL_STATE_WB        2'D3
`define PKERNEL_NPC_ADD4        1'B0
`define PKERNEL_NPC_OFFSET      1'B1
`define PKERNEL_BR_NO           3'D0
`define PKERNEL_BR_BEQ          3'D1
`define PKERNEL_BR_BNE          3'D2
`define PKERNEL_BR_BLT          3'D3
`define PKERNEL_BR_BGE          3'D4
`define PKERNEL_BR_BLTU         3'D5
`define PKERNEL_BR_BGEU         3'D6
`define PKERNEL_BR_JUMP         3'D7
`define PKERNEL_ALU_ADD         4'D0
`define PKERNEL_ALU_SUB         4'D1
`define PKERNEL_ALU_SLT         4'D2
`define PKERNEL_ALU_SLTU        4'D3
`define PKERNEL_ALU_AND         4'D4
`define PKERNEL_ALU_OR          4'D5
`define PKERNEL_ALU_XOR         4'D6
`define PKERNEL_ALU_SLL         4'D7
`define PKERNEL_ALU_SRL         4'D8
`define PKERNEL_ALU_SRA         4'D9
`define PKERNEL_ALU_SRC0_RF     1'B0
`define PKERNEL_ALU_SRC0_PC     1'B1
`define PKERNEL_ALU_SRC1_RF     1'B0
`define PKERNEL_ALU_SRC1_IMM    1'B1
`define PKERNEL_WB_ALU          2'D0
`define PKERNEL_WB_DMEM         2'D1
`define PKERNEL_WB_PCADD4       2'D2
`define PKERNEL_WB_IMM          2'D3

module PDU_kernel (
    input                   [ 0 : 0]            sys_clk,
    input                   [ 0 : 0]            sys_rst,

    output                  [31 : 0]            imem_addr,
    input                   [31 : 0]            imem_rdata,

    output                  [31 : 0]            dmem_addr,
    output                  [31 : 0]            dmem_wdata,
    output                  [ 0 : 0]            dmem_we,
    input                   [31 : 0]            dmem_rdata
);

    reg  [ 1 : 0]           cur_state       ;
    reg  [ 1 : 0]           next_state      ;

    wire [31 : 0]           pc              ;
    wire [31 : 0]           npc             ;
    wire [31 : 0]           pc_offset       ;
    wire [31 : 0]           inst            ;

    wire [ 0 : 0]           dmem_we_raw     ;
    wire [ 4 : 0]           rf_ra0          ;
    wire [ 4 : 0]           rf_ra1          ;
    wire [ 0 : 0]           rf_we           ;
    wire [ 4 : 0]           rf_wa           ;
    wire [ 1 : 0]           wb_mux_sel      ;
    wire [ 2 : 0]           br_type         ;
    wire [ 0 : 0]           alu_src0_sel    ;
    wire [ 0 : 0]           alu_src1_sel    ;
    wire [31 : 0]           imm             ;

    wire [31 : 0]           rf_rd0          ;
    wire [31 : 0]           rf_rd1          ;
    wire [31 : 0]           rf_wd           ;

    wire [31 : 0]           alu_res         ;
    wire [ 3 : 0]           alu_op          ;
    wire [31 : 0]           alu_src0        ;
    wire [31 : 0]           alu_src1        ;

    wire [ 0 : 0]           npc_sel         ;   

    wire [31 : 0]           pc_add4     =   pc + 32'H4;

    always @(posedge sys_clk) begin
        if (sys_rst)
            cur_state <= `PKERNEL_STATE_INIT;
        else
            cur_state <= next_state;
    end

    always @(*) begin
        case (cur_state)
            `PKERNEL_STATE_INIT:
                next_state = `PKERNEL_STATE_FETCH;

            `PKERNEL_STATE_FETCH:
                next_state = `PKERNEL_STATE_EXEC;

            `PKERNEL_STATE_EXEC:
                next_state = `PKERNEL_STATE_WB;

            `PKERNEL_STATE_WB:
                next_state = `PKERNEL_STATE_FETCH;
        endcase
    end

    Pkernel_MUX2 pdu_npc_mux (
        .src0           (pc_add4        ),
        .src1           (pc_offset      ),
        .sel            (npc_sel        ),
        .res            (npc            )
    );

    PKernel_PC pdu_pc (
        .sys_clk        (sys_clk        ),
        .sys_rst        (sys_rst        ),

        .set            (cur_state == `PKERNEL_STATE_INIT),
        .we             (cur_state == `PKERNEL_STATE_WB),

        .npc            (npc            ),
        .pc             (pc             )        
    );

    assign  imem_addr   = pc;
    assign  inst        = imem_rdata;

    PKernel_Decoder pdu_decoder (
        .inst           (inst           ),

        .dmem_we        (dmem_we_raw    ),
        .rf_ra0         (rf_ra0         ),
        .rf_ra1         (rf_ra1         ),
        .rf_we          (rf_we          ),
        .rf_wa          (rf_wa          ),
        .wb_mux_sel     (wb_mux_sel     ),
        .br_type        (br_type        ),
        .alu_op         (alu_op         ),
        .alu_src0_sel   (alu_src0_sel   ),
        .alu_src1_sel   (alu_src1_sel   ),
        .imm            (imm            )
    );

    Pkernel_RegFile pdu_rf (
        .sys_clk        (sys_clk        ),
        .en             (cur_state == `PKERNEL_STATE_WB),

        .rf_ra0         (rf_ra0         ),
        .rf_ra1         (rf_ra1         ),
        .rf_rd0         (rf_rd0         ),
        .rf_rd1         (rf_rd1         ),
        .rf_wa          (rf_wa          ),
        .rf_wd          (rf_wd          ),
        .rf_we          (rf_we          )
    );

    Pkernel_MUX2 pdu_alu_src0_mux (
        .src0           (rf_rd0         ),
        .src1           (pc             ),
        .sel            (alu_src0_sel   ),
        .res            (alu_src0       )
    );

    Pkernel_MUX2 pdu_alu_src1_mux (
        .src0           (rf_rd1         ),
        .src1           (imm            ),
        .sel            (alu_src1_sel   ),
        .res            (alu_src1       )
    );

    Pkernel_ALU pdu_alu (
        .src0           (alu_src0       ),
        .src1           (alu_src1       ),
        .alu_op         (alu_op         ),
        .res            (alu_res        )
    );

    assign pc_offset = alu_res;

    Pkernel_Branch pdu_branch (
        .src0           (rf_rd0         ),
        .src1           (rf_rd1         ),
        .br_type        (br_type        ),
        .npc_sel        (npc_sel        )
    );

    assign  dmem_addr   = alu_res;
    assign  dmem_wdata  = rf_rd1;
    assign  dmem_we     = dmem_we_raw && (cur_state == `PKERNEL_STATE_EXEC);

    Pkernel_MUX4 pdu_wb_mux (
        .src0           (alu_res        ),
        .src1           (dmem_rdata     ),
        .src2           (pc_add4        ),
        .src3           (imm            ),
        .sel            (wb_mux_sel     ),
        .res            (rf_wd          )
    );

endmodule



module PKernel_PC (
    input                   [ 0 : 0]            sys_clk,
    input                   [ 0 : 0]            sys_rst,

    input                   [ 0 : 0]            set,
    input                   [ 0 : 0]            we,

    input                   [31 : 0]            npc,
    output          reg     [31 : 0]            pc
);
    always @(posedge sys_clk) begin
        if (sys_rst)
            pc <= 'B0;
        else if (set)
            pc <= `PKERNEL_PC_INIT;
        else if (we)
            pc <= npc;
    end

endmodule

module PKernel_Decoder(
    input                   [31 : 0]            inst,

    output                  [ 0 : 0]            dmem_we,

    output                  [ 4 : 0]            rf_ra0,
    output                  [ 4 : 0]            rf_ra1,
    output                  [ 0 : 0]            rf_we,
    output                  [ 4 : 0]            rf_wa,

    output          reg     [ 1 : 0]            wb_mux_sel,

    output          reg     [ 2 : 0]            br_type,

    output          reg     [ 3 : 0]            alu_op,
    output          reg     [ 0 : 0]            alu_src0_sel,
    output          reg     [ 0 : 0]            alu_src1_sel,
    
    output          reg     [31 : 0]            imm 
);

    wire [ 0 : 0]  is_OP            ;
    wire [ 0 : 0]  is_OP_IMM        ;
    wire [ 0 : 0]  is_STORE         ;
    wire [ 0 : 0]  is_LOAD          ;
    wire [ 0 : 0]  is_BRANCH        ;
    wire [ 0 : 0]  is_LUI           ; 
    wire [ 0 : 0]  is_AUIPC         ; 
    wire [ 0 : 0]  is_JAL           ; 
    wire [ 0 : 0]  is_JALR          ; 
    wire [ 2 : 0]  func3            ;

    assign is_OP            = ~inst[6] &  inst[5] &  inst[4] & ~inst[3] & ~inst[2];      //  (inst[6:2] == 5'B01100);
    assign is_OP_IMM        = ~inst[6] & ~inst[5] &  inst[4] & ~inst[3] & ~inst[2];      //  (inst[6:2] == 5'B00100); 
    assign is_LOAD          = ~inst[6] & ~inst[5] & ~inst[4] & ~inst[3] & ~inst[2];      //  (inst[6:2] == 5'B00000);
    assign is_STORE         = ~inst[6] &  inst[5] & ~inst[4] & ~inst[3] & ~inst[2];      //  (inst[6:2] == 5'B01000);
    assign is_BRANCH        =  inst[6] &  inst[5] & ~inst[4] & ~inst[3] & ~inst[2];      //  (inst[6:2] == 5'B11000);
    assign is_LUI           = ~inst[6] &  inst[5] &  inst[4] & ~inst[3] &  inst[2];      //  (inst[6:2] == 5'B01101);
    assign is_AUIPC         = ~inst[6] & ~inst[5] &  inst[4] & ~inst[3] &  inst[2];      //  (inst[6:2] == 5'B00101);
    assign is_JAL           =  inst[6] &  inst[5] & ~inst[4] &  inst[3] &  inst[2];      //  (inst[6:2] == 5'B11011);
    assign is_JALR          =  inst[6] &  inst[5] & ~inst[4] & ~inst[3] &  inst[2];      //  (inst[6:2] == 5'B11001);
    assign func3            =  inst[14:12];

    assign rf_ra0           = inst[19 : 15];
    assign rf_ra1           = inst[24 : 20];
    assign rf_wa            = inst[11 :  7];
    assign rf_we            = (|{is_OP , is_OP_IMM, is_LOAD, is_LUI, is_AUIPC, is_JAL, is_JALR});

    assign dmem_we          = is_STORE;

    always @(*) begin
        alu_op = `PKERNEL_ALU_ADD;
        if (is_OP || is_OP_IMM) begin
            case(func3)
                3'B000:
                    if (inst[30] && is_OP)
                        alu_op = `PKERNEL_ALU_SUB;
                    else
                        alu_op = `PKERNEL_ALU_ADD;
                3'B001:
                    alu_op = `PKERNEL_ALU_SLL;
                3'B010:
                    alu_op = `PKERNEL_ALU_SLT;
                3'B011:
                    alu_op = `PKERNEL_ALU_SLTU;
                3'B100:
                    alu_op = `PKERNEL_ALU_XOR;
                3'B101:
                    if (inst[30])
                        alu_op = `PKERNEL_ALU_SRA;
                    else
                        alu_op = `PKERNEL_ALU_SRL;
                3'B110:
                    alu_op = `PKERNEL_ALU_OR;
                3'B111:
                    alu_op = `PKERNEL_ALU_AND;
                default:
                    alu_op = `PKERNEL_ALU_ADD;
            endcase
        end
    end

    always @(*) begin
        if (is_BRANCH || is_AUIPC || is_JAL)
            alu_src0_sel = `PKERNEL_ALU_SRC0_PC;
        else
            alu_src0_sel = `PKERNEL_ALU_SRC0_RF;

        if (is_OP_IMM || is_LOAD || is_STORE || is_BRANCH || is_LUI || is_AUIPC || is_JAL || is_JALR)
            alu_src1_sel = `PKERNEL_ALU_SRC1_IMM;
        else
            alu_src1_sel = `PKERNEL_ALU_SRC1_RF;
    end

    always @(*) begin
        wb_mux_sel = `PKERNEL_WB_ALU;
        if (is_LOAD)
            wb_mux_sel = `PKERNEL_WB_DMEM;
        else if (is_JAL || is_JALR)
            wb_mux_sel = `PKERNEL_WB_PCADD4;
        else if (is_LUI)
            wb_mux_sel = `PKERNEL_WB_IMM;
    end

    always @(*) begin
        if (is_BRANCH)
            case(func3)
                3'B000:
                    br_type = `PKERNEL_BR_BEQ;
                3'B001:
                    br_type = `PKERNEL_BR_BNE;
                3'B100:
                    br_type = `PKERNEL_BR_BLT;
                3'B110:
                    br_type = `PKERNEL_BR_BLTU;
                3'B101:
                    br_type = `PKERNEL_BR_BGE;
                3'B111:
                    br_type = `PKERNEL_BR_BGEU;
                default:
                    br_type = `PKERNEL_BR_NO;
            endcase
        else if (is_JAL || is_JALR)
            br_type = `PKERNEL_BR_JUMP;
        else
            br_type = `PKERNEL_BR_NO;
    end

    always @(*) begin
        imm = 0;
        if (is_BRANCH) begin
            imm = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'B0};
        end
        if (is_LOAD || is_OP_IMM || is_JALR) begin
            imm = {{20{inst[31]}}, inst[31:20]};
        end
        if (is_STORE) begin
            imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};
        end
        if (is_LUI || is_AUIPC) begin
            imm = {inst[31:12], 12'h0};
        end
        if (is_JAL) begin
            imm = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'B0};
        end
    end

endmodule

module Pkernel_ALU (
    input                   [31 : 0]            src0,
    input                   [31 : 0]            src1,
    input                   [ 3 : 0]            alu_op,

    output          reg     [31 : 0]            res
);

    always @(*) begin
        case (alu_op)
            `PKERNEL_ALU_ADD:
                res = src0 + src1;
            `PKERNEL_ALU_SUB:
                res = src0 - src1;
            `PKERNEL_ALU_SLT:
                res = ($signed(src0) < $signed(src1)) ? 32'H1 : 32'H0;
            `PKERNEL_ALU_SLTU:
                res = (src0 < src1) ? 32'H1 : 32'H0;
            `PKERNEL_ALU_AND:
                res = src0 & src1;
            `PKERNEL_ALU_OR:
                res = src0 | src1;
            `PKERNEL_ALU_XOR:
                res = src0 ^ src1;
            `PKERNEL_ALU_SLL:
                res = src0 << src1[ 4 : 0];
            `PKERNEL_ALU_SRL:
                res = src0 >> src1[ 4 : 0];
            `PKERNEL_ALU_SRA:
                res = $signed(src0) >>> src1[ 4 : 0];
            default:
                res = 32'H0;
        endcase
    end

endmodule

module Pkernel_RegFile (
    input                   [ 0 : 0]            sys_clk,
    input                   [ 0 : 0]            en,

    input                   [ 4 : 0]            rf_ra0,
    input                   [ 4 : 0]            rf_ra1,
    output                  [31 : 0]            rf_rd0,
    output                  [31 : 0]            rf_rd1,

    input                   [ 4 : 0]            rf_wa,
    input                   [31 : 0]            rf_wd,
    input                   [ 0 : 0]            rf_we
);

    reg [31 : 0]    reg_file [0 : 31];

    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            reg_file[i] = 0;
    end

    always @(posedge sys_clk) begin
        if (en && rf_we && (|rf_wa))
            reg_file[rf_wa] <= rf_wd;
    end

    assign rf_rd0 = reg_file[rf_ra0];
    assign rf_rd1 = reg_file[rf_ra1];

endmodule

module Pkernel_Branch (
    input                   [31 : 0]            src0,
    input                   [31 : 0]            src1,
    input                   [ 2 : 0]            br_type,            
    output          reg     [ 0 : 0]            npc_sel
);

    always @(*) begin
        npc_sel = `PKERNEL_NPC_ADD4;
        case (br_type)
            `PKERNEL_BR_NO:
                npc_sel = `PKERNEL_NPC_ADD4;
            `PKERNEL_BR_BEQ:
                if (src0 == src1)
                    npc_sel = `PKERNEL_NPC_OFFSET;
            `PKERNEL_BR_BNE:
                if (src0 != src1)
                    npc_sel = `PKERNEL_NPC_OFFSET;
            `PKERNEL_BR_BLT:
                if ($signed(src0) < $signed(src1))
                    npc_sel = `PKERNEL_NPC_OFFSET;
            `PKERNEL_BR_BLTU:
                if (src0 < src1)
                    npc_sel = `PKERNEL_NPC_OFFSET;
            `PKERNEL_BR_BGE:
                if ($signed(src0) >= $signed(src1))
                    npc_sel = `PKERNEL_NPC_OFFSET;
            `PKERNEL_BR_BGEU:
                if (src0 >= src1)
                    npc_sel = `PKERNEL_NPC_OFFSET;
            `PKERNEL_BR_JUMP:
                npc_sel = `PKERNEL_NPC_OFFSET;
        endcase
    end

endmodule

module Pkernel_MUX2 (
    input                   [31 : 0]            src0,
    input                   [31 : 0]            src1,
    input                   [ 0 : 0]            sel,
    output                  [31 : 0]            res
);

    assign  res = sel ? src1 : src0;

endmodule

module Pkernel_MUX4 (
    input                   [31 : 0]            src0,
    input                   [31 : 0]            src1,
    input                   [31 : 0]            src2,
    input                   [31 : 0]            src3,
    input                   [ 1 : 0]            sel,
    output                  [31 : 0]            res
);

    assign res = sel[1] ? (sel[0] ? src3 : src2) : (sel[0] ? src1 : src0);

endmodule