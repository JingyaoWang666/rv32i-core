module rv32i_imm_gen (
    input  wire [31:0] instr,
    input  wire [1:0]  imm_type,    // from control, defines which format to use
    output reg  [31:0] imm_out
);
    // TODO: implement immediate generation for I/S/B/U/J types
endmodule