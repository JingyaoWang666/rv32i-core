`include "rv32i_defs.vh"

module rv32i_alu_control (
    input  wire [1:0]  alu_op_main,   // from main control
    input  wire [2:0]  funct3,        // instr[14:12]
    input  wire [6:0]  funct7,        // instr[31:25]

    output reg  [3:0]  alu_op         // to ALU (see rv32i_defs.vh)
);
    // TODO: implement ALU control logic
endmodule