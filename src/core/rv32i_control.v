//主控制器（根据 Opcode）：rv32i_control.v
//这里的control仅根据opcode输出大概的控制信号，具体根据funct3等细化操作码在alu_control、imm_gen等各模块自行完成
//总的来说支持：I-type(including JALR/LOAD/OP_IMM)、B-type、J-type、S-type、R-type 的指令

/*输出各种控制信号：

alu_src：ALU 第二个操作数来自 rs2 还是 imm. 规定1表示来自rs2, 0表示来自imm。
mem_read / mem_write
mem_to_reg：写回来源是否是内存
reg_write：是否写寄存器
branch / jump
alu_op_main：交给 rv32i_alu_control 进一步细化

imm_type 编码我们定义为：
2'b00：I-type
2'b01：S-type
2'b10：B-type
2'b11：J-type       Note that we temporarily don't support U-type instruction.
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

localparam [6:0] JALR_INSTR = 7'b1100111;
localparam [6:0] LOAD_INSTR = 7'b0000011;
localparam [6:0] OP_IMM_INSTR = 7'b0010011;
localparam [6:0] B_TYPE_INSTR = 7'b1100011;
localparam [6:0] J_TYPE_INSTR = 7'b1101111;
localparam [6:0] S_TYPE_INSTR = 7'b0100011;
localparam [6:0] R_TYPE_INSTR = 7'b0110011;
//localparam [6:0] U_TYPE_INSTR = 7'b0110111;   not support yet

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

    case(opcode)
        R_TYPE_INSTR:begin
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
        S_TYPE_INSTR:begin
            alu_src = 1;
            mem_read = 0;
            mem_write = 1;
            mem_to_reg = 2'b00;
            reg_write = 0;
            branch = 0;
            jump = 0;
            is_jalr = 0;
            imm_type = 2'b01;
            alu_op_main = 2'b01;
        end
        OPP_IMM_INSTR:begin
            alu_src = 1;
            mem_read = 0;
            mem_write = 0;
            mem_to_reg = 2'b01;
            reg_write = 1;
            branch = 0;
            jump = 0;
            is_jalr = 0;
            imm_type = 2'b00;
            alu_op_main = 2'b00;
        end
        LOAD_INSTR:begin
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
        JALR_INSTR:begin
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
        B_TYPE_INSTR:begin
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
        J_TYPE_INSTR:begin  //JAL
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