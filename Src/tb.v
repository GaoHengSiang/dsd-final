// //tb for wallace
// `timescale 1ns/10ps

// module tb;

//    	reg [7:0] a;
//    	reg [7:0] b;
// 	wire [15:0] out;
//     reg [15:0] res;
// 	integer x1=0;

//     wallace m (.a1(a), .b1(b), .result(out));

// initial begin
//         a = 1;
// 		b = 1;
		
// 		for (x1=1; x1<10; x1=x1+1)
// 		begin
// 			#5 a = a+x1+1;
// 			    b = b+x1+2;
//                 res = a*b;
// 			#5 $display("x = %d, y = %d, ans = %d\n", a, b, out);
            
//             if (out[15:0] === res[15:0])
//                 $display("Test case  passed");
//             else
//                 $display("Test case  failed");
// 		end
		
// 		for (x1=9; x1<100; x1=x1+5)
// 		begin
// 			#5 a = a+x1;
// 			    b = b+2*x1;
//                 res = a*b;
                
// 			#5 $display("x = %d, y = %d, ans = %d\n", a, b, out);
//             if (out[15:0] === res[15:0])
//                 $display("Test case  passed");
//             else
//                 $display("Test case  failed");
// 		end
// 		a = 123123123;
// 		b = 121212121;
//         res = a*b;

// 		#5 $display("a = %d, b = %d,  = %d\n", a, b, out);
//             if (out[15:0] === res[15:0])
//             $display("Test case  passed");
//         else
//             $display("Test case  failed");
		
//       $finish;

//    end
// endmodule







`timescale 1ns / 1ps

module testbench;
    reg [31:0] a, b;
    wire [63:0] out;
    reg [63:0] res;
    integer x1=0;

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
        res = a*b;
        #100;  // Wait for 100 ns for the design to process the input
        $display("Test case 1: The out of %h and %h is %h", a, b, out);
        if (out[31:0] === res[31:0])
            $display("Test case  passed");
        else
            $display("Test case  failed");

        // Test case 2
        a = 32'h11111111;
        b = 32'h22222222;
        res = a*b;
        #100;  // Wait for 100 ns for the design to process the input
        $display("Test case 2: The out of %h and %h is %h", a, b, out);
        if (out[31:0] === res[31:0])
            $display("Test case  passed");
        else
            $display("Test case  failed");

        // Test case 3
        a = 32'h33333333;
        b = 32'h44444444;
        res = a*b;
        #100;  // Wait for 100 ns for the design to process the input
        $display("Test case 3: The out of %h and %h is %h", a, b, out);
        if (out[31:0] === res[31:0])
            $display("Test case  passed");
        else
            $display("Test case  failed");

		a = 32'h00000096;
        b = 32'h000000FE;
        res = a*b;
        #100;  // Wait for 100 ns for the design to process the input
        $display("Test case 3: The out of %h and %h is %h", a, b, out);
        if (out[31:0] === res[31:0])
            $display("Test case  passed");
        else
            $display("Test case  failed");
		a = 32'h003451ED;
        b = 32'h023103AC;
        res = a*b;
        #100;  // Wait for 100 ns for the design to process the input
        $display("Test case 3: The out of %h and %h is %h", a, b, out);
        if (out[31:0] === res[31:0])
            $display("Test case  passed");
        else
            $display("Test case  failed");
		a = 32'h075745B3;
        b = 32'h073647C9;
        res = a*b;
        #100;  // Wait for 100 ns for the design to process the input
        $display("Test case 3: The out of %h and %h is %h", a, b, out);
        if (out[31:0] === res[31:0])
            $display("Test case  passed");
        else
            $display("Test case  failed");

		a = 32'd429;
        b = 32'd812;
        res = a*b;
        #100;  // Wait for 100 ns for the design to process the input
        $display("Test case 3: The out of %h and %h is %h", a, b, out);
        if (out[31:0] === res[31:0])
            $display("Test case  passed");
        else
            $display("Test case  failed");
        // Test case 1
        a = 32'h12345678;
        b = 32'h87654321;
        res = a * b;
        
        #100;  // Wait for 100 ns for the design to process the input
        $display("Test case 1: The out of %h and %h is %h", a, b, out);
        if (out === res[31:0])
            $display("Test case 1 passed");
        else
            $display("Test case 1 failed");

        // Test case 2
        a = 32'h11111111;
        b = 32'h22222222;
        res = a * b;
        
        #100;  // Wait for 100 ns for the design to process the input
        $display("Test case 2: The out of %h and %h is %h", a, b, out);
        if (out === res[31:0])
            $display("Test case 2 passed");
        else
            $display("Test case 2 failed");
        // Test case 3
        a = 32'h33333333;
        b = 32'h44444444;
        res = a * b;
        
        #100;  // Wait for 100 ns for the design to process the input
        $display("Test case 3: The out of %h and %h is %h", a, b, out);
        if (out === res[31:0])
            $display("Test case 3 passed");
        else
            $display("Test case 3 failed");

        // Test case 4
        // Test INT_MAX
        a = 32'h7FFFFFFF;
        b = 32'h7FFFFFFF;
        res = a * b;
        
        #100;  // Wait for 100 ns for the design to process the input
        $display("Test case 4: The out of %h and %h is %h", a, b, out);
        if (out === res[31:0])
            $display("Test case 4 passed");
        else
            $display("Test case 4 failed");

        
        // Test case 5
        // Test zero
        a = 32'h0;
        b = 32'hFFFFFFFF;
        res = a * b;
        
        #100;  // Wait for 100 ns for the design to process the input
        $display("Test case 5: The out of %h and %h is %h", a, b, out);
        if (out === res[31:0])
            $display("Test case 5 passed");
        else
            $display("Test case 5 failed");
        
        // Test case 6
        // Test -1
        a = 32'hFFFFFFFF;
        b = 32'hFFFFFFFF;
        res = a * b;
        
        #100;  // Wait for 100 ns for the design to process the input
        $display("Test case 6: The out of %h and %h is %h", a, b, out);
        if (out === res[31:0])
            $display("Test case 6 passed");
        else
            $display("Test case 6 failed");
        
        // Finish the simulation
        a = 1;
		b = 1;
		
		for (x1=1; x1<10; x1=x1+1)
		begin
			#5 a = a+x1+1;
			    b = b+x1+2;
                res = a*b;
			#5 $display("x = %d, y = %d, ans = %d\n", a, b, out);
            if (out[31:0] === res[31:0])
                $display("Test case  passed");
            else
                $display("Test case  failed");
		end
		
		for (x1=9; x1<100; x1=x1+5)
		begin
			#5 a = a+x1;
			    b = b+2*x1;
                res = a*b;
			#5 $display("x = %d, y = %d, ans = %d\n", a, b, out);
            if (out[31:0] === res[31:0])
                $display("Test case  passed");
            else
                $display("Test case  failed");
		end
		a = 123123123;
		b = 121212121;
        res = a*b;
		#5 $display("a = %d, b = %d,  = %d\n", a, b, out);
        if (out[31:0] === res[31:0])
            $display("Test case  passed");
        else
            $display("Test case  failed");
        $finish;
    end
endmodule
