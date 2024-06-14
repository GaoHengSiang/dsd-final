//simulates a 2-stage pipelined multiplier
module dum_mul (
    input clk,
    input rst_n,
    input stall,//should support stalling
    input [31: 0] opA,
    input [31: 0] opB,
    output [31: 0] result//register blocked
);
    reg [31: 0] first_mul_r, first_mul_w;
    reg [31: 0] result_r, result_w;
    assign result = result_r;

     always @(*) begin
        first_mul_w = stall? first_mul_r: opA * opB;//equivalent to EX/MEM
        result_w = stall? result_r: first_mul_r;//equivalent to MEM/WB
    end


    always @(posedge clk) begin
        if(!rst_n) begin
            first_mul_r <= 0;
            result_r <= 0;
        end
        else begin
            first_mul_r <= first_mul_w;
            result_r <= result_w;
        end
    end

endmodule