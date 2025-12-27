`include "rv32i_defs.vh"

module rv32i_cpu (
    input  wire        clk,
    input  wire        rst_n,

    // GCD related IO signals
    input  wire             calc_start,  //activate GCD calculation
    input  wire [31:0]      gcd_a,       // input A(width 32)
    input  wire [31:0]      gcd_b,       // input B
    output wire [31:0]      gcd_result   // output
);

wire        pc_taken;
wire [31:0] next_pc;
wire [31:0] pc;
wire [31:0] instr;

wire [6:0]  opcode;
wire [2:0]  funct3;
wire [6:0]  funct7;
wire [4:0]  rs1;
wire [4:0]  rs2;
wire [4:0]  rd;

wire [1:0]  imm_type;
wire [31:0] imm;

wire        alu_src;  
wire        mem_read;  
wire        mem_write; 
wire [1:0]  mem_to_reg;
wire        reg_write; 
wire        branch;    
wire        jump;      
wire        is_jalr;     
wire [1:0]  alu_op_main;

wire [31:0] rs1_data;
wire [31:0] rs2_data;

wire [3:0] alu_op;
wire [31:0] op_b;
wire [31:0] alu_result;
wire        zero;
wire        eq;
wire        lt;
wire        ltu;

wire [31:0] mem_read_data;
wire [31:0] rd_data;

assign rd_data = alu_result;

rv32i_pc_reg rv32i_pc_reg(
    .clk(clk),
    .rst_n(rst_n),
    .next_pc(next_pc),
    .pc(pc)
);

rv32i_instr_mem rv32i_instr_mem(
    .addr(pc),
    .instr(instr)
);

rv32i_instr_decoder rv32i_instr_decoder(
    .instr(instr),
    .opcode(opcode),
    .funct3(funct3),
    .funct7(funct7),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd)
);

rv32i_imm_gen rv32i_imm_gen(
    .instr(instr),
    .imm_type(imm_type),
    .imm_out(imm)
);

rv32i_control rv32i_control(
    .opcode(opcode),
    .alu_src(alu_src),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .mem_to_reg(mem_to_reg),
    .reg_write(reg_write),
    .branch(branch),
    .jump(jump),
    .is_jalr(is_jalr),
    .imm_type(imm_type),
    .alu_op_main(alu_op_main)
);

rv32i_alu_control rv32i_alu_control(
    .alu_op_main(alu_op_main),
    .funct3(funct3),
    .funct7(funct7),
    .alu_op(alu_op)
);

rv32i_alu_opb_mux rv32i_alu_opb_mux(
    .alu_src(alu_src),
    .rs2_data(rs2_data),
    .imm(imm),
    .op_b(op_b)
);

rv32i_reg_file rv32i_reg_file(
    .clk(clk),
    .rst_n(rst_n),
    .rs1_addr(rs1),
    .rs2_addr(rs2),
    .rs1_data(rs1_data),
    .rs2_data(rs2_data),
    .rd_we(reg_write),
    .rd_addr(rd),
    .rd_data(rd_data),
    
    // gcd related ports
    .calc_start            (calc_start),
    .gcd_a                 (gcd_a),
    .gcd_b                 (gcd_b),
    .gcd_result            (gcd_result)
);

rv32i_alu rv32i_alu(
    .op_a(rs1_data),
    .op_b(op_b),
    .alu_op(alu_op),
    .result(alu_result),
    .zero(zero),
    .eq(eq),
    .lt(lt),
    .ltu(ltu)
);

rv32i_branch_unit rv32i_branch_unit(
       .branch(branch),
       .jump(jump),
       .funct3(funct3),
       .pc_current(pc),
       .rs1_data(rs1_data),
       .rs2_data(rs2_data),
       .imm(imm),
       .is_jalr(is_jalr),
       .pc_next(next_pc),
       .pc_taken(pc_taken)
);
// commmented out for lower space usage and power consumption
/*
rv32i_rd_data_mux rv32i_rd_data_mux(
    .mem_to_reg(mem_to_reg),
    .alu_result(alu_result),
    .mem_read_data(mem_read_data),
    .pc_current(pc),
    .rd_data(rd_data) 
);
*/

/*
rv32i_data_mem rv32i_data_mem(
    .clk(clk),
    .rst_n(rst_n),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .funct3(funct3),
    .addr(alu_result),
    .write_data(rs2_data),
    .read_data(mem_read_data) 
);*/

endmodule