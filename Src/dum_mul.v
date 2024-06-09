//simulates a 2-stage pipelined multiplier
module dum_mul (
    input clk,
    input rst_n,
    input [31: 0] opA,
    input [31: 0] opB,
    output [31: 0] result
);
    reg [31: 0] a_stage1_r, b_stage1_r;
    assign result = a_stage1_r * b_stage1_r;

    always @(posedge clk) begin
        if(!rst_n) begin
            a_stage1_r <= 0;
            b_stage1_r <= 0;
        end
        else begin
            a_stage1_r <= opA;
            b_stage1_r <= opB;
        end
    end

endmodule