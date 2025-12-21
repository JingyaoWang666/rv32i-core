module rv32i_rd_data_mux(
    input wire [31:0] alu_result,
    input wire [31:0] mem_read_data,
    input wire [31:0] pc_current,
    input wire [2:0] mem_to_reg,   // from control
    input wire [31:0] imm,

    output reg [31:0] rd_data      // to write-back stage
);

// mem_to_reg = 0: writeback from mem, 1: from ALU, 2:from PC+4

    always @(*) begin
        case(mem_to_reg)
            3'b000: rd_data = mem_read_data;         // from memory
            3'b001: rd_data = alu_result;            // from ALU
            3'b010: rd_data = pc_current + 32'h4;    // from PC + 4
            3'b011: rd_data = imm;  //for LUI (<<12 has already been done in imm_gen)
            3'b100: rd_data = pc_current + imm;      //for AUIPC ги<<12 has already been done in imm_gen)
            default: rd_data = 32'b0;              
        endcase

    end

endmodule
