//under development by Gao HengSiang

module MEM_STAGE #(
    parameter BIT_W = 32
    )(
    input clk,
    input rst_n,
    //PIPELINE INPUT FROM ID/EX REGISTER
    output [BIT_W-1: 0] alu_result,
    output [BIT_W-1: 0] second_opr,
    output [4: 0] rd_in
        //various control signals input
    input memrd_in,
    input memwr_in,
        //transparent
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