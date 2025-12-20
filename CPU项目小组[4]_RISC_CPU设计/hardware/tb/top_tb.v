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

    wire btn_up;
    assign btn_up = riscv_cpu_top_tb.btn_up;

    wire btn_left;
    assign btn_left = riscv_cpu_top_tb.btn_left;

    wire calc_start;
    assign calc_start = riscv_cpu_top_tb.calc_start;

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

        // 4
        repeat(4) begin          // Generate 4 consecutive pulses
            #100 btn_up_in = 1'b1; // High level for 10ns
            #100 btn_up_in = 1'b0; // Low level for 10ns
        end
    
        // left
        repeat(1) begin          // Generate 1 consecutive pulse
            #100 btn_left_in = 1'b1; // High level for 10ns
            #100 btn_left_in = 1'b0; // Low level for 10ns
        end

        // 2
        repeat(2) begin        // Loop 2 times to generate a pulse
            #100 btn_up_in = 1'b1; // High level for 10ns
            #100 btn_up_in = 1'b0; // Low level for 10ns
        end

        // left
        repeat(2) begin          // Generate 2 consecutive pulses
            #100 btn_left_in = 1'b1; // High level for 10ns
            #100 btn_left_in = 1'b0; // Low level for 10ns
        end

        // 6
        repeat(6) begin        // Loop 6 times to generate a pulse
            #100 btn_up_in = 1'b1; // High level for 10ns
            #100 btn_up_in = 1'b0; // Low level for 10ns
        end

        // start CPU
            #100 btn_center_in = 1'b1; // High level for 100ns
            #100 btn_center_in = 1'b0;

        // run for some cycles
        #10000;
        $finish;
    end

endmodule