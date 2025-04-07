module PDU_BUS (
    input                   [31 : 0]            pdu_iaddr                   ,
    output                  [31 : 0]            pdu_idata                   ,

    input                   [31 : 0]            pdu_daddr                   ,
    input                   [31 : 0]            pdu_dwdata                  ,
    input                   [ 0 : 0]            pdu_dwe                     ,
    output          reg     [31 : 0]            pdu_drdata                  ,

    output                  [31 : 0]            imem_interface_addr         ,
    input                   [31 : 0]            imem_interface_data         ,

    output                  [31 : 0]            dmem_interface_addr         ,    
    input                   [31 : 0]            dmem_interface_rdata        ,
    output                  [31 : 0]            dmem_interface_wdata        ,
    output          reg     [ 0 : 0]            dmem_interface_we           ,

    output                  [31 : 0]            uart_interface_addr         ,
    input                   [31 : 0]            uart_interface_rdata        ,
    output                  [31 : 0]            uart_interface_wdata        ,
    output          reg     [ 0 : 0]            uart_interface_we           ,

    output                  [31 : 0]            cpu_ctrl_interface_addr     ,
    input                   [31 : 0]            cpu_ctrl_interface_rdata    ,
    output                  [31 : 0]            cpu_ctrl_interface_wdata    ,
    output          reg     [ 0 : 0]            cpu_ctrl_interface_we
);

    assign imem_interface_addr = pdu_iaddr;
    assign pdu_idata = imem_interface_data;

    assign dmem_interface_addr      = pdu_daddr - 32'H00004000;
    assign dmem_interface_wdata     = pdu_dwdata;
    assign uart_interface_addr      = pdu_daddr;
    assign uart_interface_wdata     = pdu_dwdata;
    assign cpu_ctrl_interface_addr  = pdu_daddr;
    assign cpu_ctrl_interface_wdata = pdu_dwdata;

    always @(*) begin
        dmem_interface_we = 1'B0;
        uart_interface_we = 1'B0;
        cpu_ctrl_interface_we = 1'B0;
        pdu_drdata = 32'H0;
        if (pdu_daddr >= 32'H00004000 && pdu_daddr < 32'H00008000) begin
            dmem_interface_we = pdu_dwe;
            pdu_drdata = dmem_interface_rdata;
        end
        if (pdu_daddr >= 32'H00008000 && pdu_daddr < 32'H00008100) begin
            uart_interface_we = pdu_dwe;
            pdu_drdata = uart_interface_rdata;
        end 
        if (pdu_daddr >= 32'H00008100 && pdu_daddr < 32'H00008200) begin
            cpu_ctrl_interface_we = pdu_dwe;
            pdu_drdata = cpu_ctrl_interface_rdata;
        end
    end
    
endmodule