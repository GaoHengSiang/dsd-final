module alu(
    input   [3:0] op,
    input  [31:0] operand_a,
    input  [31:0] operand_b,
    output [31:0] out
);

    // operations definition
    localparam ADD       = 0;
    localparam SUB       = 1;
    localparam AND       = 2;
    localparam OR        = 3;
    localparam XOR       = 4;
    localparam SRA       = 5;
    localparam SRL       = 6;
    localparam SLL       = 7;
    localparam SLT       = 8;


    genvar gen_i;

    // wire declaration
    reg  [31:0] alu_out;
    wire [31:0] adder_result;
    wire [32:0] adder_in_a, adder_in_b;
    wire        adder_b_neg;
    wire [33:0] adder_result_tmp;

    wire [31:0] operand_a_rev;
    wire [31:0] shift_op_a;
    wire [32:0] shift_in;
    wire        shift_left;
    wire  [4:0] shift_amt;
    wire [32:0] shift_right_result;
    wire [31:0] shift_left_result;
    wire [31:0] shift_result;
    wire padding;

    generate 
        for (gen_i = 0; gen_i < 32; gen_i = gen_i+1) begin:gen_blk0
            assign operand_a_rev[gen_i] = operand_a[31-gen_i];
            assign shift_left_result[gen_i] = shift_right_result[31-gen_i];
        end
    endgenerate 

    // adder
    assign adder_b_neg = (op == SUB || op == SLT);
    assign adder_in_a = {operand_a, 1'b1};
    assign adder_in_b = {operand_b, 1'b0} ^ {33{adder_b_neg}};
    assign adder_result_tmp = $signed(adder_in_a) + $signed(adder_in_b);
    assign adder_result = adder_result_tmp[32:1];
    
    // shifter
    assign padding = (operand_a[31] && (op == SRA))? 1 : 0;
    assign shift_left = (op == SLL);
    assign shift_amt = operand_b[4:0];

    assign shift_op_a = shift_left ? operand_a_rev : operand_a;
    assign shift_in = {padding, shift_op_a};
    assign shift_right_result = $unsigned(($signed(shift_in) >>> shift_amt));
    assign shift_result = shift_left ? shift_left_result : shift_right_result[31:0];

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
            SRA, SRL, SLL: begin
                alu_out = shift_result;
            end
        endcase
    end

endmodule