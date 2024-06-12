module RISCV_IF(
    input         clk,
    input         rst_n,
    //feedback paths
    input         stall,
    input         flush,
    //input  [1:0]  pc_src,  // pc_src[1] = branch pc_src[0] = jalr || jal TODO: compress it to 1 bit
    input         make_correction,
    input  [31:0] pc_correction,
    //for BTB
    input         feedback_valid,//if the instruction in EX is not a branch or stalling...
    input         ID_stall,
    input [31: 0] set_pc_i,
    input         set_taken_i,
    input [31: 0] set_target_i,
//-------ICACHE-interface-------
	input  ICACHE_stall,
    input  load_mul_use_hazard,
    output ICACHE_ren,
	output ICACHE_wen,
	output [29: 0] ICACHE_addr,
	input  [31: 0] ICACHE_rdata,
    output [31: 0] ICACHE_wdata,
//-------Pipeline Registers-------
    output [31: 0] inst_ppl,
    output [31: 0] pc_ppl,
    output         compressed_ppl,
    //output         branch_taken_ppl,//idicates if the branch was predicted to be taken
    //will compare the predicted pc and the correct pc in EX stage, so no need 
    output [31: 0] pred_dest_ppl,
//--------IF stage PC------------
    output [31:0] PC
);

    //-------Pipeline Registers------
    reg  [31:0] pc_ppl_r;
    wire [31:0] pc_ppl_w;
    reg  [31:0] inst_ppl_r;
    wire [31:0] inst_ppl_w;
    reg         compressed_ppl_r;
    wire        compressed_ppl_w;
    
    /*deprecated because BTB
    reg         branch_taken_ppl_r;
    wire        branch_taken_ppl_w;
    */
    reg [31: 0] pred_dest_ppl_r;
    wire [31: 0] pred_dest_ppl_w;

    //-------Internal Registers-------
    wire [31:0] inst_aligned;
    // wire [31:0] inst_decompressed;
    wire [31:0] inst_i;
    reg [31:0]  pc_r, pc_w;
    wire [31:0] pc_step;
    wire        take_branch;
    //wire [31:0] branch_destination;//deprecated
    wire [31:0] sbtype_imm;
    wire        is_branch;
    wire        rvc_jalr_jr, rvc_jal_j;
    wire        is_jump;
    wire       inst_ready;
    wire       inst_compressed;
    wire [31: 0] btb_dest; //btb_dest is different from pred_dest
    //for example: if the prediction is to not take --> pred_dest = pc_step
    //btb_dest is simply what btb stores in anticipation of a branch/jump
    

    localparam OPCODE_BRANCH = 7'b11_000_11;
    localparam OPCODE_JAL    = 7'b11_011_11;
    localparam OPCODE_JALR   = 7'b11_001_11;

    localparam NOP = 32'h00000013;
    assign pc_step = pc_r + (inst_compressed ? 2 : 4);
    //assign sbtype_imm = inst_compressed ? {{24{inst_i[12]}}, inst_i[6:5], inst_i[2], inst_i[11:10], inst_i[4:3], 1'b0} :
    //{{(32-13){inst_i[31]}}, inst_i[31], inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
    assign rvc_jalr_jr = (inst_i[15:13] == 3'b100)
                        & (inst_i[6:2] == 5'b00000)
                        & (inst_i[1:0] == 2'b10);    
    assign rvc_jal_j = (inst_i[15:13] == 3'b101 || inst_i[15:13] == 3'b001) && inst_i[1:0] == 2'b01;
    
    assign is_branch = inst_compressed? 
                        ((inst_i[15:13] == 3'b110 | (inst_i[15:13] == 3'b111))
                        & (inst_i[1:0] == 2'b01)) :
                        (inst_i[6: 0] == OPCODE_BRANCH);
    assign is_jump   = inst_compressed? 
                        (rvc_jalr_jr || rvc_jal_j) :
                        (inst_i[6: 0] == OPCODE_JAL || inst_i[6: 0] == OPCODE_JALR);



    //assign branch_destination = pc_r + sbtype_imm; //doing this in IF is too slow, do in EX

    realigner u0 (
        .clk(clk),
        .rst_n(rst_n),
        .pc(pc_r),
        .ready(inst_ready),
        .compressed(inst_compressed),
        .inst(inst_aligned),
        .ICACHE_stall(ICACHE_stall),
        .ICACHE_ren(ICACHE_ren),
        .ICACHE_wen(ICACHE_wen),
        .ICACHE_addr(ICACHE_addr),
        .ICACHE_wdata(ICACHE_wdata),
        .ICACHE_rdata(ICACHE_rdata)
    );

    // decompressor u_decompressor (
    //     .inst_i(inst_aligned[15:0]),
    //     .inst_o(inst_decompressed)
    // );

    assign inst_i = inst_aligned;
    branch_predictor u_branch_predictor(
        //input
        .clk                    (clk),
        .rst_n                  (rst_n),
        .branch_pc              (pc_r),
        //output 
        .take_branch            (take_branch),
        .predicted_destination  (btb_dest),       
        
        //feedback inputs
        .feedback_valid         (feedback_valid && !ID_stall),//prevent update when ID_stall (ID/EX reg)
        .set_pc                 (set_pc_i),
        .set_taken              (set_taken_i),
        .set_destination        (set_target_i)
    );

    always @(*) begin : next_pc
        //TODO: evaluate between case and if
        if (make_correction) begin
            pc_w = pc_correction;
        end else if (!(load_mul_use_hazard || stall || !inst_ready)) begin
            //branch if predicted so, always jump
            pc_w = ((take_branch && is_branch)||is_jump)? btb_dest: pc_step; 
        end else begin
            pc_w = pc_r;
        end
    end

    // convert little-endian to normal packing
    assign inst_ppl_w = stall ? inst_ppl_r : (flush || !inst_ready) ? NOP : inst_i;
    assign pc_ppl_w = stall ? pc_ppl_r : pc_r;
    assign compressed_ppl_w = stall ? compressed_ppl_r : (flush || !inst_ready) ? 0 : inst_compressed;
    //assign branch_taken_ppl_w = take_branch;
    assign pred_dest_ppl_w = stall? pred_dest_ppl_r : pc_w;

    // output assignment
    assign inst_ppl = inst_ppl_r;
    assign pc_ppl = pc_ppl_r;
    assign compressed_ppl = compressed_ppl_r;
    assign PC = pc_r;
    //assign branch_taken_ppl = branch_taken_ppl_r;
    assign pred_dest_ppl = pred_dest_ppl_r;

    always @(posedge clk) begin
        if (!rst_n) begin
            pc_r <= 0;
            pc_ppl_r <= 0;
            inst_ppl_r <= 0;
            compressed_ppl_r <= 0;
            //branch_taken_ppl_r <= 0;
            pred_dest_ppl_r <= 0;
        end else begin
            pc_r <= pc_w;
            inst_ppl_r <= inst_ppl_w;
            pc_ppl_r <= pc_ppl_w;
            compressed_ppl_r <= compressed_ppl_w;
            //branch_taken_ppl_r <= branch_taken_ppl_w;
            pred_dest_ppl_r <= pred_dest_ppl_w;
        end
    end


endmodule
