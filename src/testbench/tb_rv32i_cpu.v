`timescale 1ns/1ps

module tb_rv32i_cpu();

    reg clk;
    wire clk_out;
    reg rst_n;
    reg calc_start;
    reg [31:0] gcd_a;
    reg [31:0] gcd_b;  

    wire [31:0] gcd_result;

    wire [31:0] pc;
    wire [31:0] instr;
    wire [6:0]  opcode;
    wire        reg_write;
    wire [4:0]  rd_addr;
    wire [31:0] alu_result;

    clock_divider uut2(
        .clk_in(clk),
        .rst_n(rst_n),
        .clk_out(clk_out)
    );

    // 2. instantiate the CPU
    rv32i_cpu uut (
        .clk(clk_out),
        .rst_n(rst_n),
        .calc_start(calc_start),
        .gcd_a(gcd_a),
        .gcd_b(gcd_b),
        .gcd_result(gcd_result)
    );

    assign pc = uut.pc;
    assign instr = uut.instr;
    assign opcode = uut.opcode;
    assign reg_write = uut.reg_write;
    assign rd_addr = uut.rd;
    assign alu_result = uut.alu_result;
    
    // 3. initialize clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz  10ns
    end

    // 4. initialize test sequences
    initial begin
        
        rst_n = 0;      
        calc_start = 0;
        gcd_a = 32'd60; // a = 15
        gcd_b = 32'd24; // b = 10
        #20;            
        calc_start = 1'b1; 
        rst_n = 1;      //reset released
        #60
        calc_start = 1'b0;
        
        // run for long enough time to complete GCD calculation
        #2000;

        // stop the simulation
        $finish;
    end

    // 5. monitor signals
    initial begin
        $monitor("Time=%0t, PC=%d, Instr=0x%h, branch=%b, jump=%b, cond_met=%b, pc_taken=%b, Opcode=0b%b, RegWrite=%b, RdAddr=%d, ALU_Result=%d, GCD_Result=%d",
                 $time,
                 pc,
                 instr,
                 uut.branch, // Directly access the internal branch signal of uut
                 uut.jump,   // Directly access the internal jump signal of uut
                 uut.rv32i_branch_unit.condition, // Access the internal condition of the branch unit
                 uut.rv32i_branch_unit.pc_taken,  // Access the internal jump flag of the branch unit
                 
                 opcode,
                 reg_write,
                 rd_addr,
                 alu_result,
                 gcd_result);
    end

endmodule