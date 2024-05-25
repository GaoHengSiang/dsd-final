//under development by Gao HengSiang

module MEM_STAGE #(
    parameter BIT_W = 32
    )(
    input clk,
    input rst_n,
    //PIPELINE INPUT FROM EX/MEM REGISTER
    input [BIT_W-1: 0] alu_result_in,
    input [BIT_W-1: 0] second_opr_in,
    input [BIT_W-1: 0] nxPC_in,
        //various control signals input
    input memrd_in,
    input memwr_in,
        //transparent
    input [4: 0] rd_in,
    input mem2reg_in,
    input regwr_in,

    
    //PIPELINE OUTPUT TO MEM/WB REGISTER
    output [BIT_W-1: 0] nx_PC,
    output [BIT_W-1: 0] alu_result_out,
    output [BIT_W-1: 0] mem_dat,
    output [4: 0] rd_out,
        //various control signals output
    output mem2reg_out,
    output regwr_out,

    //D_CACHE_INTERFACE
    input         DCACHE_stall,
    output        DCACHE_ren,
    output        DCACHE_wen,
    output [29:0] DCACHE_addr, //assume word address
    input  [31:0] DCACHE_rdata,
    output [31:0] DCACHE_wdata
    //INPUT FROM STANDALONE MODULES SUCH AS FORWARDING, HAZARD_DETECTION
    //maybe no need because forwarding is already done in ID stage
);

    //Reg and Wire declaration
    reg [BIT_W-1: 0] nx_PC_r, alu_result_r, mem_dat_r;
    reg [4: 0] rd_r;
    reg mem2reg_r, regwr_r;
    reg [BIT_W-1: 0] nx_PC_w, alu_result_w, mem_dat_w;
    reg [4: 0] rd_w;
    reg mem2reg_w, regwr_w;
    //Continuous assignments
    assign //to dcache interface

    //module instantiantion

    //Combinational

    //Sequential
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            nx_PC_r         <= 0;
            alu_result_r    <= 0;
            mem_dat_r       <= 0;
            rd_r            <= 0;
            mem2reg_r       <= 0;
            regwr_r         <= 0;
        end
        else begin
            nx_PC_r         <= nx_PC_w;
            alu_result_r    <= alu_result_w;
            mem_dat_r       <= mem_dat_w;
            rd_r            <= rd_w;
            mem2reg_r       <= mem2reg_w;
            regwr_r         <= regwr_w;
        end
    end
endmodule