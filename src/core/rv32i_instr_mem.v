//指令存储器
//地址是字节地址，通常内部用 addr[31:2] 作为字寻址索引
module rv32i_instr_mem (
    input  wire [31:0] addr,        // byte address from PC
    output wire [31:0] instr
);
    // TODO: implement instruction memory
endmodule