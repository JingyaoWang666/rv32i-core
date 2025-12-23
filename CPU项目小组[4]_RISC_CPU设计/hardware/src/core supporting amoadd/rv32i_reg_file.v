//register files
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
    input  wire [31:0] rd_data,

    // GCD 
    input                  calc_start,  // GCD initialize signal
    input      [31:0]      gcd_a,       // GCD input a
    input      [31:0]      gcd_b,       // GCD input b
    output reg [31:0]      gcd_result   // GCD calculation result
);

// Define dedicated GCD registers
// x28=GCD_A, x29=GCD_B, x10=GCD_RESULT, x31=GCD_START

localparam REG_GCD_A      = 5'd28;
localparam REG_GCD_B      = 5'd29;
localparam REG_GCD_RESULT = 5'd10;
localparam REG_GCD_START  = 5'd31;


    // implement 32x32 register file with x0 = 0
    reg [31:0] reg_file [0:31]; // 32 registers of 32 bits each
    integer i;
    // Initialize registers to 0 on reset
    always @(negedge rst_n or posedge clk) begin
        if (!rst_n) begin
            for (i = 0; i < 28; i = i + 1) begin
                reg_file[i] <= 32'b0;
            end
            reg_file[31] <= {{31{1'b0}},calc_start};
            reg_file[30] <= 32'b0;
            reg_file[29] <= gcd_a;
            reg_file[28] <= gcd_b;
            gcd_result <= 32'b0; // Reset GCD result register
        end else if (rd_we && (rd_addr != 5'b0)) begin
            // When writing to GCD_RESULT register, synchronize gcd_result output
            if (rd_addr == REG_GCD_RESULT) begin
                reg_file[rd_addr] <= rd_data; // Write data to register if write enable is high and rd_addr is not x0
                gcd_result <= rd_data;
            end

            else if((rd_addr != REG_GCD_A) && (rd_addr != REG_GCD_B) && (rd_addr != REG_GCD_START)) begin
                reg_file[rd_addr] <= rd_data; // Write data to register if write enable is high and rd_addr is not x0
            end
        end
    end

// register 1 read
always @(*) begin
    if(rs1_addr == 5'b0) begin
        rs1_data = 32'b0; // x0 is always 0
    end 
    else if (rs1_addr == REG_GCD_A) begin
        rs1_data = gcd_a;
    end
    else if (rs1_addr == REG_GCD_B) begin
        rs1_data = gcd_b;
    end
    else if (rs1_addr == REG_GCD_START) begin
        rs1_data = {{31{1'b0}}, calc_start};
    end

    else begin
        rs1_data = reg_file[rs1_addr];
    end
end

// register 2 read
always @(*) begin
    if(rs2_addr == 5'b0) begin
        rs2_data = 32'b0;
    end 
    else if (rs2_addr == REG_GCD_A) begin
        rs2_data = gcd_a;
    end
    else if (rs2_addr == REG_GCD_B) begin
        rs2_data = gcd_b;
    end
    else if (rs2_addr == REG_GCD_START) begin
        rs2_data = {{31{1'b0}}, calc_start}; 
    end
    
    else begin
        rs2_data = reg_file[rs2_addr];
    end
end

endmodule