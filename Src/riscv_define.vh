// RISC-V related definitions
parameter OPCODE_OP     = 7'b01_100_11;
parameter OPCODE_OPIMM  = 7'b00_100_11;
parameter OPCODE_LOAD   = 7'b00_000_11;
parameter OPCODE_STORE  = 7'b01_000_11;
parameter OPCODE_BRANCH = 7'b11_000_11;
parameter OPCODE_JAL    = 7'b11_011_11;
parameter OPCODE_JALR   = 7'b11_001_11;

// compressed instruction
parameter OP_C0 = 2'b00;
parameter OP_C1 = 2'b01;
parameter OP_C2 = 2'b10;

parameter OP_C0_LW = 3'b010;
parameter OP_C0_SW = 3'b110;

parameter OP_C1_ADDI = 3'b000;
parameter OP_C1_JAL = 3'b001;
parameter OP_C1_MISC = 3'b100; // SRLI, SRAI, ANDI
parameter OP_C1_J = 3'b101; 
parameter OP_C1_BEQZ = 3'b110; 
parameter OP_C1_BNEZ = 3'b111;

parameter OP_C2_SLLI = 3'b000;
parameter OP_C2_JRMVADD = 3'b100;