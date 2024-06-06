module RISCV_IF(
    input         clk,
    input         rst_n,
    input         stall,
    input         flush,
    input  [1:0]  pc_src,  // pc_src[1] = branch pc_src[0] = jalr || jal TODO: compress it to 1 bit
    input  [31:0] pc_branch,
    input  [31:0] pc_j,
//-------ICACHE-interface-------
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
    output         compressed_ppl,
//--------IF stage PC------------
    output [31:0] PC
);

//-------Pipeline Registers-------
    reg [31:0] pc_ppl_r;
    wire [31: 0] pc_ppl_w;
    reg [31:0] inst_ppl_r;
    wire [31: 0] inst_ppl_w;
    reg         compressed_ppl_r;
    wire        compressed_ppl_w;
//-------Internal Registers-------
    wire [31:0] inst_i;
    reg [31:0] pc_r, pc_w;
    wire [31:0] pc_step;
    wire       inst_ready;
    wire       inst_compressed;


    localparam NOP = 32'h00000013;
    assign pc_step = pc_r + (inst_compressed ? 2 : 4);


    realigner u0(
        .clk(clk),
        .rst_n(rst_n),
        .pc(pc_r),
        .ready(inst_ready),
        .compressed(inst_compressed),
        .inst(inst_i),
        .ICACHE_stall(ICACHE_stall),
        .ICACHE_ren(ICACHE_ren),
        .ICACHE_wen(ICACHE_wen),
        .ICACHE_addr(ICACHE_addr),
        .ICACHE_wdata(ICACHE_wdata),
        .ICACHE_rdata(ICACHE_rdata)
    );


    always @(*) begin:next_pc
        //TODO: evaluate between case and if
        if (pc_src == 2'b01) begin //jal || jalr
            pc_w = pc_j;
        end 
        else if(pc_src == 2'b10) begin
            pc_w = pc_branch;
        end else if (!(load_use_hazard || stall || !inst_ready)) begin
            pc_w = pc_step;
        end else begin
            pc_w = pc_r;
        end
    end

    // convert little-endian to normal packing
    assign inst_ppl_w = stall? inst_ppl_r : (flush || !inst_ready) ? NOP : inst_i;
    assign pc_ppl_w = stall ? pc_ppl_r : pc_r;
    assign compressed_ppl_w = stall ? compressed_ppl_r : (flush || !inst_ready) ? 0 : inst_compressed;
   
    // output assignment
    assign inst_ppl = inst_ppl_r;
    assign pc_ppl = pc_ppl_r;
    assign compressed_ppl = compressed_ppl_r;
    assign PC = pc_r;

    always @(posedge clk) begin
        if (!rst_n) begin
            pc_r <= 0;
            pc_ppl_r <= 0;
            inst_ppl_r <= 0;
            compressed_ppl_r <= 0;
        end else begin
            pc_r <= pc_w;
            inst_ppl_r <= inst_ppl_w;
            pc_ppl_r <= pc_ppl_w;
            compressed_ppl_r <= compressed_ppl_w;
        end
    end


endmodule