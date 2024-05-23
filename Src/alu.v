module alu(
    input   [2:0] op,
    input  [31:0] operand_a,
    input  [31:0] operand_b,
    output [31:0] out,
);

    // operations definition
    localparam ADD       = 0;
    localparam SUB       = 1;
    localparam AND       = 2;
    localparam OR        = 3;
    localparam XOR       = 4;
    localparam SRA       = 5;
    localparam SRL       = 6;
    localparam SLT       = 7;



    // wire declaration
    reg  [31:0] alu_out;
    wire [31:0] adder_result;
    wire [32:0] adder_in_a, adder_in_b;
    wire        adder_b_neg;
    wire [33:0] adder_result_tmp;

    wire [32:0] shift_op_a;
    wire  [4:0] shift_amt;
    wire [32:0] shift_result;
    wire padding;

    // adder
    assign adder_b_neg = (op == SUB || op == SLT);
    assign adder_in_a = {alu_operand_a, 1'b1};
    assign adder_in_b = {alu_operand_b, 1'b0} ^ {33{adder_b_neg}};
    assign adder_result_tmp = $signed(adder_in_a) + $signed(adder_in_b);
    assign adder_result = adder_result_tmp[32:1];
    
    // shifter
    assign padding = (operand_a[31] && (op == SRA))? 1 : 0;
    assign shift_amt = operand_b[4:0];
    assign shift_op_a = {padding, operand_a};
    assign shift_result = $unsigned($(signed(shift_op_a) >>> shift_amt));
    
    // output assignment
    assign out = alu_out;
    
    always @(*) begin
        case (op) 
            ADD, SUB: begin
                alu_out = adder_result;
            end 
            SLT: begin
                //FIXME: if SLT doesn't need to care about overflow, we can use 
                //       adder_result[31], it will shorten the critical path
                alu_out = {31'b0, adder_result_tmp[33]};
            end
            AND: begin
                alu_out = operand_a & operand_b;
            end
            OR: begin
                alu_out = operand_a | operand_b;
            end
            XOR: begin
                alu_out = operand_a ^ operand_b;
            end
            SRA, SRL: begin
                alu_out = shift_result[31:0];
            end
        endcase
    end

endmodule