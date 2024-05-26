module RISCV_Pipeline(
    input         clk,
    input         rst_n,
//----------I cache interface-------
    input         ICACHE_stall,
    output        ICACHE_ren,
    output        ICACHE_wen,
    output [29:0] ICACHE_addr, //assume word address
    input  [31:0] ICACHE_rdata,
    output [31:0] ICACHE_wdata,
//----------D cache interface-------
    input         DCACHE_stall,
    output        DCACHE_ren,
    output        DCACHE_wen,
    output [29:0] DCACHE_addr, //assume word address
    input  [31:0] DCACHE_rdata,
    output [31:0] DCACHE_wdata,
//--------------PC-----------------
    output [31:0] PC
    );

    // wire and reg
    wire [4:0] ID_regfile_rs1, ID_regfile_rs2;
    wire [31:0] ID_regfile_rs1_data, ID_regfile_rs2_data;

    register_file reg_file(
        .clk(clk),
        .rst_n(rst_n),
        .rs1(ID_regfile_rs1),
        .rs2(ID_regfile_rs2),
        .rd(), //TODO: handle rd from WB stage
        .wen(),
        .wrdata(),
        .rddata1(ID_regfile_rs1_data),
        .rddata2(ID_regfile_rs2_data)
    );
    
endmodule