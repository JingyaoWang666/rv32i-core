//立即数生成：根据不同指令类型（I/S/B/U/J）从指令中拼出 imm[31:0]，扩展为有符号。
/*
imm_type 编码我们定义为：
2'b00：I-type
2'b01：S-type
2'b10：B-type
2'b11：J-type       Note that we temporarily don't support U-type instruction.
*/
module rv32i_imm_gen (
    input  wire [31:0] instr,
    input  wire [1:0]  imm_type,    // from control, defines which format to use
    output reg  [31:0] imm_out
);
    // TODO: implement immediate generation for I/S/B/U/J types
endmodule