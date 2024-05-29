module RISCV_IF(
    input         clk,
    input         rst_n,
    input         stall,
    input         flush,
    input  [1:0]  pc_src,  // pc_src[1] = branch pc_src[0] = jalr || jal
    input  [31:0] pc_branch,
    input  [31:0] pc_j,
//-------ICACHE interface-------
	input  ICACHE_stall,
    input load_use_hazard,
    output ICACHE_ren,
	output ICACHE_wen,
	output [29: 0] ICACHE_addr,
	input  [31: 0] ICACHE_rdata,
    output [31: 0] ICACHE_wdata,
//-------Pipeline Registers-------
    output [31: 0] inst_ppl,
    output [31: 0] pc_ppl,
//--------IF stage PC------------
    output [31:0] PC
);

//-------Pipeline Registers-------
    reg [31:0] pc_ppl_r;
    wire [31: 0] pc_ppl_w;
    reg [31:0] inst_ppl_r;
    wire [31: 0] inst_ppl_w;
//-------Internal Registers-------
    reg [31:0] pc_r, pc_w;
    wire [31:0] pc_p4;

    localparam NOP = 32'h00000013;
    assign pc_p4 = pc_r + 4;

    always @(*) begin:next_pc
        //TODO: evaluate between case and if
        if (pc_src == 2'b01) begin //jal || jalr
            pc_w = pc_j;
        end 
        else if(pc_src == 2'b10) begin
            pc_w = pc_branch;
        end else if (!(load_use_hazard || stall || ICACHE_stall)) begin
            pc_w = pc_p4;
        end else begin
            pc_w = pc_r;
        end
    end

    assign pc_ppl_w = pc_r;
    // convert little-endian to normal packing
    assign inst_ppl_w = {ICACHE_rdata[7:0], ICACHE_rdata[15:8], ICACHE_rdata[23:16], ICACHE_rdata[31:24]};
   
    // output assignment
    assign inst_ppl = inst_ppl_r;
    assign pc_ppl = pc_ppl_r;
    assign PC = pc_r;
    // icache ctrl signal
    assign ICACHE_ren = 1;
    assign ICACHE_wen = 0;
    assign ICACHE_addr = pc_r[31:2];
    assign ICACHE_wdata = 0;
    

    always @(posedge clk) begin
        if (!rst_n) begin
            pc_r <= 0;
            pc_ppl_r <= 0;
            inst_ppl_r <= 0;
        end else begin
            pc_r <= pc_w;
            inst_ppl_r <= (flush || ICACHE_stall) ? NOP : inst_ppl_w;
            pc_ppl_r <= pc_ppl_w;
        end
    end


endmodule