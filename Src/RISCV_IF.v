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
    output ICACHE_ren,
	output ICACHE_wen,
	output ICACHE_addr,
	input  ICACHE_rdata,
    output ICACHE_wdata,
//-------Pipeline Registers-------
    output inst_ppl,
    output [31:0] pc_ppl
);

//-------Pipeline Registers-------
    reg [31:0] pc_ppl_r, pc_ppl_w;
    reg [31:0] inst_ppl_r, inst_ppl_w;
//-------Internal Registers-------
    reg [31:0] pc_r, pc_w;
    wire [31:0] pc_p4;

    localparam NOP = 32'h00000013;
    assign pc_p4 = pc_r + 4;

    always @(*) begin:next_pc
        //TODO: evaluate between case and if
        if (pc_src == 2'b01) begin //jal || jalr
            pc_w = pc_j;
        end else if(pc_src = 2'b10) begin
            pc_w = pc_branch;
        end else begin
            pc_w = pc_p4;
        end
    end

    assign pc_ppl_w = pc_r;
    assign inst_ppl_w = ICACHE_rdata;
   
    // output assignment
    assign inst_ppl = inst_ppl_r;
    assign pc_ppl = pc_ppl_r;
    
    // icache ctrl signal
    assign ICACHE_ren = 1;
    assign ICACHE_wen = 0;
    assign ICACHE_addr = pc_r;
    assign ICACHE_wdata = 0;
    

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_r <= 0;
            pc_ppl_r <= 0;
            inst_ppl_r <= 0;
        end else begin
            pc_r <= (stall || ICACHE_stall) ? pc_r : pc_w;
            inst_ppl_r <= (flush || ICACHE_stall) ? NOP : inst_ppl_w;
            pc_ppl_r <= pc_ppl_w;
        end
    end


endmodule