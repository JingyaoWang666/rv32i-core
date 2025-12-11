//展宽后同步化sync和上升沿检测posedge_check模块
module debounce(
   input clk,
   input PB,
   output PB_down
);

// 对窄脉冲输入进行展宽（确保至少持续1个时钟周期）
reg PB_extend;
always @(posedge clk or posedge PB) begin
    if (PB) begin
        PB_extend <= 1'b1;  // 检测到投币信号立即置1
    end else begin
        PB_extend <= 1'b0;  // 时钟沿到来时复位（展宽至至少1个周期）
    end
end

//投币信号coin_in的同步化处理（通过两级寄存器，实现异步输入同步化）
reg PB_sync1, PB_sync2;
//第一级同步：可能存在亚稳态
always @(posedge clk) begin
        PB_sync1 <= PB_extend;
end
//第二级同步：输出稳定的同步信号（与clk同步）
always @(posedge clk) begin
        PB_sync2 <= PB_sync1;
end

//对同步后的信号进行边沿检测（检测上升沿，应对投币信号持续多个时钟周期）
reg PB_sync3;
always @(posedge clk) begin
        PB_sync3 <= PB_sync2;
end
// 上升沿检测：同步信号当前为1，前一拍为0
assign PB_down = PB_sync2 & ~PB_sync3;

endmodule
