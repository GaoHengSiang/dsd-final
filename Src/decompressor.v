module decompressor (
    input      [15:0] inst_i,
    output reg [31:0] inst_o
);

    `include "riscv_define.vh"
    /* verilog_format: off */
/*
| C-inst. | Base instuction (Assembly)            |
|----------|----------------------------------------|
| C.LW     | lw rd’, offset[6:2](rs1’)              |
| C.SW     | sw rs2’, offset[6:2](rs1’)             |
| C.BEQZ   | beq rs1’, x0, offset[8:1]              |
| C.BNEZ   | bne rs1’, x0, offset[8:1]              |
| C.J      | jal x0, offset[11:1]                   |
| C.JAL    | jal x1, offset[11:1]                   |
| C.JR     | jalr x0, rs1, 0                        |
| C.JALR   | jalr x1, rs1, 0                        |
| C.ADDI   | addi rd, rd, nzimm[5:0]                |
| C.ANDI   | andi rd’, rd’, imm[5:0]                |
| C.SLLI   | slli rd, rd, shamt[5:0]                |
| C.SRLI   | srli rd’, rd’, shamt[5:0]              |
| C.SRAI   | srai rd’, rd’, shamt[5:0]              |
| C.MV     | add rd, x0, rs2                        |
| C.ADD    | add rd, rd, rs2                        |
| C.NOP    | addi x0, x0, 0                         |
*/
/* verilog_format: on */


    always @(*) begin
        inst_o = 32'h13;  // NOP
        case (inst_i[1:0])  // synopsys full_case parallel_case
            OP_C0: begin
                if (!inst_i[15]) begin  // 010: LW
                    inst_o = {
                        5'b0,
                        inst_i[5],
                        inst_i[12:10],
                        inst_i[6],
                        2'b00,
                        2'b01,
                        inst_i[9:7],
                        3'b010,
                        2'b01,
                        inst_i[4:2],
                        OPCODE_LOAD
                    };
                end else begin  // 110: SW
                    inst_o = {
                        5'b0,
                        inst_i[5],
                        inst_i[12],
                        2'b01,
                        inst_i[4:2],
                        2'b01,
                        inst_i[9:7],
                        3'b010,
                        inst_i[11:10],
                        inst_i[6],
                        2'b00,
                        OPCODE_STORE
                    };
                end
            end
            OP_C1: begin
                case (inst_i[15:13])  // synopsys full_case parallel_case
                    OP_C1_ADDI: begin
                        inst_o = {
                            {6{inst_i[12]}},
                            inst_i[12],
                            inst_i[6:2],
                            inst_i[11:7],
                            3'b0,
                            inst_i[11:7],
                            OPCODE_OPIMM
                        };
                    end
                    OP_C1_JAL: begin
                        inst_o = {
                            inst_i[12],
                            inst_i[8],
                            inst_i[10:9],
                            inst_i[6],
                            inst_i[7],
                            inst_i[2],
                            inst_i[11],
                            inst_i[5:3],
                            {9{inst_i[12]}},
                            5'b1,
                            OPCODE_JAL
                        };
                    end
                    OP_C1_MISC: begin  // SRLI, SRAI, ANDI
                        case (inst_i[11:10])
                            2'b00, 2'b01: begin  // SRLI, SRAI
                                inst_o = {
                                    1'b0,
                                    inst_i[10],
                                    4'b0,
                                    inst_i[12],
                                    inst_i[6:2],
                                    2'b01,
                                    inst_i[9:7],
                                    3'b101,
                                    2'b01,
                                    inst_i[9:7],
                                    OPCODE_OPIMM
                                };
                            end
                            2'b10: begin  // ANDI
                                inst_o = {
                                    {6{inst_i[12]}},
                                    inst_i[12],
                                    inst_i[6:2],
                                    2'b01,
                                    inst_i[9:7],
                                    3'b111,
                                    2'b01,
                                    inst_i[9:7],
                                    OPCODE_OPIMM
                                };
                            end
                        endcase
                    end
                    OP_C1_J: begin  // J
                        inst_o = {
                            inst_i[12],
                            inst_i[8],
                            inst_i[10:9],
                            inst_i[6],
                            inst_i[7],
                            inst_i[2],
                            inst_i[11],
                            inst_i[5:3],
                            {9{inst_i[12]}},
                            4'b0,
                            ~inst_i[15],
                            OPCODE_JAL
                        };
                    end
                    OP_C1_BEQZ, OP_C1_BNEZ: begin
                        inst_o = {
                            {4{inst_i[12]}},
                            inst_i[6:5],
                            inst_i[2],
                            5'b0,
                            2'b01,
                            inst_i[9:7],
                            2'b00,
                            inst_i[13],
                            inst_i[11:10],
                            inst_i[4:3],
                            inst_i[12],
                            OPCODE_BRANCH
                        };
                    end
                endcase
            end
            OP_C2: begin
                case (inst_i[15:13])  // synopsys full_case parallel_case
                    OP_C2_SLLI: begin
                        inst_o = {
                            6'b0,
                            inst_i[12],
                            inst_i[6:2],
                            inst_i[11:7],
                            3'b001,
                            inst_i[11:7],
                            OPCODE_OPIMM
                        };
                    end
                    OP_C2_JRMVADD: begin
                        if (inst_i[12] == 1'b0) begin  // JR, MV
                            if (inst_i[6:2] == 5'b0) begin  //JR
                                inst_o = {12'b0, inst_i[11:7], 3'b0, 5'b0, OPCODE_JALR};
                            end else begin  // MV
                                inst_o = {7'b0, inst_i[6:2], 5'b0, 3'b0, inst_i[11:7], OPCODE_OP};
                            end
                        end else begin  // JALR, ADD
                            if (inst_i[6:2] == 5'b0) begin  // JALR
                                inst_o = {12'b0, inst_i[11:7], 3'b000, 5'b00001, OPCODE_JALR};
                            end else begin  // ADD
                                inst_o = {
                                    7'b0, inst_i[6:2], inst_i[11:7], 3'b0, inst_i[11:7], OPCODE_OP
                                };
                            end
                        end
                    end
                endcase
            end
        endcase
    end
endmodule
