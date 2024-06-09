`timescale 1ns / 10ps

module testbench;
    reg [31:0] a, b;
    reg [63:0] result;
    reg [31:0] result_l32;
    wire [31:0] out;

    // Instantiate the multiplier
    mul_unit uut (
        .a(a), 
        .b(b), 
        .out(out)
    );

    initial begin
        // Test case 1
        a = 32'h12345678;
        b = 32'h87654321;
        result = a * b;
        result_l32 = result[31:0];
        #100;  // Wait for 100 ns for the design to process the input
        $display("Test case 1: The out of %h and %h is %h", a, b, out);
        if (out === result_l32)
            $display("Test case 1 passed");
        else
            $display("Test case 1 failed");

        // Test case 2
        a = 32'h11111111;
        b = 32'h22222222;
        result = a * b;
        result_l32 = result[31:0];
        #100;  // Wait for 100 ns for the design to process the input
        $display("Test case 2: The out of %h and %h is %h", a, b, out);
        if (out === result_l32)
            $display("Test case 2 passed");
        else
            $display("Test case 2 failed");
        // Test case 3
        a = 32'h33333333;
        b = 32'h44444444;
        result = a * b;
        result_l32 = result[31:0];
        #100;  // Wait for 100 ns for the design to process the input
        $display("Test case 3: The out of %h and %h is %h", a, b, out);
        if (out === result_l32)
            $display("Test case 3 passed");
        else
            $display("Test case 3 failed");

        // Test case 4
        // Test INT_MAX
        a = 32'h7FFFFFFF;
        b = 32'h7FFFFFFF;
        result = a * b;
        result_l32 = result[31:0];
        #100;  // Wait for 100 ns for the design to process the input
        $display("Test case 4: The out of %h and %h is %h", a, b, out);
        if (out === result_l32)
            $display("Test case 4 passed");
        else
            $display("Test case 4 failed");

        
        // Test case 5
        // Test zero
        a = 32'h0;
        b = 32'hFFFFFFFF;
        result = a * b;
        result_l32 = result[31:0];
        #100;  // Wait for 100 ns for the design to process the input
        $display("Test case 5: The out of %h and %h is %h", a, b, out);
        if (out === result_l32)
            $display("Test case 5 passed");
        else
            $display("Test case 5 failed");
        
        // Test case 6
        // Test -1
        a = 32'hFFFFFFFF;
        b = 32'hFFFFFFFF;
        result = a * b;
        result_l32 = result[31:0];
        #100;  // Wait for 100 ns for the design to process the input
        $display("Test case 6: The out of %h and %h is %h", a, b, out);
        if (out === result_l32)
            $display("Test case 6 passed");
        else
            $display("Test case 6 failed");
        // Finish the simulation
        $finish;
    end
endmodule
