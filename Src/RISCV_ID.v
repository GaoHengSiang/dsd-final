module RISCV_ID (
    input clk,
    input rst_n,
    input stall,
    input flush,

    input  [31:0] inst_ppl,
    input  [31:0] pc_ppl,
    input         compressed_ppl,
//    input         branch_taken_in, //the prediction
    //input [31: 0] pred_dest_in,

    output [ 4:0] rd_ppl,
    output [31:0] rs1_data_ppl,
    rs2_data_ppl,
    output [31:0] imm_ppl,
    output        alu_src_ppl,
    output [ 3:0] alu_ctrl_ppl,
    output [31:0] pc_ppl_out,
    output        jal_ppl,
    output        jalr_ppl,
    output        branch_ppl,
    output        bne_ppl,
    output        mem_ren_ppl,
    output        mem_wen_ppl,
    output        mem_to_reg_ppl,
    output [ 4:0] rs1_ppl,
    output [ 4:0] rs2_ppl,
    output        reg_wen_ppl,
    output        compressed_ppl_out,
//    output        branch_taken_ppl,//the prediction
    //output [31:0] pred_dest_ppl,
    output        mul_ppl,

    //----------register_file interface-------------
    output [ 4:0] regfile_rs1,
    regfile_rs2,
    input  [31:0] regfile_rs1_data,
    regfile_rs2_data
);
    // decoder result
    wire [4:0] rs1, rs2, rd;
    wire [31:0] imm;
    wire        alu_src;
    wire [ 3:0] alu_op;
    wire jal, jalr, branch, bne, mem_to_reg, mem_wen, mem_ren, reg_wen, mul;

    // wire and reg
    wire [31:0] rs1_rdata_w, rs2_rdata_w;
    wire [31:0] imm_w;
    wire [4:0] rd_w, rs1_w, rs2_w;
    wire       alu_src_w;
    wire [3:0] alu_op_w;
    wire jal_w, jalr_w, mem_to_reg_w, mem_wen_w, mem_ren_w, reg_wen_w;
    wire [31:0] pc_out_w;
    wire bne_w, branch_w; //branch_taken_w;
    //wire [31: 0] pred_dest_w;
    wire compressed_ppl_w;
    wire mul_w;
    wire [31:0] inst_decompressed;
    wire [31:0] inst_decode_in;

    reg [31:0] rs1_rdata_r, rs2_rdata_r;
    reg [31:0] imm_r;
    reg [4:0] rd_r, rs1_r, rs2_r;
    reg       alu_src_r;
    reg [3:0] alu_op_r;
    reg jal_r, jalr_r, mem_to_reg_r, mem_wen_r, mem_ren_r, reg_wen_r;
    reg [31:0] pc_out_r;
    reg bne_r, branch_r;// branch_taken_r;
    //reg [31: 0] pred_dest_r;
    reg compressed_ppl_r;
    reg mul_r;

    assign regfile_rs1 = rs1;
    assign regfile_rs2 = rs2;
    assign rs1_rdata_w = regfile_rs1_data;
    assign rs2_rdata_w = regfile_rs2_data;
    assign imm_w = imm;
    assign rd_w = rd;
    assign rs1_w = rs1;
    assign rs2_w = rs2;
    assign alu_src_w = alu_src;
    assign alu_op_w = alu_op;
    assign jal_w = jal;
    assign jalr_w = jalr;
    assign mem_to_reg_w = mem_to_reg;
    assign mem_wen_w = mem_wen;
    assign mem_ren_w = mem_ren;
    assign reg_wen_w = reg_wen;
    assign pc_out_w = pc_ppl;
    assign bne_w = bne;
    assign branch_w = branch;
    assign compressed_ppl_w = compressed_ppl;
    assign mul_w = mul;
    //assign branch_taken_w = branch_taken_in;
    //assign pred_dest_w = pred_dest_in;

    // pipeline reg output
    assign rd_ppl = rd_r;
    assign rs1_data_ppl = rs1_rdata_r;
    assign rs2_data_ppl = rs2_rdata_r;
    assign imm_ppl = imm_r;
    assign alu_src_ppl = alu_src_r;
    assign alu_ctrl_ppl = alu_op_r;
    assign pc_ppl_out = pc_out_r;
    assign jal_ppl = jal_r;
    assign jalr_ppl = jalr_r;
    assign mem_ren_ppl = mem_ren_r;
    assign mem_wen_ppl = mem_wen_r;
    assign mem_to_reg_ppl = mem_to_reg_r;
    assign reg_wen_ppl = reg_wen_r;
    assign rs1_ppl = rs1_r;
    assign rs2_ppl = rs2_r;
    assign branch_ppl = branch_r;
    assign bne_ppl = bne_r;
    assign compressed_ppl_out = compressed_ppl_r;
    assign mul_ppl = mul_r;
    //assign branch_taken_ppl = branch_taken_r;
    //assign pred_dest_ppl = pred_dest_r;

    decompressor u_decompressor (
        .inst_i    (inst_ppl[15:0]),
        .inst_o    (inst_decompressed)
    );

    assign inst_decode_in = compressed_ppl ? inst_decompressed : inst_ppl;
    decoder u0 (
        .inst_i      (inst_decode_in),
        .rs1_o       (rs1),
        .rs2_o       (rs2),
        .rd_o        (rd),
        .imm_o       (imm),
        .alusrc_o    (alu_src),
        .aluop_o     (alu_op),
        .jal_o       (jal),
        .jalr_o      (jalr),
        .branch_o    (branch),
        .bne_o       (bne),
        .mem_to_reg_o(mem_to_reg),
        .mem_wen_o   (mem_wen),
        .mem_ren_o   (mem_ren),
        .reg_wen_o   (reg_wen),
        .mul_o       (mul)
    );


    always @(posedge clk) begin
        if (!rst_n) begin
            rd_r <= 0;
            rs1_r <= 0;
            rs2_r <= 0;
            alu_src_r <= 0;
            alu_op_r <= 0;
            jal_r <= 0;
            jalr_r <= 0;
            mem_to_reg_r <= 0;
            mem_wen_r <= 0;
            mem_ren_r <= 0;
            reg_wen_r <= 0;
            rs1_rdata_r <= 0;
            rs2_rdata_r <= 0;
            imm_r <= 0;
            pc_out_r <= 0;
            compressed_ppl_r <= 0;
            bne_r <= 0;
            branch_r <= 0;
            //branch_taken_r <= 0;
            //pred_dest_r <= 0;
            mul_r <= 0;
        end else if (!stall) begin
            rs1_rdata_r <= rs1_rdata_w;
            rs2_rdata_r <= rs2_rdata_w;
            imm_r <= imm_w;  // don't need to flush imm and reg data
            pc_out_r <= pc_out_w;
            compressed_ppl_r <= compressed_ppl_w;
            if (flush) begin
                rs1_r <= 0;
                rs2_r <= 0;
                rd_r <= 0;
                alu_src_r <= 0;
                alu_op_r <= 0;
                jal_r <= 0;
                jalr_r <= 0;
                mem_to_reg_r <= 0;
                mem_wen_r <= 0;
                mem_ren_r <= 0;
                reg_wen_r <= 0;
                bne_r <= 0;
                branch_r <= 0;
                //branch_taken_r <= 0;
                //pred_dest_r <= 0;
                mul_r <= 0;
            end else begin
                rs1_r <= rs1_w;
                rs2_r <= rs2_w;
                rd_r <= rd_w;
                alu_src_r <= alu_src_w;
                alu_op_r <= alu_op_w;
                jal_r <= jal_w;
                jalr_r <= jalr_w;
                mem_to_reg_r <= mem_to_reg_w;
                mem_wen_r <= mem_wen_w;
                mem_ren_r <= mem_ren_w;
                reg_wen_r <= reg_wen_w;
                bne_r <= bne_w;
                branch_r <= branch_w;
                //branch_taken_r <= branch_taken_w;
                //pred_dest_r <= pred_dest_w;
                mul_r <= mul_w;
            end
        end
    end

endmodule
