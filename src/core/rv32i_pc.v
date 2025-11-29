//PC寄存器
module rv32i_pc (
    input  wire        clk,
    input  wire        rst_n,      // active low reset
    input  wire [31:0] next_pc,
    output reg  [31:0] pc
);
    // TODO: implement PC update logic
endmodule