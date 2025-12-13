module clk_divider_100M_to_50kHz (
    input  wire clk_100M,   // 输入100MHz时钟
    input  wire rst_n,      // 低电平复位
    output reg  scan_clk    // 输出50kHz时钟
);

// 定义计数器，位宽计算：2^11 = 2048 > 2000，故需11位
localparam CNT_MAX = 1999;  // 计数器最大值（0~1999共2000个周期）
reg [10:0] cnt;

// 计数器模块
always @(posedge clk_100M or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 11'd0;
    end else if (cnt == CNT_MAX) begin
        cnt <= 11'd0;
    end else begin
        cnt <= cnt + 11'd1;
    end
end

// 输出时钟翻转（占空比50%）
always @(posedge clk_100M or negedge rst_n) begin
    if (!rst_n) begin
        scan_clk <= 1'b0;
    end else if (cnt == CNT_MAX / 2) begin  // 计数到1000时翻转
        scan_clk <= ~scan_clk;
    end
end

endmodule