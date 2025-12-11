`timescale 1ns/1ps

module tb_riscv_cpu_top();
    reg clk;
    reg rst_n;
    reg btn_center_in;
    reg btn_up_in;
    reg btn_left_in;
    reg btn_down_in;
    reg btn_right_in;

    wire [31:0] pc;
    assign pc = riscv_cpu_top_tb.rv32i_cpu.rv32i_pc_reg.pc;

    wire calc_start;
    assign calc_start = riscv_cpu_top_tb.calc_start;

    wire btn_up;
    assign btn_up = riscv_cpu_top_tb.btn_up;

   riscv_cpu_top riscv_cpu_top_tb (
        .clk   (clk),
        .rst_n (rst_n),
        .btn_center_in (btn_center_in),
        .btn_up_in     (btn_up_in),
        .btn_left_in   (btn_left_in),
        .btn_down_in   (btn_down_in),
        .btn_right_in  (btn_right_in),
        .seg_an        (),
        .seg_seg       ()
    );
    
    // 3. initialize clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz  10ns
    end

    // 4. initialize test sequences
    initial begin
        rst_n = 0;
        {btn_center_in, btn_up_in, btn_down_in, btn_left_in, btn_right_in} = 5'b0;
        #100;
        rst_n = 1;

        // 生成5个连续脉冲
        repeat(5) begin          // 循环5次生成脉冲
            #100 btn_up_in = 1'b1; // 高电平持续10ns
            #100 btn_up_in = 1'b0; // 低电平持续10ns
        end
    
        // 生成3个连续脉冲
        repeat(3) begin          // 循环3次生成脉冲
            #100 btn_left_in = 1'b1; // 高电平持续10ns
            #100 btn_left_in = 1'b0; // 低电平持续10ns
        end

        // 生成1个连续脉冲
        repeat(1) begin        // 循环1次生成脉冲
            #100 btn_up_in = 1'b1; // 高电平持续10ns
            #100 btn_up_in = 1'b0; // 低电平持续10ns
        end

        // 启动cpu计算
            #100 btn_center_in = 1'b1; // 高电平持续100ns
            #100 btn_center_in = 1'b0; 
        
        // run for some cycles
        #10000;
        $finish;
    end

endmodule