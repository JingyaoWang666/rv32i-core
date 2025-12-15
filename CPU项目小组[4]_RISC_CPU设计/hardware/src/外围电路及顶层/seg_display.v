module seg_display(
    input  wire         clk,            // 100MHz系统时钟
    input  wire         rst_n,          // 低有效复位
    input  wire [15:0]  seg_data_16,    // 四位数码管数据（拼接为16位：[15:12]=seg3, [11:8]=seg2, [7:4]=seg1, [3:0]=seg0）
    input  wire [31:0]  gcd_result,     // GCD计算结果（可选显示）
    input  wire         cpu_state,      // CPU状态（0=空闲/计算中，1=完成）
    output reg [3:0]    seg_an,         // 数码管位选（共阴极，低有效）
    output reg [7:0]    seg_seg         // 数码管段选（a~g+dp，低有效）
);

// 将16位一维信号拆分回4个4位的二位信号
wire [3:0] curr_seg[3:0];
assign curr_seg[0] = seg_data_16[3:0];   // 第0位（最低位）
assign curr_seg[1] = seg_data_16[7:4];   // 第1位
assign curr_seg[2] = seg_data_16[11:8];  // 第2位
assign curr_seg[3] = seg_data_16[15:12]; // 第3位（最高位）


// 1. 分频：100MHz→500Hz扫描频率（避免闪烁）
wire scan_clk;
clk_divider_100M_to_50kHz my_div(
    .clk_100M(clk),
    .rst_n(rst_n),
    .scan_clk(scan_clk)
);
reg [1:0] scan_an;
always @(posedge scan_clk)
    scan_an <= scan_an + 2'b1;    // 当前扫描位（2位，0-3）

// 2. 当前扫描位的数字选择(4位)
reg [3:0] scan_seg;                      // 当前扫描位的数字（4位）
always @(*) begin
    if(cpu_state == 1'b1) begin          // 计算完成：显示GCD结果
        case(scan_an)
            2'd0: scan_seg = gcd_result % 4'd10; //个位数
            2'd1: scan_seg = gcd_result / 4'd10; //十位数
            default: scan_seg = 4'd0;  
        endcase
    end else begin 
        scan_seg = curr_seg[scan_an];          // 空闲/计算中：显示输入值
    end
end

// 3. 数码管位选控制
always @(*) begin
    case(scan_an)
        2'd0: seg_an = 4'b1110; // 第0位（最低位）
        2'd1: seg_an = 4'b1101; // 第1位
        2'd2: seg_an = 4'b1011; // 第2位
        2'd3: seg_an = 4'b0111; // 第3位（最高位）
        default: seg_an = 4'b1111;
    endcase
end

// 4. 数码管段选控制（0-9数字编码）
always @(*) begin
    case(scan_seg)
        4'd0: seg_seg = 8'b11000000; // 0 (dp灭，a-g亮)
        4'd1: seg_seg = 8'b11111001; // 1
        4'd2: seg_seg = 8'b10100100; // 2
        4'd3: seg_seg = 8'b10110000; // 3
        4'd4: seg_seg = 8'b10011001; // 4
        4'd5: seg_seg = 8'b10010010; // 5
        4'd6: seg_seg = 8'b10000010; // 6
        4'd7: seg_seg = 8'b11111000; // 7
        4'd8: seg_seg = 8'b10000000; // 8
        4'd9: seg_seg = 8'b10010000; // 9
        default: seg_seg = 8'b11111111; // 熄灭
    endcase
end

endmodule