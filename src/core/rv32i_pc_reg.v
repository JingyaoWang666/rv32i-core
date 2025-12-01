//PC寄存器 (pc后边的那一级流水线)
module rv32i_pc_reg (
    input  wire        clk,
    input  wire        rst_n,      // asynchronous active low reset
    input  wire [31:0] next_pc,
    output reg  [31:0] pc
);
    //implement PC update logic
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n)
            pc <= 32'b0;
        else
            pc <= next_pc;
    end


endmodule