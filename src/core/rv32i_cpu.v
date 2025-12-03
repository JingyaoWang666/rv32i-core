//CPU顶层
//把所有模块连起来。外部可以只暴露时钟/复位和一些调试端口（比如当前 PC）。
`include "rv32i_defs.vh"

module rv32i_cpu (
    input  wire        clk,
    input  wire        rst_n
    // 你也可以在这里加一些 debug 输出，比如：
    // output wire [31:0] dbg_pc
    // output wire [31:0] dbg_reg_x10
);
    // TODO:
    // 1. instantiate rv32i_pc
    rv32i_pc pc_inst (
        .clk(clk),
        .rst_n(rst_n),
        .pc(pc_current),
        .pc_next(pc_next)
    );
    // 2. instantiate rv32i_instr_mem
    // 3. decode instr fields: opcode, funct3, funct7, rs1, rs2, rd, imm...
    // 4. instantiate rv32i_control, rv32i_imm_gen, rv32i_reg_file
    // 5. instantiate rv32i_alu_control, rv32i_alu
    // 6. instantiate rv32i_data_mem, rv32i_branch_unit
    // 7. mux for ALU src (rs2 or imm)
    // 8. mux for writeback data (ALU result / mem_read_data / PC+4 / LUI/AUIPC)
    // 9. connect pc_next from branch_unit or pc+4
endmodule