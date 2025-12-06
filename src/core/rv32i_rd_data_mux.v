module rv32i_rd_data_mux(
    input wire [31:0] alu_result,
    input wire [31:0] mem_read_data,
    input wire [31:0] pc_current,
    input wire [1:0] mem_to_reg,   // from control

    output reg [31:0] rd_data      // to write-back stage
);

// mem_to_reg = 0: writeback from mem, 1: from ALU, 2:from PC+4

    always @(*) begin
        case(mem_to_reg)
            2'b00: rd_data = mem_read_data;         // from memory
            2'b01: rd_data = alu_result;            // from ALU
            2'b10: rd_data = pc_current + 32'h4;    // from PC + 4
            default: rd_data = 32'b0;              
        endcase

    end

endmodule
