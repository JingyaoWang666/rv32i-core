`timescale 1ns/1ps

module cpu_tb();
    reg clk, rst_n, calc_start;
    wire [15:0] led;
    
    rv32i_cpu u1(
    .clk(clk),
    .rst_n(rst_n),
    .calc_start(calc_start),  //activate GCD calculation
    .led(led)   // we constrain gcd_result[15:0] to led[15:0]
);
    
    initial begin
    clk = 0;
    forever #5 clk = ~clk;
    end
    
    initial begin
    rst_n = 0;
    calc_start = 0;
    #30
    rst_n = 1;
    calc_start = 1;
    #3000
    $finish();
    end




endmodule