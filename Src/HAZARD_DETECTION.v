//code by Yu Siang
module HAZARD_DETECTION (
    input ID_EX_MemRead, 
    input ID_EX_mul,
    input [4:0]ID_EX_RegisterRd, ID_RegisterRs1, ID_RegisterRs2,
    output load_mul_use_hazard//load use or mul use

);
assign load_mul_use_hazard = (ID_EX_MemRead||ID_EX_mul) && ((ID_EX_RegisterRd == ID_RegisterRs1) || (ID_EX_RegisterRd == ID_RegisterRs2)) && (ID_EX_RegisterRd != 5'd0);
    //added: no load_use hazard if rd = 0 -- Heng Siang
endmodule

