/*ALU控制：根据 alu_op_main（主控制器给的大类：算术/逻辑/分支等）以及 funct3/funct7，
生成真正的 alu_op（内部编码，见 rv32i_defs.vh）*/
`include "rv32i_defs.vh"

module rv32i_alu_control (
    input  wire [1:0]  alu_op_main,   // from main control
    input  wire [2:0]  funct3,        // instr[14:12]
    input  wire [6:0]  funct7,        // instr[31:25]

    output reg  [3:0]  alu_op,         // to ALU (see rv32i_defs.vh)
);
    // TODO: implement ALU control logic
    // define local names for alu_op_main values to improve readability
    localparam ALU_OP_MAIN_I    = 2'b00;
    localparam ALU_OP_MAIN_BJ = 2'b11;
    localparam ALU_OP_MAIN_RS  = 2'b01;
    
    always @(*) begin
        case (alu_op_main)
            ALU_OP_MAIN_RS: begin
                // R-type arithmetic & logic instructions  & S-type instructions
                case (funct3)
                    `FUNCT3_ADD_SUB: begin
                        // ADD or SUB (SUB indicated by funct7 == FUNCT7_SUB_SRA)
                        if (funct7 == `FUNCT7_SUB_SRA) begin
                            alu_op = `ALU_OP_SUB;   // SUB
                        end else begin
                            alu_op = `ALU_OP_ADD;   // ADD
                        end
                    end
                    `FUNCT3_SLL: begin
                        alu_op = `ALU_OP_SLL;
                    end
                    `FUNCT3_SLT: begin
                        alu_op = `ALU_OP_SLT;
                    end
                    `FUNCT3_XOR: begin
                        alu_op = `ALU_OP_XOR;
                    end
                    `FUNCT3_SRL_SRA: begin
                        // SRL or SRA (SRA distinguished by funct7)
                        if (funct7 == `FUNCT7_SUB_SRA) begin
                            alu_op = `ALU_OP_SRA;
                        end else begin
                            alu_op = `ALU_OP_SRL;
                        end
                    end
                    `FUNCT3_OR: begin
                        alu_op = `ALU_OP_OR;
                    end
                    `FUNCT3_AND: begin
                        alu_op = `ALU_OP_AND;
                    end
                    default: begin
                        alu_op = `ALU_OP_HLT;  // safe default
                    end
                endcase
            end

            ALU_OP_MAIN_I: begin     // I-type instructions (eg. ADDI, LW, SW) 
                case (funct3)
                    `FUNCT3_ADD_SUB: begin
                        alu_op = (funct7 == `FUNCT7_SUB_SRA) ? `ALU_OP_SUB : `ALU_OP_ADD;
                    end
                    `FUNCT3_SLL: begin
                        alu_op = `ALU_OP_SLL;
                    end
                    `FUNCT3_SLT: begin
                        alu_op = `ALU_OP_SLT;
                    end
                    `FUNCT3_XOR: begin
                        alu_op = `ALU_OP_XOR;
                    end
                    `FUNCT3_SRL_SRA: begin
                        alu_op = (funct7 == `FUNCT7_SUB_SRA) ? `ALU_OP_SRA : `ALU_OP_SRL;
                    end
                    `FUNCT3_OR: begin
                        alu_op = `ALU_OP_OR;
                    end
                    `FUNCT3_AND: begin
                        alu_op = `ALU_OP_AND;
                    end
                    default: begin
                        alu_op = `ALU_OP_HLT;  // safe default
                    end
                endcase
            end

            ALU_OP_MAIN_BJ: begin
                // Branch instructions B-type / J-type
                ;  // No ALU operation needed for branches/jumps
            end
            
            default: begin
                // defensive: map any other value to HLT
                alu_op = `ALU_OP_HLT;
            end
        endcase
    end

endmodule
