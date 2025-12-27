//ALU module for RV32I processor
`include "rv32i_defs.vh" 

module rv32i_alu (
    input  wire [31:0] op_a,       // usually rs1_data
    input  wire [31:0] op_b,       // rs2_data or imm
    input  wire [3:0]  alu_op,     // from alu_control

    output reg  [31:0] result,
    output wire        zero,       // (result == 0)
    output wire        eq,         // (op_a == op_b) 
    output wire        lt,         // (op_a < op_b) signed
    output wire        ltu         // (op_a < op_b) unsigned (if you want)
);
    // TODO: implement ALU operations and flags
    always @(*) begin
        result = 32'b0;
        case(alu_op)
            `ALU_OP_SUB: result = op_a - op_b;
            `ALU_OP_ADD: result = op_a + op_b;
            `ALU_OP_AND: result = op_a & op_b;
            
            `ALU_OP_OR : result = op_a | op_b;
            `ALU_OP_XOR: result = op_a ^ op_b;
            `ALU_OP_SLL: result = op_a << op_b[4:0];
            `ALU_OP_SRL: result = op_a >> op_b[4:0];
            `ALU_OP_SRA: result = $signed(op_a) >>> op_b[4:0];
            `ALU_OP_SLT: result = ($signed(op_a) < $signed(op_b)) ? 1'b1 : 1'b0;
            `ALU_OP_HLT: ;
            // No need to default
        endcase
    end

    assign zero = (result == 32'b0);

    assign eq = (op_a == op_b);
    assign lt = $signed(op_a) < $signed(op_b);
    assign ltu = op_a < op_b;
    

endmodule