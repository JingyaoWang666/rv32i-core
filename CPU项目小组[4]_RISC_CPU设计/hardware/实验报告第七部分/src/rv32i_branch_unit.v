// Branch and Jump Unit. Overall, this module supports six instructions: JAL/JALR/BEQ/BNE/BLT/BGE.
/* Responsible for calculating:
pc_next
pc_taken (whether to take the jump/branch target)
Based on:
branch / jump control signals
funct3 (to distinguish between BEQ/BNE/BLT/BGE)
rs1_data / rs2_data
pc_current / imm
jal / jalr flag (is_jalr is a signal generated separately in the control module based on the opcode and passed in)

The control module is responsible for decoding the opcode. This branch module is responsible for: distinguishing more specific instructions, determining if the condition is met (and generating pc_taken), and calculating pc_next.
*/
module rv32i_branch_unit (
    input  wire        branch,        // from main control
    input  wire        jump,          // from main control
    input  wire [2:0]  funct3,        // instr[14:12]
    input  wire [31:0] pc_current,
    input  wire [31:0] rs1_data,
    input  wire [31:0] rs2_data,
    input  wire [31:0] imm,           // signed immediate
    input  wire        is_jalr,       // 1 if opcode is JALR

    output reg  [31:0] pc_next,
    output wire        pc_taken       // 1 if branch/jump is taken
);
    // implement branch and jump target calculation
    // JAL:   pc_next = pc_current + imm
    // JALR:  pc_next = (rs1_data + imm) & 32'b1бнбн10
    // BEQ/BNE/BLT/BGE: pc_next = pc_current + imm (if condition true)

    // pc logic: if condition==0, pc_next = pc_current + 4 (32'h4/32'o4/32'd4)
    
    reg condition;
    wire [31:0] pc_target;
    
    assign pc_taken = (branch && condition) || jump; 
    
    //For B-type instr, condition's bool value calculation
    always @(*) begin
        if (branch) begin
            case(funct3)
                `FUNCT3_BEQ: condition = rs1_data == rs2_data; //BEQ
                `FUNCT3_BNE: condition = rs1_data != rs2_data; //BNE
                `FUNCT3_BLT: condition = $signed(rs1_data) < $signed(rs2_data);    //BLT (signed comparison)
                `FUNCT3_BGE: condition = $signed(rs1_data) >= $signed(rs2_data);   //BGE (signed comparison)
                default: condition = 0; //undefined funct3 for branch (BLTU/BGEU) -> not taken
            endcase
        end
        else 
            condition = 0;
    end

    //pc_next calculation
    // Step 1: Calculate the target address if a branch/jump were to be taken
    assign pc_target = is_jalr ? ((rs1_data + imm) & ~32'b1) : (pc_current + imm);

    // Step 2: Select pc_next based on whether the branch/jump is actually taken
    always @(*) begin
        if (pc_taken)
            pc_next = pc_target; // JAL, JALR, or a taken Branch
        else
            pc_next = pc_current + 32'd4; // Not-taken branch or normal instruction
    end


endmodule