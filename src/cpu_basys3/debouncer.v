module key_debounce(
    input  wire clk,      // 100MHz时钟
    input  wire rst_n,    // 低复位
    input  wire key_in,   // 按键输入（按下为低）
    output reg  key_out   // 消抖后输出（按下为高，持续1个时钟）
);

reg [19:0] cnt;  // 消抖计数器（100MHz→1ms计数）
reg        key_reg;     // 按键值寄存

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt <= 20'd0;
        key_reg <= 1'b1;
        key_out <= 1'b0;
    end else begin
        key_reg <= key_in;
        if(key_reg != key_in) begin  // 按键状态变化，重置计数器
            cnt <= 20'd0;
        end else if(cnt == 20'd999999) begin  // 稳定10ms
            cnt <= cnt;
            key_out <= ~key_in;  // 按下为高
        end else begin
            cnt <= cnt + 1'b1;
            key_out <= 1'b0;
        end
    end
end

endmodule