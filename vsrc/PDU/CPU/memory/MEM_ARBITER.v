module MEM_ARBITER(
    input                   [ 0 : 0]            cpu_global_en       ,

    input                   [31 : 0]            cpu_imem_addr       ,
    output                  [31 : 0]            cpu_imem_rdata      ,
    input                   [31 : 0]            cpu_dmem_addr       ,
    output                  [31 : 0]            cpu_dmem_rdata      ,
    input                   [31 : 0]            cpu_dmem_wdata      ,
    input                   [ 0 : 0]            cpu_dmem_we         ,

    input                   [31 : 0]            cpu_ctrl_imem_addr  ,
    output                  [31 : 0]            cpu_ctrl_imem_rdata ,
    input                   [31 : 0]            cpu_ctrl_imem_wdata ,
    input                   [ 0 : 0]            cpu_ctrl_imem_we    ,
    input                   [31 : 0]            cpu_ctrl_dmem_addr  ,
    output                  [31 : 0]            cpu_ctrl_dmem_rdata ,
    input                   [31 : 0]            cpu_ctrl_dmem_wdata ,
    input                   [ 0 : 0]            cpu_ctrl_dmem_we    ,

    output                  [31 : 0]            imem_addr           ,
    input                   [31 : 0]            imem_rdata          ,
    output                  [31 : 0]            imem_wdata          ,
    output                  [ 0 : 0]            imem_we             ,
    output                  [31 : 0]            dmem_addr           ,
    input                   [31 : 0]            dmem_rdata          ,
    output                  [31 : 0]            dmem_wdata          ,
    output                  [ 0 : 0]            dmem_we
);

    assign imem_addr = cpu_global_en ? cpu_imem_addr : cpu_ctrl_imem_addr;
    assign imem_wdata = cpu_ctrl_imem_wdata;
    assign imem_we = cpu_ctrl_imem_we;
    assign dmem_addr = cpu_global_en ? cpu_dmem_addr : cpu_ctrl_dmem_addr;
    assign dmem_wdata = cpu_global_en ? cpu_dmem_wdata : cpu_ctrl_dmem_wdata;
    assign dmem_we = cpu_global_en ? cpu_dmem_we : cpu_ctrl_dmem_we;

    assign cpu_imem_rdata = imem_rdata;
    assign cpu_dmem_rdata = dmem_rdata;
    assign cpu_ctrl_imem_rdata = imem_rdata;
    assign cpu_ctrl_dmem_rdata = dmem_rdata;

endmodule