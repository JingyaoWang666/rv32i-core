//instruction memory(指令存储器)
//addr即为当前pc输出，通常内部用 addr[31:2] 作为字寻址索引 

//(这是因为本rv32i的寻址粒度为1byte/8bit,即pc输出的1表示1个字节。而本设计中固定指令长度为32bit=4byte=1word，如果4字节对齐的话，
//即指令地址都以4的倍数开头，pc的低两位始终是0，更新是也是pc+4，低两位没有信息量。但为了接近通用地址总线/32位字节地址，与数据访问
//总线相统一，且其他复杂功能会用到低两位，所以这里还是把低两位写上了。）

`include "rv32i_defs.vh"
module rv32i_instr_mem (
    input  wire [31:0] addr,        // byte address from PC
    output wire [31:0] instr
);
    
reg [31:0] instr_mem [0:`INSTR_MEM_DEPTH-1];

// 初始化inst_mem，加载汇编生成的机器码
initial begin
    // initialize the starting address
    $readmemh("inst_mem_init.mem", instr_mem, 0, `INSTR_MEM_DEPTH-1);
end

assign instr = instr_mem[addr[`INSTR_MEM_WIDTH+2-1:2]];

endmodule