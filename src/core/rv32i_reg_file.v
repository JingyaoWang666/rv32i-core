//寄存器堆
module rv32i_reg_file (
    input  wire        clk,
    input  wire        rst_n,
    // read ports
    input  wire [4:0]  rs1_addr,
    input  wire [4:0]  rs2_addr,
    output reg [31:0] rs1_data,
    output reg [31:0] rs2_data,
    // write port
    input  wire        rd_we,      // write enable
    input  wire [4:0]  rd_addr,
    input  wire [31:0] rd_data
);
    // TODO: implement 32x32 register file with x0 = 0
    reg [31:0] reg_file [0:31]; // 32 registers of 32 bits each
    integer i;
    // Initialize registers to 0 on reset
    always @(negedge rst_n or posedge clk) begin
        if (!rst_n) begin
            for (i = 0; i < 32; i = i + 1) begin
                reg_file[i] <= 32'b0;
            end
        end else if (rd_we && (rd_addr != 5'b0)) begin
            reg_file[rd_addr] <= rd_data; // Write data to register if write enable is high and rd_addr is not x0
        end
    end

    always @(*) begin
        // Read data from registers
        rs1_data = (rs1_addr == 5'b0) ? 32'b0 : reg_file[rs1_addr]; // x0 is always 0
        rs2_data = (rs2_addr == 5'b0) ? 32'b0 : reg_file[rs2_addr]; // x0 is always 0
    end

endmodule