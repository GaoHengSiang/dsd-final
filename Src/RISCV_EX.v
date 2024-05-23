module EX_STAGE #(
    parameter BIT_W = 32
    )(
    //PIPELINE INPUT FROM ID/EX REGISTER
    input [BIT_W-1: 0] rs1_dat_in,
    input [BIT_W-1: 0] rs2_dat_in,
    input [BIT_W-1: 0] imm,
    input [4: 0] rs1_in,
    input [4: 0] rs2_in,
    input [4: 0] rd_in,
        //various control signals input
    input alusrc_in,
    input [3: 0] aluctrl_in,
    input jalr_in,
    input jal_in,
    input branch_in,
    input memrd_in,
    input memwr_in,
    input mem2reg_in,
    input regwr_in,


    //PIPELINE OUTPUT TO EX/MEM REGISTER
    output [BIT_W-1: 0] alu_result,
    output [BIT_W-1: 0] second_opr,
    output [4: 0] rd_out,
        //various control signals output
    output memrd_out,
    output memwr_out,
    output mem2reg_out,
    output regwr_out
    //INPUT FROM STANDALONE MODULES SUCH AS FORWARDING, HAZARD_DETECTION
    //maybe no need because forwarding is already done in ID stage
);

endmodule