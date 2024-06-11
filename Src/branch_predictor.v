module branch_predictor(
    input clk,
    input rst_n,
    input [31:0] branch_pc, // BHB will use branch_pc to index the saturation counter
    input prediction_correct,
    input feedback_valid,//if the instruction in EX is not a branch, or if it is stalling, 
        //the saturation counter should not take this feedback
    output take_branch
);

`ifndef USE_BHB
    saturation_counter u_saturation_counter (
        .clk                   (clk),
        .rst_n                 (rst_n),
        .prediction_correct    (prediction_correct),
        .feedback_valid        (feedback_valid),
        .take_branch           (take_branch)
    );
`else
    parameter BHB_SIZE = 4;
`endif


endmodule