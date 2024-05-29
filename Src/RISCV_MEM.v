//under development by Gao HengSiang

module MEM_STAGE #(
    parameter BIT_W = 32
    )(
    input clk,
    input rst_n,
    //PIPELINE INPUT FROM EX/MEM REGISTER
    input [BIT_W-1: 0] alu_result_in,
    input [BIT_W-1: 0] mem_wdata_in,
        //various control signals input
    input memrd_in,
    input memwr_in,
        //transparent
    input [BIT_W-1: 0] PC_plus_4_in,
    input [4: 0] rd_in,
    input mem2reg_in,
    input regwr_in,
    input jump_in,
    
    //PIPELINE OUTPUT TO MEM/WB REGISTER
    output [BIT_W-1: 0] alu_result_out,
    output [BIT_W-1: 0] mem_dat,
        //various control signals output
    output [BIT_W-1: 0] PC_plus_4_out,
    output [4: 0] rd_out,
    output mem2reg_out,
    output regwr_out,
    output jump_out,

    //D_CACHE_INTERFACE, output not register blocked
    input         DCACHE_stall,
    output        DCACHE_ren,
    output        DCACHE_wen,
    output [29:0] DCACHE_addr, //assume word address
    input  [31:0] DCACHE_rdata,
    output [31:0] DCACHE_wdata

);

    //Reg and Wire declaration
    reg [BIT_W-1: 0] PC_plus_4_r, PC_plus_4_w,
                    alu_result_r, alu_result_w,
                    mem_dat_r, mem_dat_w;
    reg [4: 0] rd_r, rd_w;
    reg mem2reg_r, mem2reg_w, 
        regwr_r, regwr_w,
        jump_r, jump_w;

    wire stall;
    //Continuous assignments
    //to dcache interface
    assign DCACHE_ren = memrd_in;
    assign DCACHE_wen = memwr_in;
    assign DCACHE_addr = alu_result_in[31: 2];
    // little endian
    assign DCACHE_wdata = {mem_wdata_in[7:0], mem_wdata_in[15:8], mem_wdata_in[23:16], mem_wdata_in[31:24]};
    assign stall = DCACHE_stall & (mem2reg_in | memwr_in);
    //to pipeline
    assign alu_result_out = alu_result_r;
    assign mem_dat = mem_dat_r;
    assign PC_plus_4_out = PC_plus_4_r;
    assign rd_out = rd_r;
    assign mem2reg_out = mem2reg_r;
    assign regwr_out = regwr_r;
    assign jump_out = jump_r;
    //module instantiantion
    //none

    //Combinational 
    always @(*) begin
        //default
        alu_result_w    = stall? alu_result_r: alu_result_in;
        mem_dat_w       = {DCACHE_rdata[7:0], DCACHE_rdata[15:8], DCACHE_rdata[23:16], DCACHE_rdata[31:24]};
        PC_plus_4_w     = stall? PC_plus_4_r: PC_plus_4_in;
        rd_w            = stall? rd_r: rd_in;
        mem2reg_w       = stall? mem2reg_r: mem2reg_in;
        regwr_w         = stall? regwr_r: regwr_in;
        jump_w          = stall? jump_r: jump_in;
    end

    //Sequential
    always @(posedge clk) begin
        if(!rst_n) begin
            alu_result_r    <= 0;
            mem_dat_r       <= 0;
            PC_plus_4_r     <= 0;
            rd_r            <= 0;
            mem2reg_r       <= 0;
            regwr_r         <= 0;
            jump_r          <= 0;
        end
        else begin
            alu_result_r    <= alu_result_w;
            mem_dat_r       <= mem_dat_w;
            PC_plus_4_r     <= PC_plus_4_w;
            rd_r            <= rd_w;
            mem2reg_r       <= mem2reg_w;
            regwr_r         <= regwr_w;
            jump_r          <= jump_w;
        end
    end
endmodule