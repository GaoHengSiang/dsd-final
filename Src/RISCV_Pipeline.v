module RISCV_Pipeline(
    input         clk,
    input         rst_n,
//----------I cache interface-------
    input         ICACHE_stall,
    output        ICACHE_ren,
    output        ICACHE_wen,
    output [29:0] ICACHE_addr, //assume word address
    input  [31:0] ICACHE_rdata,
    output [31:0] ICACHE_wdata,
//----------D cache interface-------
    input         DCACHE_stall,
    output        DCACHE_ren,
    output        DCACHE_wen,
    output [29:0] DCACHE_addr, //assume word address
    input  [31:0] DCACHE_rdata,
    output [31:0] DCACHE_wdata,
//--------------PC-----------------
    output [31:0] PC
    );

    
    //---------IF stage---------
    wire         IF_stall;
    wire         IF_flush;
    wire  [2:0]  IF_pc_src;
    wire  [31:0] IF_ID_inst_ppl;
    wire  [31:0] IF_ID_pc_ppl;

    //TODO: finish this 
    assign IF_pc_src = {ID_branch_taken, // };

    //---------ID stage---------
    wire         ID_stall, ID_flush;
    wire [4:0] ID_regfile_rs1, ID_regfile_rs2;
    wire [31:0] ID_regfile_rs1_data, ID_regfile_rs2_data;
    wire        ID_branch_taken;
    wire [31:0] ID_pc_branch;

    wire  [4:0] ID_EX_rd_ppl;
    wire [31:0] ID_EX_rs1_data_ppl, ID_EX_rs2_data_ppl;
    wire [31:0] ID_EX_imm_ppl;
    wire        ID_EX_alu_src_ppl;
    wire [31:0] ID_EX_pc_ppl_out;


    register_file reg_file(
        .clk(clk),
        .rst_n(rst_n),
        .rs1(ID_regfile_rs1),
        .rs2(ID_regfile_rs2),
        .rd(), //TODO: handle rd from WB stage
        .wen(),
        .wrdata(),
        .rddata1(ID_regfile_rs1_data),
        .rddata2(ID_regfile_rs2_data)
    );

    RISCV_IF IF(
        .clk(clk),
        .rst_n(rst_n),
        .stall(IF_stall),
        .flush(IF_flush),
        .pc_src(IF_pc_src),
        .pc_branch(ID_pc_branch),
        .pc_j(), // TODO: Connect to EX stage JAL or JALR result
        .ICACHE_stall(ICACHE_stall),
        .ICACHE_ren(ICACHE_ren),
        .ICACHE_wen(ICACHE_wen),
        .ICACHE_addr(ICACHE_addr),
        .ICACHE_rdata(ICACHE_rdata),
        .ICACHE_wdata(ICACHE_wdata),
        .inst_ppl(IF_ID_inst_ppl), 
        .pc_ppl(IF_ID_pc_ppl) 
    );

    RISCV_ID ID(
        .clk(clk),
        .rst_n(rst_n),
        .stall(ID_stall),
        .flush(ID_flush),
        .inst_ppl(IF_ID_inst_ppl),
        .pc_ppl(IF_ID_pc_ppl),
        .rd_ppl(ID_EX_rd_ppl),
        .rs1_data_ppl(ID_EX_rs1_data_ppl),
        .rs2_data_ppl(ID_EX_rs2_data_ppl),
        .imm_ppl(ID_EX_imm_ppl),
        .alu_src_ppl(ID_EX_alu_src_ppl),
        .pc_ppl_out(ID_EX_pc_ppl_out),
        //----------register_file interface-------------
        .regfile_rs1(ID_regfile_rs1),
        .regfile_rs2(ID_regfile_rs2),
        .regfile_rs1_data(ID_regfile_rs1_data),
        .regfile_rs2_data(ID_regfile_rs2_data),
        //----------PC generation-------------------------
        .branch_taken(ID_branch_taken),
        .pc_branch(ID_pc_branch)
    );



endmodule