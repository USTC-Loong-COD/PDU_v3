`include "global_config.vh"

module TOP(
    input                   [ 0 : 0]            sys_clk,
    input                   [ 0 : 0]            sys_rst,

    input                   [ 0 : 0]            uart_rxd,
    output                  [ 0 : 0]            uart_txd
);

    wire [31 : 0] pdu_iaddr;
    wire [31 : 0] pdu_idata;

    wire [31 : 0] pdu_daddr;
    wire [31 : 0] pdu_dwdata;
    wire [ 0 : 0] pdu_dwe;
    wire [31 : 0] pdu_drdata;

    wire [31 : 0] imem_interface_addr;
    wire [31 : 0] imem_interface_data;
    wire [31 : 0] dmem_interface_addr;
    wire [31 : 0] dmem_interface_rdata;
    wire [31 : 0] dmem_interface_wdata;
    wire [ 0 : 0] dmem_interface_we;

    wire [31 : 0] uart_interface_addr;
    wire [31 : 0] uart_interface_rdata;
    wire [31 : 0] uart_interface_wdata;
    wire [ 0 : 0] uart_interface_we;

    wire [31 : 0] cpu_ctrl_interface_addr;
    wire [31 : 0] cpu_ctrl_interface_rdata;
    wire [31 : 0] cpu_ctrl_interface_wdata;
    wire [ 0 : 0] cpu_ctrl_interface_we;

    wire [31 : 0] cpu_ctrl_imem_addr;
    wire [31 : 0] cpu_ctrl_imem_rdata;
    wire [31 : 0] cpu_ctrl_imem_wdata;
    wire [ 0 : 0] cpu_ctrl_imem_we;
    wire [31 : 0] cpu_ctrl_dmem_addr;
    wire [31 : 0] cpu_ctrl_dmem_rdata;
    wire [31 : 0] cpu_ctrl_dmem_wdata;
    wire [ 0 : 0] cpu_ctrl_dmem_we;

    wire [ 0 : 0] cpu_rst;
    wire [ 0 : 0] cpu_global_en;
    wire [ 0 : 0] cpu_commit_en;
    wire [31 : 0] cpu_commit_pc;
    wire [31 : 0] cpu_commit_instr;
    wire [ 0 : 0] cpu_commit_halt;
    wire [ 4 : 0] cpu_reg_ra;
    wire [31 : 0] cpu_reg_rd;

    wire [31 : 0] cpu_imem_addr;
    wire [31 : 0] cpu_imem_rdata;
    wire [31 : 0] cpu_dmem_addr;
    wire [31 : 0] cpu_dmem_rdata;
    wire [31 : 0] cpu_dmem_wdata;
    wire [ 0 : 0] cpu_dmem_we;

    wire [31 : 0] imem_addr;
    wire [31 : 0] imem_rdata;
    wire [31 : 0] imem_wdata;
    wire [ 0 : 0] imem_we;
    wire [31 : 0] dmem_addr;
    wire [31 : 0] dmem_rdata;
    wire [31 : 0] dmem_wdata;
    wire [ 0 : 0] dmem_we;

    wire [ 0 : 0] sys_rst_in;

    `ifdef PHYSICAL_BOARD
        assign  sys_rst_in = ~sys_rst;
    `endif
    `ifndef PHYSICAL_BOARD
        assign  sys_rst_in = sys_rst;
    `endif

    PDU_kernel pdu_kernel(
        .sys_clk                        (sys_clk                    ),
        .sys_rst                        (sys_rst_in                 ),

        .imem_addr                      (pdu_iaddr                  ),
        .imem_rdata                     (pdu_idata                  ),

        .dmem_addr                      (pdu_daddr                  ),
        .dmem_wdata                     (pdu_dwdata                 ),
        .dmem_we                        (pdu_dwe                    ),
        .dmem_rdata                     (pdu_drdata                 )
    );

    PDU_BUS pdu_bus(
        .pdu_iaddr                      (pdu_iaddr                  ),
        .pdu_idata                      (pdu_idata                  ),

        .pdu_daddr                      (pdu_daddr                  ),
        .pdu_dwdata                     (pdu_dwdata                 ),
        .pdu_dwe                        (pdu_dwe                    ),
        .pdu_drdata                     (pdu_drdata                 ),

        .imem_interface_addr            (imem_interface_addr        ),
        .imem_interface_data            (imem_interface_data        ),

        .dmem_interface_addr            (dmem_interface_addr        ),
        .dmem_interface_rdata           (dmem_interface_rdata       ),
        .dmem_interface_wdata           (dmem_interface_wdata       ),
        .dmem_interface_we              (dmem_interface_we          ),

        .uart_interface_addr            (uart_interface_addr        ),
        .uart_interface_rdata           (uart_interface_rdata       ),
        .uart_interface_wdata           (uart_interface_wdata       ),
        .uart_interface_we              (uart_interface_we          ),

        .cpu_ctrl_interface_addr        (cpu_ctrl_interface_addr    ),
        .cpu_ctrl_interface_rdata       (cpu_ctrl_interface_rdata   ),
        .cpu_ctrl_interface_wdata       (cpu_ctrl_interface_wdata   ),
        .cpu_ctrl_interface_we          (cpu_ctrl_interface_we      )
    );

    localparam PDU_IMEM_DEPTH = 12;
    localparam PDU_DMEM_DEPTH = 12;

    PDU_IMEM#(
        .DEPTH                          (PDU_IMEM_DEPTH                                 )
    )
    pdu_imem
    (
        .sys_clk                        (sys_clk                                        ),
        .interface_addr                 (imem_interface_addr[PDU_IMEM_DEPTH + 1 : 2]    ),
        .interface_data                 (imem_interface_data                            )
    );

    PDU_DMEM#(
        .DEPTH                          (PDU_DMEM_DEPTH                                 )
    )
    pdu_dmem
    (
        .sys_clk                        (sys_clk                                        ),
        .interface_addr                 (dmem_interface_addr[PDU_DMEM_DEPTH + 1 : 2]    ),
        .interface_rdata                (dmem_interface_rdata                           ),
        .interface_wdata                (dmem_interface_wdata                           ),
        .interface_we                   (dmem_interface_we                              )
    );

    PDU_UART pdu_uart(
        .sys_clk                        (sys_clk                    ),
        .sys_rst                        (sys_rst_in                 ),

        .interface_addr                 (uart_interface_addr        ),
        .interface_rdata                (uart_interface_rdata       ),
        .interface_wdata                (uart_interface_wdata       ),
        .interface_we                   (uart_interface_we          ),

        .uart_rxd                       (uart_rxd                   ),
        .uart_txd                       (uart_txd                   )
    );

    CPU_ctrl cpu_ctrl(
        .sys_clk                        (sys_clk                    ),
        .sys_rst                        (sys_rst_in                 ),

        .interface_addr                 (cpu_ctrl_interface_addr    ),
        .interface_rdata                (cpu_ctrl_interface_rdata   ),
        .interface_wdata                (cpu_ctrl_interface_wdata   ),
        .interface_we                   (cpu_ctrl_interface_we      ),

        .imem_addr                      (cpu_ctrl_imem_addr         ),
        .imem_rdata                     (cpu_ctrl_imem_rdata        ),
        .imem_wdata                     (cpu_ctrl_imem_wdata        ),
        .imem_we                        (cpu_ctrl_imem_we           ),

        .dmem_addr                      (cpu_ctrl_dmem_addr         ),
        .dmem_rdata                     (cpu_ctrl_dmem_rdata        ),
        .dmem_wdata                     (cpu_ctrl_dmem_wdata        ),
        .dmem_we                        (cpu_ctrl_dmem_we           ),

        .cpu_rst                        (cpu_rst                    ),
        .cpu_global_en                  (cpu_global_en              ),
        .cpu_commit_en                  (cpu_commit_en              ),
        .cpu_commit_pc                  (cpu_commit_pc              ),
        .cpu_commit_instr               (cpu_commit_instr           ),
        .cpu_commit_halt                (cpu_commit_halt            ),
        .cpu_reg_ra                     (cpu_reg_ra                 ),
        .cpu_reg_rd                     (cpu_reg_rd                 )
    );

    CPU cpu(
        .clk                            (sys_clk                    ),
        .rst                            (cpu_rst                    ),

        .global_en                      (cpu_global_en              ),
        .imem_raddr                     (cpu_imem_addr              ),
        .imem_rdata                     (cpu_imem_rdata             ),

        .dmem_addr                      (cpu_dmem_addr              ),
        .dmem_rdata                     (cpu_dmem_rdata             ),
        .dmem_wdata                     (cpu_dmem_wdata             ),
        .dmem_we                        (cpu_dmem_we                ),

        .commit                         (cpu_commit_en              ),
        .commit_pc                      (cpu_commit_pc              ),
        .commit_instr                   (cpu_commit_instr           ),
        .commit_halt                    (cpu_commit_halt            ),
        .commit_reg_we                  (                           ),
        .commit_reg_wa                  (                           ),
        .commit_reg_wd                  (                           ),
        .commit_dmem_we                 (                           ),
        .commit_dmem_wa                 (                           ),
        .commit_dmem_wd                 (                           ),

        .debug_reg_ra                   (cpu_reg_ra                 ),
        .debug_reg_rd                   (cpu_reg_rd                 )
    );

    MEM_ARBITER mem_arbiter(
        .cpu_global_en                  (cpu_global_en              ),

        .cpu_imem_addr                  (cpu_imem_addr              ),
        .cpu_imem_rdata                 (cpu_imem_rdata             ),
        .cpu_dmem_addr                  (cpu_dmem_addr              ),
        .cpu_dmem_rdata                 (cpu_dmem_rdata             ),
        .cpu_dmem_wdata                 (cpu_dmem_wdata             ),
        .cpu_dmem_we                    (cpu_dmem_we                ),

        .cpu_ctrl_imem_addr             (cpu_ctrl_imem_addr         ),
        .cpu_ctrl_imem_rdata            (cpu_ctrl_imem_rdata        ),
        .cpu_ctrl_imem_wdata            (cpu_ctrl_imem_wdata        ),
        .cpu_ctrl_imem_we               (cpu_ctrl_imem_we           ),
        .cpu_ctrl_dmem_addr             (cpu_ctrl_dmem_addr         ),
        .cpu_ctrl_dmem_rdata            (cpu_ctrl_dmem_rdata        ),
        .cpu_ctrl_dmem_wdata            (cpu_ctrl_dmem_wdata        ),
        .cpu_ctrl_dmem_we               (cpu_ctrl_dmem_we           ),

        .imem_addr                      (imem_addr                  ),
        .imem_rdata                     (imem_rdata                 ),
        .imem_wdata                     (imem_wdata                 ),
        .imem_we                        (imem_we                    ),
        .dmem_addr                      (dmem_addr                  ),
        .dmem_rdata                     (dmem_rdata                 ),
        .dmem_wdata                     (dmem_wdata                 ),
        .dmem_we                        (dmem_we                    )
    );

    localparam IMEM_DEPTH = 10;
    localparam DMEM_DEPTH = 10;

    IMEM #(
        .DEPTH                          (IMEM_DEPTH                         )
    )
    imem
    (
        .clk                            (sys_clk                            ),
        
        .addr                           (imem_addr[IMEM_DEPTH + 1 : 2]      ),
        .rdata                          (imem_rdata                         ),
        .wdata                          (imem_wdata                         ),
        .we                             (imem_we                            )
    );

    DMEM #(
        .DEPTH                          (DMEM_DEPTH                         )
    )
    dmem
    (
        .clk                            (sys_clk                            ),
        
        .addr                           (dmem_addr[DMEM_DEPTH + 1 : 2]      ),
        .rdata                          (dmem_rdata                         ),
        .wdata                          (dmem_wdata                         ),
        .we                             (dmem_we                            )
    );

endmodule