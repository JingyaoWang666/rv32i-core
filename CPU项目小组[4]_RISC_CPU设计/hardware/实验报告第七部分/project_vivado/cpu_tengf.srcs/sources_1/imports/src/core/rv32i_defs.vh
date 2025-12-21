
`ifndef RV32I_DEFS_VH
`define RV32I_DEFS_VH   //include guard

// ---------------------
// Opcode definitions
// ---------------------
`define OPCODE_LUI      7'b0110111
`define OPCODE_AUIPC    7'b0010111
`define OPCODE_JAL      7'b1101111
`define OPCODE_JALR     7'b1100111
`define OPCODE_BRANCH   7'b1100011
`define OPCODE_LOAD     7'b0000011
`define OPCODE_STORE    7'b0100011
`define OPCODE_OP_IMM   7'b0010011
`define OPCODE_OP_R     7'b0110011

// Funct3 for BRANCH
`define FUNCT3_BEQ      3'b000
`define FUNCT3_BNE      3'b001
`define FUNCT3_BLT      3'b100
`define FUNCT3_BGE      3'b101

// Funct3 for LOAD
`define FUNCT3_LB       3'b000
`define FUNCT3_LH       3'b001
`define FUNCT3_LW       3'b010

// Funct3 for STORE
`define FUNCT3_SB       3'b000
`define FUNCT3_SH       3'b001
`define FUNCT3_SW       3'b010

// Funct3 for OP-IMM and OP
`define FUNCT3_ADD_SUB  3'b000
`define FUNCT3_SLL      3'b001
`define FUNCT3_SLT      3'b010
`define FUNCT3_XOR      3'b100
`define FUNCT3_SRL_SRA  3'b101
`define FUNCT3_OR       3'b110
`define FUNCT3_AND      3'b111

// Funct7 for OP / OP-IMM shifts
`define FUNCT7_ADD_SRL_SLL 7'b0000000
`define FUNCT7_SUB_SRA     7'b0100000

// ---------------------
// ALU operation encoding
// (for internal alu_op control signal)
// ---------------------
`define ALU_OP_ADD   4'd0
`define ALU_OP_SUB   4'd1
`define ALU_OP_AND   4'd2
`define ALU_OP_OR    4'd3
`define ALU_OP_XOR   4'd4
`define ALU_OP_SLL   4'd5
`define ALU_OP_SRL   4'd6
`define ALU_OP_SRA   4'd7
`define ALU_OP_SLT   4'd8
`define ALU_OP_HLT   4'd15

//instruction memory
`define INSTR_MEM_DEPTH 128
`define INSTR_MEM_WIDTH 7  //2^10=1024


// ... add more if needed

`endif // RV32I_DEFS_VH