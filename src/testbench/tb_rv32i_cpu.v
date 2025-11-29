`timescale 1ns/1ps

module tb_rv32i_cpu;
    reg clk;
    reg rst_n;

    // instantiate DUT
    rv32i_cpu dut (
        .clk   (clk),
        .rst_n (rst_n)
    );

    // clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100 MHz
    end

    // reset and simulation control
    initial begin
        rst_n = 0;
        #100;
        rst_n = 1;

        // run for some cycles
        #10000;
        $finish;
    end

    // optional: waveform dump
    initial begin
        $dumpfile("rv32i_cpu.vcd");
        $dumpvars(0, tb_rv32i_cpu);
    end
endmodule