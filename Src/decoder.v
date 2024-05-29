module decoder(
    input  [31:0] inst_i,
    output  [4:0] rs1_o, rs2_o, rd_o,
    output [31:0] imm_o,
    output        alusrc_o,
    output [3:0]  aluop_o,
    output        jal_o,
    output        jalr_o,
    output        branch_o,
    output        bne_o,
    output        mem_to_reg_o,
    output        mem_wen_o,
    output        mem_ren_o,
    output        reg_wen_o
);

    // RISC-V related definitions
    localparam OPCODE_OP     = 7'b01_100_11;
    localparam OPCODE_OPIMM  = 7'b00_100_11;
    localparam OPCODE_LOAD   = 7'b00_000_11;
    localparam OPCODE_STORE  = 7'b01_000_11;
    localparam OPCODE_BRANCH = 7'b11_000_11;
    localparam OPCODE_JAL    = 7'b11_011_11;
    localparam OPCODE_JALR   = 7'b11_001_11;
    
    // immgen
    localparam I_IMM = 0;
    localparam S_IMM = 1;
    localparam SB_IMM = 2;
    localparam UJ_IMM = 3;

    // ALU operations definition
    localparam ADD       = 0;
    localparam SUB       = 1;
    localparam AND       = 2;
    localparam OR        = 3;
    localparam XOR       = 4;
    localparam SRA       = 5;
    localparam SRL       = 6;
    localparam SLL       = 7;
    localparam SLT       = 8;
    localparam EQ        = 9;

    wire [4:0] rs1, rs2, rd;
    wire [6:0] opcode;
    wire [6:0] funct7;
    wire [2:0] funct3;

    wire [31:0] itype_imm, stype_imm, sbtype_imm, ujtype_imm;
    assign itype_imm = {{(32-12){inst_i[31]}} , inst_i[31:20]};
    assign stype_imm = {{(32-12){inst_i[31]}}, inst_i[31:25], inst_i[11:7]};
    assign sbtype_imm = {{(32-13){inst_i[31]}}, inst_i[31], inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
    assign ujtype_imm = {{(32-21){inst_i[31]}}, inst_i[31], inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};

    reg [2:0] imm_select;
    reg [3:0] alu_op;
    reg alu_src;
    reg reg_wen, mem_to_reg, mem_wen, mem_ren;
    reg branch, jal, jalr;
    reg bne; // we do subtraction for BEQ, but if we encounter BNE, we need to negate the result

    
    reg [31:0] imm_ext;


    assign opcode = inst_i[6:0];
    assign funct7 = inst_i[31:25];
    assign funct3 = inst_i[14:12];
    assign rs1 = inst_i[19:15];
    assign rs2 = inst_i[24:20];
    assign rd  = inst_i[11:7];

    // output assignment
    assign rs1_o = rs1;
    assign rs2_o = rs2;
    assign rd_o  = rd;
    assign imm_o = imm_ext;
    assign alusrc_o = alu_src;
    assign aluop_o = alu_op;
    assign jal_o = jal;
    assign jalr_o = jalr;
    assign branch_o = branch;
    assign bne_o = bne;
    assign mem_to_reg_o = mem_to_reg;
    assign mem_wen_o = mem_wen;
    assign mem_ren_o = mem_ren;
    assign reg_wen_o = reg_wen;

    // decode logic
    always @(*) begin 
        alu_op = ADD;
        reg_wen = 0;
        mem_to_reg = 0;
        mem_ren = 0;
        mem_wen = 0;
        branch = 0;
        bne = 0;
        jal = 0;
        jalr = 0;
        alu_src = 0;
        imm_select = I_IMM;
        case (opcode) // synopsys full_case parallel_case
            OPCODE_OP: begin
                reg_wen = 1;
                mem_to_reg = 0;
                case (funct3) 
                    3'b000: begin
                        if (!funct7[5])  // ADD
                            alu_op = ADD; 
                        else   // SUB
                            alu_op = SUB;
                    end
                    3'b001: begin // SLL
                        alu_op = SLL;
                    end
                    3'b010: begin // SLT
                        alu_op = SLT;
                    end
                    3'b100: begin // XOR
                        alu_op = XOR;
                    end
                    3'b101: begin
                        if (!funct7[5]) // SRL: funct7 = 0000000
                            alu_op = SRL;
                        else  // SRA: funct7 = 0100000
                            alu_op = SRA;
                    end
                    3'b110: begin // OR
                        alu_op = OR;
                    end
                    3'b111: begin // AND
                        alu_op = AND;
                    end
                endcase
            end
            OPCODE_OPIMM: begin
                alu_src = 1;
                reg_wen = 1;
                imm_select = I_IMM;
                case (funct3) 
                    3'b000: begin // ADDI
                        alu_op = ADD;
                    end
                    3'b010: begin // SLTI
                        alu_op = SLT;
                    end
                    3'b100: begin // XORI
                        alu_op = XOR;
                    end
                    3'b110: begin // ORI
                        alu_op = OR;
                    end
                    3'b111: begin // ANDI
                        alu_op = AND;
                    end
                    3'b001: begin // SLLI
                        alu_op = SLL;
                    end
                    3'b101: begin
                        if (!funct7[5]) // SRLI
                            alu_op = SRL;
                        else // SRAI
                            alu_op = SRA;
                    end
                endcase
            end
            OPCODE_LOAD: begin
                alu_src = 1;
                alu_op = ADD;
                mem_ren = 1;
                reg_wen = 1;
                mem_to_reg = 1;
                imm_select = I_IMM;
            end
            OPCODE_STORE: begin
                alu_src = 1;
                alu_op = ADD;
                mem_wen = 1;
                imm_select = S_IMM;
            end
            OPCODE_BRANCH: begin
                alu_op = ADD;
                alu_src = 1;
                branch = 1;
                imm_select = SB_IMM;
                if (funct3[0] == 1) begin // BNE: funct3 == 3'b001, BEQ: funct3 == 3'b000
                    bne = 1;
                end else begin
                    bne = 0;
                end
            end
            OPCODE_JAL: begin 
                jal = 1;
                alu_op = ADD;
                alu_src = 1;
                reg_wen = 1;
                imm_select = UJ_IMM;
            end
            OPCODE_JALR: begin
                jalr = 1;
                alu_op = ADD;
                alu_src = 1;
                reg_wen = 1;
                imm_select = I_IMM;
            end

        endcase
    end
    
    always @(*) begin
        imm_ext = 0;
        case (imm_select)
            I_IMM: imm_ext = itype_imm;
            S_IMM: imm_ext = stype_imm;
            SB_IMM: imm_ext = sbtype_imm;
            UJ_IMM: imm_ext = ujtype_imm;
        endcase
    end
    
endmodule

