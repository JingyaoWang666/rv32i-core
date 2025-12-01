//instruction memory(指令存储器)
//addr即为当前pc输出，通常内部用 addr[31:2] 作为字寻址索引 
//(这是因为本rv32i的寻址粒度为1byte/8bit,即最小数据存储单位为8bit，8位数据算作一个整体.而指令有32位，addr的低两位用来指示当前8位是指令的哪一部分，4*8=32)
`include "rv32i_defs.vh"
module rv32i_instr_mem (
    input  wire [31:0] addr,        // byte address from PC
    output wire [31:0] instr
);
    reg [31:0] instr_mem [`INSTR_MEM_DEPTH:0];
    assign instr = instr_mem[addr[`INSTR_MEM_WIDTH+2-1:2]];

//往指令存储器中存数据的行为，我们考虑在testbench中完成。

endmodule