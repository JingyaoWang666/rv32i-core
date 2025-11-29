//ALU本体：需要支持你表中的所有算术/逻辑/移位/比较操作，并提供比较结果（给分支单元用）。
`include "rv32i_defs.vh"

module rv32i_alu (
    input  wire [31:0] op_a,       // usually rs1_data
    input  wire [31:0] op_b,       // rs2_data or imm
    input  wire [3:0]  alu_op,     // from alu_control

    output reg  [31:0] result,
    output wire        zero,       // (op_a == op_b)
    output wire        lt,         // (op_a < op_b) signed
    output wire        ltu         // (op_a < op_b) unsigned (if you want)
);
    // TODO: implement ALU operations and flags
endmodule