module RISCV_Pipeline (
    input         clk,
    input         rst_n,
    //----------I cache interface-------
    input         ICACHE_stall,
    output        ICACHE_ren,
    output        ICACHE_wen,
    output [29:0] ICACHE_addr,   //assume word address
    input  [31:0] ICACHE_rdata,
    output [31:0] ICACHE_wdata,
    //----------D cache interface-------
    input         DCACHE_stall,
    output        DCACHE_ren,
    output        DCACHE_wen,
    output [29:0] DCACHE_addr,   //assume word address
    input  [31:0] DCACHE_rdata,
    output [31:0] DCACHE_wdata,
    //--------------PC-----------------
    output [31:0] PC             //what is this one for?
);


    //---------IF stage---------
    wire        IF_stall;
    wire        IF_flush;
    wire [ 1:0] IF_pc_src;
    wire [31:0] IF_ID_inst_ppl;
    wire [31:0] IF_ID_pc_ppl;
    wire        IF_ID_compressed_ppl;
    wire         IF_ID_branch_taken_ppl;
    //---------ID stage---------
    wire ID_stall, ID_flush;
    wire [4:0] ID_regfile_rs1, ID_regfile_rs2;
    wire [31:0] ID_regfile_rs1_data, ID_regfile_rs2_data;
    wire [4:0] ID_EX_rs1, ID_EX_rs2;

    //-------ID/EX pipeline reg------------
    wire       EX_stall;
    wire [4:0] ID_EX_rd_ppl;
    wire [31:0] ID_EX_rs1_data_ppl, ID_EX_rs2_data_ppl;
    wire [31:0] ID_EX_imm_ppl;
    wire        ID_EX_alu_src_ppl;
    wire [ 3:0] ID_EX_alu_ctrl_ppl;
    wire [31:0] ID_EX_pc_ppl_out;
    wire        ID_EX_jal_ppl,
                ID_EX_jalr_ppl,
                ID_EX_branch_ppl,
                ID_EX_bne_ppl,
                ID_EX_mem_ren_ppl,
                ID_EX_mem_wen_ppl,
                ID_EX_mem_to_reg_ppl,
                ID_EX_reg_wen_ppl,
                ID_EX_compressed_ppl,
                ID_EX_branch_taken_ppl;

    //------EX/MEM pipeline reg------------
    wire [31:0] EX_MEM_alu_result;
    wire [31:0] EX_MEM_mem_wdata;
    wire [ 4:0] EX_MEM_rd;
    wire [31:0] EX_MEM_PC_step;
    wire EX_MEM_memrd, EX_MEM_memwr, EX_MEM_mem2reg, EX_MEM_regwr, EX_MEM_jump;


    //------MEM/WB pipeline reg------------
    wire [31:0] MEM_WB_alu_result, MEM_WB_mem_dat, MEM_WB_PC_step;
    wire [4:0] MEM_WB_rd;
    wire MEM_WB_mem2reg, MEM_WB_regwr, MEM_WB_jump;//********************MEM needs to have jump signal
                                                   //so that PC+4 can be stored into reg

    //LOOP BACK: reg or wires that go in the reverse direction
    reg [31:0] rd_data;
    //no_block
    wire EX_jump_noblock, 
         EX_prediction_incorrect,
         EX_feedback_valid;
    wire make_branch_correction;
    wire [31: 0] EX_PC_result_noblock;


    // forwarding & hazard detection
    wire [31:0] forward_A_dat, forward_B_dat;
    wire forward_A_flag, forward_B_flag;
    wire load_use_hazard;

    reg  regfile_wen;
    reg mem_wb_valid_r, mem_wb_valid_w;
    //wire assignment 
    assign make_branch_correction = EX_prediction_incorrect && EX_feedback_valid;

    //FIXME: hazard detection
    
    assign IF_pc_src = {make_branch_correction, EX_jump_noblock}; // pc_src[1] = branch pc_src[0] = jalr || jal
    assign IF_stall = (DCACHE_stall && (EX_MEM_memwr || EX_MEM_mem2reg))||load_use_hazard;
    assign IF_flush = make_branch_correction || EX_jump_noblock;
    assign ID_stall = DCACHE_stall && (EX_MEM_memwr || EX_MEM_mem2reg);
    assign ID_flush = make_branch_correction || EX_jump_noblock || load_use_hazard; // TODO: plus load-use hazard
    assign EX_stall = DCACHE_stall && (EX_MEM_memwr || EX_MEM_mem2reg);


    Forwarding_Unit Forward_Unit (
        .EX_MEM_RegWrite  (EX_MEM_regwr),
        .MEM_WB_RegWrite  (MEM_WB_regwr),
        .EX_MEM_RegisterRd(EX_MEM_rd),
        .ID_EX_RegisterRs1(ID_EX_rs1),
        .ID_EX_RegisterRs2(ID_EX_rs2),
        .MEM_WB_RegisterRd(MEM_WB_rd),

        //loop backs
        .rd_data(rd_data),  //data source for MEM/WB forwarding
        //data source(s) for EX/MEM forwarding
        .EX_MEM_alu_result(EX_MEM_alu_result),
        .EX_MEM_PC_step(EX_MEM_PC_step),
        .EX_MEM_jump(EX_MEM_jump),  //we need this signal to determine which of the above

        //forwarding signal and data to EX
        .forward_A_flag(forward_A_flag),
        .forward_A_dat (forward_A_dat),
        .forward_B_flag(forward_B_flag),
        .forward_B_dat (forward_B_dat)

    );

    HAZARD_DETECTION hazard_unit (
        .IF_RegisterRs1(ID_regfile_rs1),
        .IF_RegisterRs2(ID_regfile_rs2),
        .ID_EX_MemRead(ID_EX_mem_ren_ppl),
        .ID_EX_RegisterRd(ID_EX_rd_ppl),
        .load_use_hazard(load_use_hazard)
    );


    register_file regfile (
        .clk  (clk),
        .rst_n(rst_n),
        .rs1  (ID_regfile_rs1),
        .rs2  (ID_regfile_rs2),

        //LOOP BACK FROM WB STAGE
        .rd(MEM_WB_rd),
        .wen(regfile_wen),  //looped back from WB stage
        .wrdata(rd_data),

        .rddata1(ID_regfile_rs1_data),
        .rddata2(ID_regfile_rs2_data)
    );

    RISCV_IF IF (
        .clk(clk),
        .rst_n(rst_n),
        //feedback paths
        .stall(IF_stall),
        .flush(IF_flush),
        .pc_src(IF_pc_src), //feedback from EX stage
        .pc_branch(EX_PC_correction),//feedback from EX stage
        .pc_j(EX_PC_result_noblock), // Feedback from EX stage
        .prediction_correct(!EX_prediction_incorrect),//tells the saturation counter if its prediction is correct
        .feedback_valid(EX_feedback_valid),//if the instruction in EX is not a branch or stalling...
        .load_use_hazard(load_use_hazard),
        
        .ICACHE_stall(ICACHE_stall),
        .ICACHE_ren(ICACHE_ren),
        .ICACHE_wen(ICACHE_wen),
        .ICACHE_addr(ICACHE_addr),
        .ICACHE_rdata(ICACHE_rdata),
        .ICACHE_wdata(ICACHE_wdata),
        .inst_ppl(IF_ID_inst_ppl),
        .pc_ppl(IF_ID_pc_ppl),
        .compressed_ppl(IF_ID_compressed_ppl),
        .branch_taken_ppl(IF_ID_branch_taken_ppl),//idicates if the branch was predicted to be taken
        .PC(PC)
    );

    RISCV_ID ID (
        .clk  (clk),
        .rst_n(rst_n),
        .stall(ID_stall),
        .flush(ID_flush),

        .inst_ppl(IF_ID_inst_ppl),
        .pc_ppl(IF_ID_pc_ppl),
        .compressed_ppl(IF_ID_compressed_ppl),        .branch_taken_in(IF_ID_branch_taken_ppl),

        //ID/EX pipeline
        .rd_ppl(ID_EX_rd_ppl),
        .rs1_ppl(ID_EX_rs1),
        .rs2_ppl(ID_EX_rs2),
        .rs1_data_ppl(ID_EX_rs1_data_ppl),
        .rs2_data_ppl(ID_EX_rs2_data_ppl),
        .imm_ppl(ID_EX_imm_ppl),
        .alu_src_ppl(ID_EX_alu_src_ppl),
        .alu_ctrl_ppl(ID_EX_alu_ctrl_ppl),
        .pc_ppl_out(ID_EX_pc_ppl_out),
        .jal_ppl(ID_EX_jal_ppl),
        .jalr_ppl(ID_EX_jalr_ppl),
        .branch_ppl(ID_EX_branch_ppl),
        .bne_ppl(ID_EX_bne_ppl),
        .mem_ren_ppl(ID_EX_mem_ren_ppl),
        .mem_wen_ppl(ID_EX_mem_wen_ppl),
        .mem_to_reg_ppl(ID_EX_mem_to_reg_ppl),
        .reg_wen_ppl(ID_EX_reg_wen_ppl),
        .compressed_ppl_out(ID_EX_compressed_ppl),
        .branch_taken_ppl(ID_EX_branch_taken_ppl),
        //**********************************************OTHER CONTROLS FOR EX

        //----------register_file interface-------------
        .regfile_rs1(ID_regfile_rs1),
        .regfile_rs2(ID_regfile_rs2),
        .regfile_rs1_data(ID_regfile_rs1_data),
        .regfile_rs2_data(ID_regfile_rs2_data)
    );

    EX_STAGE EX (
        .clk(clk),
        .rst_n(rst_n),
        //PIPELINE INPUT FROM ID/EX REGISTER
        .PC_in(ID_EX_pc_ppl_out),
        .rs1_dat_in(ID_EX_rs1_data_ppl),
        .rs2_dat_in(ID_EX_rs2_data_ppl),
        .imm(ID_EX_imm_ppl),
        //various control signals input
        .alusrc_in(ID_EX_alu_src_ppl),
        .aluctrl_in(ID_EX_alu_ctrl_ppl),
        .jal_in(ID_EX_jal_ppl),
        .jalr_in(ID_EX_jalr_ppl),
        .branch_in(ID_EX_branch_ppl),
        .bne_in(ID_EX_bne_ppl),
        .stall(EX_stall),
        .branch_taken_in(ID_EX_branch_taken_ppl),
    //transparent for this stage
        .rd_in(ID_EX_rd_ppl),
        .memrd_in(ID_EX_mem_ren_ppl),
        .memwr_in(ID_EX_mem_wen_ppl),
        .mem2reg_in(ID_EX_mem_to_reg_ppl),
        .regwr_in(ID_EX_reg_wen_ppl),
        .compressed_in(ID_EX_compressed_ppl),
        // forwarding
        // didn't add PC stall yet
        .forward_A_flag(forward_A_flag),
        .forward_A_dat(forward_A_dat),
        .forward_B_flag(forward_B_flag),
        .forward_B_dat(forward_B_dat),



        //PIPELINE OUTPUT TO EX/MEM REGISTER
        .alu_result(EX_MEM_alu_result),
        .mem_wdata(EX_MEM_mem_wdata),
        .rd_out(EX_MEM_rd),
        .PC_step(EX_MEM_PC_step),
        //various control signals output
        .memrd_out(EX_MEM_memrd),
        .memwr_out(EX_MEM_memwr),
        .mem2reg_out(EX_MEM_mem2reg),
        .regwr_out(EX_MEM_regwr),
        .jump_out(EX_MEM_jump),

        //direct output, no register blocking
        .jump_noblock(EX_jump_noblock),  //should correct PC immediately
        .PC_result_noblock(EX_PC_result_noblock),
        .PC_correction(EX_PC_correction),
        .prediction_incorrect(EX_prediction_incorrect),
        .feedback_valid(EX_feedback_valid)
    );


    MEM_STAGE MEM (
        .clk(clk),
        .rst_n(rst_n),
        //PIPELINE INPUT FROM EX/MEM REGISTER
        .alu_result_in(EX_MEM_alu_result),
        .mem_wdata_in(EX_MEM_mem_wdata),
        //various control signals input
        .memrd_in(EX_MEM_memrd),
        .memwr_in(EX_MEM_memwr),
        //transparent
        .PC_step_in(EX_MEM_PC_step),
        .rd_in(EX_MEM_rd),
        .mem2reg_in(EX_MEM_mem2reg),
        .regwr_in(EX_MEM_regwr),
        .jump_in(EX_MEM_jump),
        // ********************************************ONE SIGNAL SHOULD INDICATE JUMP

        //PIPELINE OUTPUT TO MEM/WB REGISTER
        .alu_result_out(MEM_WB_alu_result),
        .mem_dat(MEM_WB_mem_dat),
        .PC_step_out(MEM_WB_PC_step),
        .rd_out(MEM_WB_rd),
        //various control signals output
        .mem2reg_out(MEM_WB_mem2reg),
        .regwr_out(MEM_WB_regwr),
        .jump_out(MEM_WB_jump),
        //D_CACHE_INTERFACE, output not register blocked
        .DCACHE_stall(DCACHE_stall),
        .DCACHE_ren(DCACHE_ren),
        .DCACHE_wen(DCACHE_wen),
        .DCACHE_addr(DCACHE_addr),  //assume word address
        .DCACHE_rdata(DCACHE_rdata),
        .DCACHE_wdata(DCACHE_wdata)

    );

    always @(*) begin
        rd_data = MEM_WB_alu_result;
        mem_wb_valid_w = !DCACHE_stall;
        regfile_wen = mem_wb_valid_r && MEM_WB_regwr;
        //****************************maybe we can finally utilize PARALLEL CASE here
        if (MEM_WB_mem2reg) begin
            rd_data = MEM_WB_mem_dat;
        end else if (MEM_WB_jump) begin
            rd_data = MEM_WB_PC_step;
        end
    end

    always @(posedge clk) begin
        if (!rst_n) mem_wb_valid_r <= 1;
        else mem_wb_valid_r <= mem_wb_valid_w;
    end

endmodule
