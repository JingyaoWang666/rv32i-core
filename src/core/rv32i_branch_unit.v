module rv32i_branch_unit (
    input  wire        branch,        // from main control
    input  wire        jump,          // from main control
    input  wire [2:0]  funct3,        // instr[14:12]
    input  wire [31:0] pc_current,
    input  wire [31:0] rs1_data,
    input  wire [31:0] rs2_data,
    input  wire [31:0] imm,           // sign-extended immediate
    input  wire        is_jalr,       // 1 if opcode is JALR

    output reg  [31:0] pc_next,
    output reg         pc_taken       // 1 if branch/jump is taken
);
    // TODO: implement branch and jump target calculation
    // JAL:   pc_next = pc_current + imm
    // JALR:  pc_next = (rs1_data + imm) & ~1
    // BEQ/BNE/BLT/BGE: pc_next = pc_current + imm (if condition true)
endmodule