`include "mem_init.vh"

module PDU_DMEM#(
    parameter               DEPTH               = 12
)(
    input                   [ 0 : 0]            sys_clk,

    input                   [DEPTH - 1 : 0]     interface_addr,
    output          reg     [31 : 0]            interface_rdata,
    input                   [31 : 0]            interface_wdata,
    input                   [ 0 : 0]            interface_we
);

    (* ram_style = "block" *) reg [31 : 0] mem [0 : (1 << DEPTH) - 1];

    initial begin
        $readmemh(`PDU_DMEM_FILE, mem);
    end

    always @(posedge sys_clk) begin
        if (interface_we) begin
            mem[interface_addr] <= interface_wdata;
            interface_rdata <= interface_wdata;
        end
        else begin
            interface_rdata <= mem[interface_addr];
        end
    end

endmodule