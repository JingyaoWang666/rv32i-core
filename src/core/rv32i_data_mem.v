//数据存储器
//需要支持 LB/LH/LW/SB/SH/SW（包含字节/半字对齐、符号扩展）。
module rv32i_data_mem (
    input  wire        clk,
    input  wire        rst_n,

    input  wire        mem_read,
    input  wire        mem_write,
    input  wire [2:0]  funct3,      // to distinguish LB/LH/LW/SB/SH/SW
    input  wire [31:0] addr,        // byte address
    input  wire [31:0] write_data,  // from rs2_data

    output reg  [31:0] read_data    // properly sign/zero extended
);
    // TODO: implement byte/halfword/word access with sign extension
endmodule