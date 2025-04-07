`include "mem_init.vh"

module PDU_IMEM#(
    parameter               DEPTH               = 12
)(
    input                   [ 0 : 0]            sys_clk,

    input                   [DEPTH - 1 : 0]     interface_addr,
    output          reg     [31 : 0]            interface_data
);

    (* ram_style = "block" *) reg [31 : 0] mem [0 : (1 << DEPTH) - 1];

    initial begin
        $readmemh(`PDU_IMEM_FILE, mem);
    end

    always @(posedge sys_clk) begin
        interface_data <= mem[interface_addr];
    end

endmodule