`include "rv32i_defs.vh"

module rv32i_control (
    input  wire [6:0]  opcode,

    output wire        alu_src,     // 1: use imm, 0: use rs2
    output wire        mem_read,
    output wire        mem_write,
    output wire        mem_to_reg,  // 1: writeback from mem, 0: from ALU/PC+4
    output wire        reg_write,
    output wire        branch,      // for conditional branches
    output wire        jump,        // for JAL / JALR
    output wire [1:0]  imm_type,    // e.g. 00:I, 01:S, 10:B, 11:U/J  (you can define)
    output wire [1:0]  alu_op_main  // high-level ALUOp to alu_control
);
    // TODO: implement main control logic
endmodule