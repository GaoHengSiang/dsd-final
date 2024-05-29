//under development by Gao HengSiang

module EX_STAGE #(
    parameter BIT_W = 32
    )(
    input clk,
    input rst_n,
    //PIPELINE INPUT FROM ID/EX REGISTER
    input [BIT_W-1: 0] PC_in,
    input [BIT_W-1: 0] rs1_dat_in,
    input [BIT_W-1: 0] rs2_dat_in,
    input [BIT_W-1: 0] imm,
        //various control signals input
    input alusrc_in,
    input [3: 0] aluctrl_in,
    input jal_in,
    input jalr_in,
    input branch_in,
    input bne_in,
    input stall,

    //transparent for this stage
    input [4: 0] rd_in,
    input memrd_in,
    input memwr_in,
    input mem2reg_in,
    input regwr_in,

    // forwarding
    input forward_A_flag,
    input [31: 0] forward_A_dat,
    input forward_B_flag,
    input [31: 0] forward_B_dat,



    //PIPELINE OUTPUT TO EX/MEM REGISTER
    output [BIT_W-1: 0] alu_result,
    output [BIT_W-1: 0] mem_wdata,
    output [4: 0] rd_out,
    output [BIT_W-1: 0] PC_plus_4,
        //various control signals output
    output memrd_out,
    output memwr_out,
    output mem2reg_out,
    output regwr_out,
    output jump_out,
    
    //INPUT FROM STANDALONE MODULES SUCH AS FORWARDING, HAZARD_DETECTION
    //maybe no need because forwarding is already done in ID stage
    output jump_noblock, //not blocked by register, signal for IF stage
    output [31: 0] PC_result_noblock,//for jump and branch
    output branch_taken //not blocked
);
    //Reg and Wire declaration
    reg [BIT_W-1: 0] alu_result_r, alu_result_w;
    reg [BIT_W-1: 0] mem_wdata_r, mem_wdata_w;
    reg [4: 0] rd_r, rd_w;
    reg [BIT_W-1: 0] PC_plus_4_r, PC_plus_4_w;
    reg memrd_r, memrd_w,
        memwr_r, memwr_w,
        mem2reg_r, mem2reg_w,
        regwr_r, regwr_w,
        jump_r, jump_w;

    reg [BIT_W-1: 0] alu_opA, alu_opB;
    wire [BIT_W-1: 0] alu_o_wire;

    //forwarded rs1 and rs2
    wire [31: 0] forwarded_rs1, forwarded_rs2; 


    //Continuous assignments
    //output assignments
    assign alu_result = alu_result_r;
    assign mem_wdata = mem_wdata_r;
    assign rd_out = rd_r;
    assign PC_plus_4 = PC_plus_4_r;
    assign memrd_out = memrd_r;
    assign memwr_out = memwr_r;
    assign mem2reg_out = mem2reg_r;
    assign regwr_out = regwr_r;
    assign jump_out = jump_r;

    //forwarded rs1, rs2
    assign forwarded_rs1 = (forward_A_flag)? forward_A_dat: rs1_dat_in;
    assign forwarded_rs2 = (forward_B_flag)? forward_B_dat: rs2_dat_in;


    //direct output, no blocking!
    assign jump_noblock = jalr_in || jal_in;
    assign PC_result_noblock = alu_o_wire;
        //branch
    assign branch_taken = ((forwarded_rs1 == forwarded_rs2) ^ bne_in) & branch_in; 

    
    //module instantiation
    alu alu_inst(
        .op(aluctrl_in),
        .operand_a(alu_opA),
        .operand_b(alu_opB),
        .out(alu_o_wire)
    );
    //Combinational
    always @(*) begin
        alu_opA = (jal_in||branch_in)? PC_in: forwarded_rs1;
        alu_opB = alusrc_in? imm: forwarded_rs2;
    end

    always @(*) begin
        alu_result_w    = stall? alu_result_r: alu_o_wire;
        mem_wdata_w     = stall? mem_wdata_r: rs2_dat_in;
        rd_w            = stall? rd_r: rd_in;
        PC_plus_4_w     = stall? PC_plus_4_r: PC_in + 4;
        memrd_w         = stall? memrd_r: memrd_in;
        memwr_w         = stall? memwr_r: memwr_in;
        mem2reg_w       = stall? mem2reg_r: mem2reg_in;
        regwr_w         = stall? regwr_r: regwr_in;
        jump_w          = stall? jump_r: jalr_in || jal_in;

    end
    //Sequential
    always @(posedge clk) begin
        if(!rst_n) begin
            alu_result_r    <= 0;
            mem_wdata_r     <= 0;
            rd_r            <= 0;
            PC_plus_4_r     <= 0;
            memrd_r         <= 0;
            memwr_r         <= 0;
            mem2reg_r       <= 0;
            regwr_r         <= 0;
            jump_r          <= 0;
        end
        else begin
            alu_result_r    <= alu_result_w;
            mem_wdata_r     <= mem_wdata_w;
            rd_r            <= rd_w;
            PC_plus_4_r     <= PC_plus_4_w;
            memrd_r         <= memrd_w;
            memwr_r         <= memwr_w;
            mem2reg_r       <= mem2reg_w;
            regwr_r         <= regwr_w;
            jump_r          <= jump_w;
        end
    end
endmodule