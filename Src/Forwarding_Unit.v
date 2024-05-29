module Forwarding_Unit(
    input  EX_MEM_RegWrite, MEM_WB_RegWrite,
    input  [4:0]EX_MEM_RegisterRd,ID_EX_RegisterRs1,ID_EX_RegisterRs2,
    input  [4:0]MEM_WB_RegisterRd,
    output [1:0]ForwardA, ForwardB
);


assign ForwardA = (EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0) && (EX_MEM_RegisterRd == ID_EX_RegisterRs1)) ? 2'b10 : 
                  ((MEM_WB_RegWrite && (MEM_WB_RegisterRd != 0) && !(EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0) && (EX_MEM_RegisterRd == ID_EX_RegisterRs1)) && (MEM_WB_RegisterRd == ID_EX_RegisterRs1)) ? 2'b01 : 2'b00);

assign ForwardB = (EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0) && (EX_MEM_RegisterRd == ID_EX_RegisterRs2)) ? 2'b10 : 
                  ((MEM_WB_RegWrite && (MEM_WB_RegisterRd != 0) && !(EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0) && (EX_MEM_RegisterRd == ID_EX_RegisterRs2)) && (MEM_WB_RegisterRd == ID_EX_RegisterRs2)) ? 2'b01 : 2'b00);
// if (EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0) && (EX_MEM_RegisterRd == ID_EX_RegisterRs1)) ForwardA = 2'b10;
// else if (MEM_WB_RegWrite && (MEM_WB_RegisterRd != 0) && !(EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0) && (EX_MEM_RegisterRd = ID_EX_RegisterRs1)) && (MEM_WB_RegisterRd = ID_EX_RegisterRs1)) ForwardA = 2'b01;
// else ForwardA = 2'b00;

// if (EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0) && (EX_MEM_RegisterRd == ID_EX_RegisterRs2)) ForwardB = 2'b10;
// else if (MEM_WB_RegWrite&& (MEM_WB_RegisterRd != 0) && !(EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0) && (EX_MEM_RegisterRd = ID_EX_RegisterRs2)) && (MEM_WB_RegisterRd = ID_EX_RegisterRs2)) ForwardB = 2'b01;
// else ForwardB = 2'b00;



endmodule