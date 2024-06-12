module branch_predictor(
    input clk,
    input rst_n,
    input [31:0] branch_pc, // BTB will use branch_pc to index the saturation counter

    //correction 
    input feedback_valid,//if the instruction in EX is not a branch, or if it is stalling, 
        //the saturation counter should not take this feedback
    input [31: 0] set_pc,//the pc of the branch instruction that is being corrected
    input set_taken,
    input [31: 0] set_destination,

    output take_branch,
    output [31: 0] predicted_destination
);

`ifndef USE_BTB
    saturation_counter u_saturation_counter (
        .clk                   (clk),
        .rst_n                 (rst_n),
        .set_taken             (set_taken),
        .feedback_valid        (feedback_valid),
        .take_branch           (take_branch)
    );
    assign predicted_destination = 0;
`else
    parameter BTB_SIZE = 4;
    BTB_BHT #(.BTBW(BTB_SIZE)) u_btb_bht (
        .clk                    (clk),
        .rst_n                  (rst_n),
        .pre_take_o             (take_branch),
        .pre_destination_o      (predicted_destination[31: 1]),
        .pc_i                   (branch_pc[31: 1]),
        .feedback_valid_i       (feedback_valid),
        .set_pc_i               (set_pc[31: 1]),
        .set_taken_i            (set_taken),
        .set_target_i           (set_destination[31: 1])
    );
    assign predicted_destination [0] = 1'b0;

`endif
endmodule