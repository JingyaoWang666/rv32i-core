/*ALU控制：根据 alu_op_main（主控制器给的大类：算术/逻辑/分支等）以及 funct3/funct7，
生成真正的 alu_op（内部编码，见 rv32i_defs.vh）*/
`include "rv32i_defs.vh"

module rv32i_alu_control (
    input  wire [1:0]  alu_op_main,   // from main control
    input  wire [2:0]  funct3,        // instr[14:12]
    input  wire [6:0]  funct7,        // instr[31:25]

    output reg  [3:0]  alu_op         // to ALU (see rv32i_defs.vh)
);
    // TODO: implement ALU controlling
    // define local names for alu_op_main values      
    localparam ALU_OP_MAIN_S  = 2'b00; 
    localparam ALU_OP_MAIN_RI = 2'b01;
    localparam ALU_OP_MAIN_B  = 2'b10;  // B:10
    localparam ALU_OP_MAIN_J  = 2'b11;  // J:11
    
    always @(*) begin
        case (alu_op_main)
            ALU_OP_MAIN_S: 
            begin
                // Load / Store -> just addition (address calculation)
                alu_op = `ALU_OP_ADD;
            end

            ALU_OP_MAIN_RI: begin     // R/I-type instructions (eg. ADD, AND, ADDI...) 
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

            ALU_OP_MAIN_B: begin
                // Branch instructions B-type
                alu_op = `ALU_OP_SUB;   // for comparisons in branches
            end

            ALU_OP_MAIN_J: begin        // J-type
                alu_op = `ALU_OP_ADD;   // for adds in jumps
            end 
            
            default: begin
                // defensive: map any other value to HLT
                alu_op = `ALU_OP_HLT;
            end
        endcase
    end

endmodule
