//code by: Yu Siang
//altered by: Heng Siang
module Forwarding_Unit(
    input  EX_MEM_RegWrite, MEM_WB_RegWrite,
    input  [4:0]EX_MEM_RegisterRd,ID_EX_RegisterRs1,ID_EX_RegisterRs2,
    input  [4:0]MEM_WB_RegisterRd,
    //output [1:0]ForwardA, ForwardB //handle the complexities withing this module

    input [31: 0] rd_data,//data source for MEM/WB forwarding
    //data source(s) for EX/MEM forwarding
    input [31: 0] EX_MEM_alu_result,
    input [31: 0] EX_MEM_PC_step,
    input EX_MEM_jump,//we need this signal to determine which of the above
    
    output reg         forward_A_flag,
    output reg [31: 0] forward_A_dat,
    output reg         forward_B_flag,
    output reg [31: 0] forward_B_dat,
    output reg         mul_forward_A_flag,
    output reg [31: 0] mul_forward_A_dat,
    output reg         mul_forward_B_flag,
    output reg [31: 0] mul_forward_B_dat

);

wire [1:0] ForwardA, ForwardB;
wire       ForwardA_EX_MEM, ForwardA_MEM_WB;
wire       ForwardB_EX_MEM, ForwardB_MEM_WB;

assign ForwardA_EX_MEM = (EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0) && (EX_MEM_RegisterRd == ID_EX_RegisterRs1));
assign ForwardB_EX_MEM = (EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0) && (EX_MEM_RegisterRd == ID_EX_RegisterRs2));

assign ForwardA_MEM_WB = ((MEM_WB_RegWrite && (MEM_WB_RegisterRd != 0) && (MEM_WB_RegisterRd == ID_EX_RegisterRs1)));
assign ForwardB_MEM_WB = ((MEM_WB_RegWrite && (MEM_WB_RegisterRd != 0) && (MEM_WB_RegisterRd == ID_EX_RegisterRs2)));

assign ForwardA = {ForwardA_EX_MEM, ForwardA_MEM_WB};
assign ForwardB = {ForwardB_EX_MEM, ForwardB_MEM_WB};

/*
assign ForwardA = (EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0) && (EX_MEM_RegisterRd == ID_EX_RegisterRs1)) ? 2'b10 : 
                  ((MEM_WB_RegWrite && (MEM_WB_RegisterRd != 0) && (MEM_WB_RegisterRd == ID_EX_RegisterRs1)) ? 2'b01 : 2'b00);

assign ForwardB = (EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0) && (EX_MEM_RegisterRd == ID_EX_RegisterRs2)) ? 2'b10 : 
                  ((MEM_WB_RegWrite && (MEM_WB_RegisterRd != 0) && (MEM_WB_RegisterRd == ID_EX_RegisterRs2)) ? 2'b01 : 2'b00);
*/


always @(*)begin
    //default
    forward_A_flag = |ForwardA;
    forward_B_flag = |ForwardB;
    forward_A_dat = rd_data;
    forward_B_dat = rd_data;
    
    mul_forward_A_flag = ForwardA_MEM_WB;
    mul_forward_B_flag = ForwardB_MEM_WB;
    mul_forward_A_dat = rd_data;
    mul_forward_B_dat = rd_data;

    if (ForwardA[1]) begin
        if (EX_MEM_jump) begin
            forward_A_dat = EX_MEM_PC_step;
        end else begin
            forward_A_dat = EX_MEM_alu_result;
        end
    end else if (ForwardA[0]) begin
        forward_A_dat = rd_data;
    end

    if (ForwardB[1]) begin
        if (EX_MEM_jump) begin
            forward_B_dat = EX_MEM_PC_step;
        end else begin
            forward_B_dat = EX_MEM_alu_result;
        end
    end else if (ForwardB[0]) begin
            forward_B_dat = rd_data;
    end

end


endmodule