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

    
    //PIPELINE OUTPUT TO MEM/WB REGISTER
    output [BIT_W-1: 0] alu_result_out,
    output [BIT_W-1: 0] mem_dat,
        //various control signals output
    output [BIT_W-1: 0] PC_plus_4_out,
    output [4: 0] rd_out,
    output mem2reg_out,
    output regwr_out,

    //D_CACHE_INTERFACE
    input         DCACHE_stall,
    output        DCACHE_ren,
    output        DCACHE_wen,
    output [29:0] DCACHE_addr, //assume word address
    input  [31:0] DCACHE_rdata,
    output [31:0] DCACHE_wdata,

    //I/O FOR STANDALONE MODULES SUCH AS FORWARDING, HAZARD_DETECTION
    output d_cache_stall
);

    //Reg and Wire declaration
    reg [BIT_W-1: 0] PC_plus_4_r, PC_plus_4_w,
                    alu_result_r, alu_result_w,
                    mem_dat_r, mem_dat_w;
    reg [4: 0] rd_r, rd_w;
    reg mem2reg_r, mem2reg_w, 
        regwr_r, regwr_w;

    //Continuous assignments
    //to dcache interface
    assign DCACHE_ren = memrd_in;
    assign DCACHE_wen = memwr_in;
    assign DCACHE_addr = alu_result_in[31: 2];
    assign DCACHE_wdata = mem_wdata_in;

    //to pipeline
    assign alu_result_out = alu_result_r;
    assign mem_dat = mem_dat_r;
    assign PC_plus_4_out = PC_plus_4_r;
    assign rd_out = rd_r;
    assign mem2reg_out = mem2reg_r;
    assign regwr_out = regwr_r;

    //other
    assign d_cache_stall_out = DCACHE_stall;

    //module instantiantion
    //none

    //Combinational 
    always @(*) begin
        //default
        alu_result_w    = DCACHE_stall? alu_result_r: alu_result_in;
        mem_dat_w       = DCACHE_rdata;
        PC_plus_4_w     = DCACHE_stall? PC_plus_4_r: PC_plus_4_in;
        rd_w            = DCACHE_stall? rd_r: rd_in;
        mem2reg_w       = DCACHE_stall? mem2reg_r: mem2reg_in;
        regwr_w         = DCACHE_stall? regwr_r: regwr_in;
    end

    //Sequential
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            alu_result_r    <= 0;
            mem_dat_r       <= 0;
            PC_plus_4_r     <= 0;
            rd_r            <= 0;
            mem2reg_r       <= 0;
            regwr_r         <= 0;
        end
        else begin
            alu_result_r    <= alu_result_w;
            mem_dat_r       <= mem_dat_w;
            PC_plus_4_r     <= PC_plus_4_w;
            rd_r            <= rd_w;
            mem2reg_r       <= mem2reg_w;
            regwr_r         <= regwr_w;
        end
    end
endmodule