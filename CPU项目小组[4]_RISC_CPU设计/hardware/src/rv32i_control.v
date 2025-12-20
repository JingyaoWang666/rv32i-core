// Main controller (based on Opcode): rv32i_control.v
// This control module only outputs general control signals based on the opcode.
// Specific operations based on funct3, etc., are handled by modules like alu_control and imm_gen.
// In general, it supports: I-type (including JALR/LOAD/OP_IMM), B-type, J-type, S-type, R-type instructions.

/* Outputs various control signals:

alu_src: Selects the second operand for the ALU, either from rs2 or imm. 1 for imm, 0 for rs2.
mem_read / mem_write: Read/write enable signals for data_mem.
mem_to_reg: Selects the data source for writing back to a register. We define: 00: data_mem, 01: ALU result, 10: PC+4.
reg_write: Register write enable.
branch / jump: Branch/jump signals, output to the branch_unit module.
is_jalr: Signal to distinguish between JAL and JALR instructions.
imm_type: Immediate type signal, output to the imm_gen module.
alu_op_main: ALU operation type signal, passed to rv32i_alu_control for further refinement.

We define the imm_type encoding as:
2'b00: I-type
2'b01: S-type
2'b10: B-type
2'b11: J-type       Note that we temporarily don't support U-type instruction.
*/
`include "rv32i_defs.vh"

module rv32i_control (
    input  wire [6:0]  opcode,

    output reg        alu_src,     //used for alu_opb_mux module. 1: use imm, 0: use rs2
    output reg        mem_read,    //used for data_mem module
    output reg        mem_write,   //used for data_mem module
    output reg [1:0]  mem_to_reg,  //used for rd_data_mux,in write-back session. 0: writeback from mem, 1: from ALU, 2:from PC+4
    output reg        reg_write,   //used for rd_we in reg_file module.
    output reg        branch,      // for conditional branches
    output reg        jump,        // for JAL / JALR
    output reg        is_jalr,     //distinguish JAL from JALR
    output reg [1:0]  imm_type,    // e.g. 00:I, 01:S, 10:B, 11:J  (temporarily not support other types of instr)
    output reg [1:0]  alu_op_main  // high-level ALUOp to alu_control. See the rules in alu_control.v localparam.
);

    // implement main control logic (Decode)


always @(*) begin
    alu_src = 0;
    mem_read = 0;
    mem_write = 0;
    mem_to_reg = 0;
    reg_write = 0;
    branch = 0;
    jump = 0;
    is_jalr = 0;
    imm_type = 0;
    alu_op_main = 0;

    case(opcode)    // U-type instructions are not supported temporarily
        `OPCODE_OP_R:begin
            alu_src = 0;
            mem_read = 0;
            mem_write = 0;
            mem_to_reg = 2'b01;
            reg_write = 1;
            branch = 0;
            jump = 0;
            is_jalr = 0;
            imm_type = 2'b00;
            alu_op_main = 2'b01;
        end
        `OPCODE_STORE:begin
            alu_src = 1;
            mem_read = 0;
            mem_write = 1;
            mem_to_reg = 2'b00;
            reg_write = 0;
            branch = 0;
            jump = 0;
            is_jalr = 0;
            imm_type = 2'b01;
            alu_op_main = 2'b00;
        end
        `OPCODE_OP_IMM:begin
            alu_src = 1;
            mem_read = 0;
            mem_write = 0;
            mem_to_reg = 2'b01;
            reg_write = 1;
            branch = 0;
            jump = 0;
            is_jalr = 0;
            imm_type = 2'b00;
            alu_op_main = 2'b01;
        end
        `OPCODE_LOAD:begin
            alu_src = 1;
            mem_read = 1;
            mem_write = 0;
            mem_to_reg = 2'b00;
            reg_write = 1;
            branch = 0;
            jump = 0;
            is_jalr = 0;
            imm_type = 2'b00;
            alu_op_main = 2'b00;
        end
        `OPCODE_JALR:begin
            alu_src = 0;
            mem_read = 0;
            mem_write = 0;
            mem_to_reg = 2'b10;
            reg_write = 1;
            branch = 0;
            jump = 1;
            is_jalr = 1;
            imm_type = 2'b00;
            alu_op_main = 2'b00;
        end
        `OPCODE_BRANCH:begin
            alu_src = 1;
            mem_read = 0;
            mem_write = 0;
            mem_to_reg = 2'b00; //don't care
            reg_write = 0;
            branch = 1;
            jump = 0;
            is_jalr = 0;
            imm_type = 2'b10;
            alu_op_main = 2'b11;
        end
        `OPCODE_JAL:begin  //JAL
            alu_src = 0;
            mem_read = 0;
            mem_write = 0;
            mem_to_reg = 2'b10;
            reg_write = 1;
            branch = 0;
            jump = 1;
            is_jalr = 0;
            imm_type = 2'b11;
            alu_op_main = 2'b10;
        end
    endcase
end



endmodule