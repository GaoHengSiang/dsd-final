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



endmodule