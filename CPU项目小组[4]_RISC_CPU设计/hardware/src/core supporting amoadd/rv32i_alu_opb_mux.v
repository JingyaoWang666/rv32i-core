// mux to select between rs2 and immediate for ALU operand B

module rv32i_alu_opb_mux (
    input  wire        alu_src,     // 1: use imm, 0: use rs2
    input  wire [31:0] rs2_data,    // rs2 from register file
    input  wire [31:0] imm,         // immediate (already sign-extended)
    output wire [31:0] op_b         // final operand B to ALU
);

    assign op_b = (alu_src == 1'b1) ? imm : rs2_data;

endmodule
 