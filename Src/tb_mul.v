`timescale 1ns/10ps;

// `include "Daddas_MUL.v"

module MUL_UNIT_tb();

reg clk;
reg rst_n;

reg [31:0] mul_in1, mul_in2;
wire [31:0] mul_result;

mul_unit d0(
    .clk(clk),
    .rst_n(rst_n),
    .a({mul_in1}),
    .b({mul_in2}),
    .c(mul_result)
);

initial begin
    clk = 0;
    forever
    #5 clk = ~clk;
end


integer i,j,k;
parameter TESTCASE = 100;
initial begin
    $fsdbDumpfile("MUL.fsdb");			
    $fsdbDumpvars(0,MUL_UNIT_tb,"+mda");
    $fsdbDumpvars;

    #10;
    rst_n = 0;
    #10;
    rst_n = 1;

    for(i=0;i<TESTCASE;i=i+1) begin
        @(posedge clk);
        mul_in1 = $random; ;
        mul_in2 = $random; ;
        j = mul_in1 * mul_in2;
        @(posedge clk);
        //@(posedge clk);
        #1;
        $display("================================================\n\n", );
        $display("TEST:  mul_in1 = %d, mul_in2 = %d, mul_result = %b\n", mul_in1, mul_in2, j);
        if(mul_result != j) begin
            $display("ERROR: mul_in1 = %d, mul_in2 = %d, mul_result = %b\n\n", mul_in1, mul_in2, mul_result);
        end
    end
    $finish;
end
endmodule