//主控制器（根据 Opcode）：rv32i_control.v
/*输出各种控制信号：

alu_src：ALU 第二个操作数来自 rs2 还是 imm
mem_read / mem_write
mem_to_reg：写回来源是否是内存
reg_write：是否写寄存器
branch / jump
alu_op_main：交给 rv32i_alu_control 进一步细化

imm_type 编码你们自己定义，比如：
2'b00：I-type
2'b01：S-type
2'b10：B-type
2'b11：U/J-type（再用其他信号区分）
*/
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
    assign alu_op_main = opcode[6:5]; // example
    assign alu_src = opcode[4]; 
    

endmodule