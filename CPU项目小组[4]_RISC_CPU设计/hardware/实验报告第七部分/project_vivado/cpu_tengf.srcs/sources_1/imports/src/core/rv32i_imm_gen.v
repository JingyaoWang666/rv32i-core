// Immediate generation: Assembles imm[31:0] from the instruction based on different instruction types (I/S/B/U/J), and sign-extends it.
/*
We define the imm_type encoding as:
2'b00: I-type
2'b01: S-type
2'b10: B-type
2'b11: J-type       
*/
module rv32i_imm_gen (
    input  wire [31:0] instr,
    input  wire [1:0]  imm_type,    // from control, defines which format to use
    input  wire        imm_u,
    output reg  [31:0] imm_out
);
    // TODO: implement immediate generation for I/S/B/U/J types
    always @(*) begin
        if (!imm_u) begin
            case (imm_type)
                2'b00: begin // I-type (e.g., ADDI, etc.)
                    imm_out = {{20{instr[31]}}, instr[31:20]}; // sign-extend 12-bit immediate
                end
                2'b01: begin // S-type (e.g., SW)
                    imm_out = {{20{instr[31]}}, instr[31:25], instr[11:7]}; // sign-extend 12-bit immediate
                end
                2'b10: begin // B-type (e.g., BEQ, BNE, etc.)
                    imm_out = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0}; // sign-extend 13-bit immediate
                end
                2'b11: begin // J-type (e.g., JAL, JALR)
                    imm_out = {{12{instr[31]}},instr[19:12],instr[20],instr[30:21], 1'b0};
                end
                // U: imm_out = {instr[31:12], 12'b0};  //if support U-type inst,imm_type should be 3 bits
            endcase
        end
        else 
           imm_out = {instr[31:12], 12'b0}; 
    end


endmodule