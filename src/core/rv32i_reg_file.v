module rv32i_reg_file (
    input  wire        clk,
    input  wire        rst_n,
    // read ports
    input  wire [4:0]  rs1_addr,
    input  wire [4:0]  rs2_addr,
    output wire [31:0] rs1_data,
    output wire [31:0] rs2_data,
    // write port
    input  wire        rd_we,      // write enable
    input  wire [4:0]  rd_addr,
    input  wire [31:0] rd_data
);
    // TODO: implement 32x32 register file with x0 = 0
endmodule