


module wallace_multiplier_64_get_l32(a, b, out );
    
input [31:0]a;
input [31:0]b;
output [31:0]out;  
wire [7:0] am1, am2, am3, am4, am5, am6, am7, am8;
wire [31:0] addtemp1, addtemp2, addtemp3, addtemp4, addtemp5, addtemp6,  addtemp7, addtemp8;
wire [31:0] l1, l2, l3, l4, l5, l6, l7, l8, l9, l10;
wire [15:0] li1, li2, li3, li4, li5, li6, li7, li8, li9, li10;
wire [31:0] w1, w2, w3;
assign am1[7:0] = a[7:0];
assign am2[7:0] = a[15:8];
assign am3[7:0] = a[23:16];
assign am4[7:0] = a[31:24];

assign am5[7:0] = b[7:0];
assign am6[7:0] = b[15:8];
assign am7[7:0] = b[23:16];
assign am8[7:0] = b[31:24];

wallace_tree_multiplier bc1(am1[7:0], am5[7:0], li1);
wallace_tree_multiplier bc2(am1, am6, li2);
wallace_tree_multiplier bc3(am1, am7, li3);
wallace_tree_multiplier bc4(am1, am8, li4);
wallace_tree_multiplier bc5(am2, am5, li5);
wallace_tree_multiplier bc6(am2, am6, li6);
wallace_tree_multiplier bc7(am2, am7, li7);
wallace_tree_multiplier bc9(am3, am5, li9);
wallace_tree_multiplier bc10(am3, am6, li10);
wallace_tree_multiplier bc13(am4, am5, li8);


assign l1 = {16'b0, li1[15:0]};
assign l2 = {8'b0, li2[15:0], 8'b0};
assign l5 = {8'b0, li5[15:0], 8'b0};
assign l6 = { li6[15:0], 16'b0};
assign l9 = { li9[15:0], 16'b0};
assign l3 = { li3[15:0], 16'b0};
assign l4 = { li4[7:0], 24'b0};
assign l7 = { li7[7:0], 24'b0};
assign l10 = { li10[7:0], 24'b0};
assign l8 = { li8[7:0], 24'b0};

adder_32 mc1(.a(l1), .b(l2), .sum(addtemp1));
adder_32 mc2(l3, l4, addtemp2);
adder_32 mc3(l5, l6, addtemp3);
adder_32 mc4(l7, l8, addtemp4);
adder_32 mc5(l9, l10, addtemp5);
adder_32 mc6(addtemp1, addtemp2, w1);
adder_32 mc7(addtemp3, addtemp4, w2);
adder_32 mc8(w1, w2, w3);
adder_32 mc9(w3, addtemp5, out);
endmodule

module full_adder(input a, b, cin, output sum, cout);
    wire temp1, temp2, temp3;
    
    assign temp1 = a ^ b;  // XOR gate for temp1
    assign temp2 = a & b;  // AND gate for temp2
    assign temp3 = cin & temp1;  // AND gate for temp3
    assign sum = cin ^ temp1;  // XOR gate for sum
    assign cout = temp2 | temp3;  // OR gate for cout
endmodule


module half_adder(input a, b, output sum, carry);
    assign sum = a ^ b;  // XOR gate for sum
    assign carry = a & b;  // AND gate for carry
endmodule



module wallace_tree_multiplier(input [7:0] a1, b1, output [15:0] result
    );
	 // partial product
	 wire [7:0] p0,p1,p2,p3,p4,p5,p6,p7;
	 wire [7:0] r1, r2, r3, r4, r5, r6, r7, r8;
	 wire [64:0] carry;
	 wire [53:0] sum;
	 
	 

	 assign r1[7:0] =  {8{b1[0]}};
	 assign r2[7:0] =  {8{b1[1]}};
	 assign r3[7:0] =  {8{b1[2]}};
	 assign r4[7:0] =  {8{b1[3]}};
	 assign r5[7:0] =  {8{b1[4]}};
	 assign r6[7:0] =  {8{b1[5]}};
	 assign r7[7:0] =  {8{b1[6]}};
	 assign r8[7:0] =  {8{b1[7]}};
	 
	 assign p0=a1&r1;
	 assign p1=a1&r2;
	 assign p2=a1&r3;
	 assign p3=a1&r4;
	 assign p4=a1&r5;
	 assign p5=a1&r6;
	 assign p6=a1&r7;
	 assign p7=a1&r8;
	
	assign result[0] = p0[0];
	half_adder a1241(p0[1], p1[0], sum[1], carry[1]);
	full_adder a2(p0[2], p1[1], p2[0], sum[2], carry[2]);
	full_adder a3(p0[3], p1[2], p2[1], sum[3], carry[3]);
	full_adder a4(p0[4], p1[3], p2[2], sum[4], carry[4]);	
	half_adder a5(p3[1], p4[0], sum[10], carry[10]);
	full_adder a6(p0[5], p1[4], p2[3], sum[5], carry[5]);
	full_adder a7(p3[2], p4[1], p5[0], sum[11], carry[11]);
	full_adder a8(p0[6], p1[5], p2[4], sum[6], carry[6]);
	full_adder a9(p3[3], p4[2], p5[1], sum[12], carry[12]);
	full_adder a10(p0[7], p1[6], p2[5], sum[7], carry[7]);
	full_adder a11(p3[4], p4[3], p5[2], sum[13], carry[13]);
	half_adder a12(p1[7], p2[6], sum[8], carry[8]);
	full_adder a13(p3[5], p4[4], p5[3], sum[14], carry[14]);
	full_adder a14(p2[7], p3[6], p4[5], sum[9], carry[9]);
	full_adder a15(p3[7], p4[6], p5[5], sum[15], carry[15]);
	half_adder a16(p4[7], p5[6], sum[16], carry[16]);	

	assign result[1] = sum[1];
	half_adder a17(sum[2], carry[1], sum[17], carry[17]);
	full_adder a18(sum[3], carry[2], p3[0], sum[18], carry[18]);
	full_adder a19(sum[4], carry[3], sum[10], sum[19], carry[19]);		
	full_adder a20(sum[5], carry[4], sum[11], sum[20], carry[20]);
	full_adder a21(sum[6], carry[5], sum[12], sum[21], carry[21]);  	
	full_adder a22(sum[7], carry[6], sum[13], sum[22], carry[22]);
	full_adder a23(sum[8], carry[7], sum[14], sum[23], carry[23]);
	full_adder a24(sum[9], carry[8], carry[14], sum[24], carry[24]);
	full_adder a25(carry[9], p6[4], p7[3], sum[29], carry[29]);		
	full_adder a26(carry[15], p6[5], p7[4], sum[30], carry[30]);
	full_adder a27(p5[7], p6[6], p7[5], sum[31], carry[31]);
	half_adder a28(p6[7], p7[6], sum[32], carry[32]);
	half_adder a29(p6[0], carry[11], sum[25], carry[25]);
	full_adder a30(carry[12], p6[1], p7[0], sum[26], carry[26]);
	full_adder a31(carry[13], p6[2], p7[1], sum[27], carry[27]);
	full_adder a32(p5[4], p6[3], p7[2], sum[28], carry[28]);

	assign result[2] = sum[17];
	half_adder a33(sum[18], carry[17], sum[33], carry[33]);
	half_adder a34(sum[19], carry[18], sum[34], carry[34]);
	full_adder a35(sum[20], carry[19], carry[10], sum[35], carry[35]);
	full_adder a36(sum[21], carry[20], sum[25], sum[36], carry[36]);
	full_adder a37(sum[22], carry[21], sum[26], sum[37], carry[37]);
	full_adder a38(sum[23], carry[22], sum[27], sum[38], carry[38]);
	full_adder a39(sum[24], carry[23], sum[28], sum[39], carry[39]);
	full_adder a40(sum[15], carry[24], sum[29], sum[40], carry[40]);
	half_adder a41(sum[16], sum[30], sum[41], carry[41]);
	half_adder a42(carry[16], sum[31], sum[42], carry[42]);
	
	assign result[3] = sum[33];
	half_adder a43(sum[34], carry[33], sum[43], carry[43]);
	half_adder a44(sum[35], carry[34], sum[44], carry[44]);
	half_adder a45(sum[36], carry[35], sum[45], carry[45]);
	full_adder a46(sum[37], carry[36], carry[25], sum[46], carry[46]);
	full_adder a47(sum[38], carry[37], carry[26], sum[47], carry[47]);	
	full_adder a48(sum[39], carry[38], carry[27], sum[48], carry[48]);
	full_adder a49(sum[40], carry[39], carry[28], sum[49], carry[49]);	
	full_adder a50(sum[41], carry[40], carry[29], sum[50], carry[50]);	
	full_adder a51(sum[42], carry[30], carry[41], sum[51], carry[51]);	
	full_adder a52(carry[42], sum[32], carry[31], sum[52], carry[52]);	
	half_adder a53(p7[7], carry[32], sum[53], carry[53]);
	
	assign result[4] = sum[43];
	half_adder a54(sum[44], carry[43], result[5], carry[54]);
	full_adder a55(sum[45], carry[44], carry[54], result[6], carry[55]);	
	full_adder a56(sum[46], carry[45], carry[55], result[7], carry[56]);
	full_adder a57(sum[47], carry[46], carry[56], result[8], carry[57]);
	full_adder a58(sum[48], carry[47], carry[57], result[9], carry[58]);
	full_adder a59(sum[49], carry[48], carry[58], result[10], carry[59]);
	full_adder a60(sum[50], carry[49], carry[59], result[11], carry[60]);
	full_adder a61(sum[51], carry[50], carry[60], result[12], carry[61]);
	full_adder a62(sum[52], carry[51], carry[61], result[13], carry[62]);
	full_adder a63(sum[53], carry[52], carry[62], result[14], carry[32]);
	assign result[15] = carry[53];
      
	 
endmodule

module adder_32( a, b, sum);
input [31:0]a; 
input [31:0]b;
output [31:0]sum;

wire t1,t2, t3,t4, t5, t6, t7, t8, t9, t10, t11, t12, t13, t14, t15, t16, t17, t18, t19, t20, t21, t22, t23, t24, t25, t26, t27, t28, t29, t30, t31, t32; 
half_adder f1(a[0], b[0], sum[0], t1);
full_adder f2(a[1], b[1], t1, sum[1], t2);
full_adder f3(a[2], b[2], t2, sum[2], t3);
full_adder f4(a[3], b[3], t3, sum[3], t4);
full_adder f5(a[4], b[4], t4, sum[4], t5);
full_adder f6(a[5], b[5], t5, sum[5], t6);
full_adder f7(a[6], b[6], t6, sum[6], t7);
full_adder f8(a[7], b[7], t7, sum[7], t8);
full_adder f9(a[8], b[8], t8, sum[8], t9);
full_adder f10(a[9], b[9], t9, sum[9], t10);
full_adder f11(a[10], b[10], t10, sum[10], t11);
full_adder f12(a[11], b[11], t11, sum[11], t12);
full_adder f13(a[12], b[12], t12, sum[12], t13);
full_adder f14(a[13], b[13], t13, sum[13], t14);
full_adder f15(a[14], b[14], t14, sum[14], t15);
full_adder f16(a[15], b[15], t15, sum[15], t16);
full_adder f21(a[16], b[16], t16, sum[16], t17);
full_adder f22(a[17], b[17], t17, sum[17], t18);
full_adder f23(a[18], b[18], t18, sum[18], t19);
full_adder f24(a[19], b[19], t19, sum[19], t20);
full_adder f25(a[20], b[20], t20, sum[20], t21);
full_adder f26(a[21], b[21], t21, sum[21], t22);
full_adder f27(a[22], b[22], t22, sum[22], t23);
full_adder f28(a[23], b[23], t23, sum[23], t24);
full_adder f119(a[24], b[24], t24, sum[24], t25);
full_adder f29(a[25], b[25], t25, sum[25], t26);
full_adder f30(a[26], b[26], t26, sum[26], t27);
full_adder f31(a[27], b[27], t27, sum[27], t28);
full_adder f32(a[28], b[28], t28, sum[28], t29);
full_adder f33(a[29], b[29], t29, sum[29], t30);
full_adder f34(a[30], b[30], t30, sum[30], t31);
full_adder f35(a[31], b[31], t31, sum[31], t32);
endmodule








 
