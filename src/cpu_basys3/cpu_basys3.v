// top_module 包含basys3硬件逻辑
module riscv_cpu_top(
    input  wire         clk,           // Basys3 100MHz时钟（W5�?
    input  wire         rst_n,         // 复位（BTNC，低有效�?
    input  wire         btn_center_in, // 中键（启动CPU，接BTNC�?
    input  wire         btn_up_in,     // 上键（加1，接BTNU�?
    input  wire         btn_down_in,   // 下键（减1，接BTND�?
    input  wire         btn_left_in,   // 左键（�?�前�?位，接BTNL�?
    input  wire         btn_right_in,  // 右键（�?�后�?位，接BTNR�?

    output wire [3:0]   seg_an,        // 数码管位选（共阴极）
    output wire [7:0]   seg_seg        // 数码管段选（a~g+dp�?
);

// 内部信号
wire [31:0] gcd_a;       // GCD输入数A
wire [31:0] gcd_b;       // GCD输入数B
wire [31:0] gcd_result;  // CPU计算出的GCD结果

wire        calc_start;  // 消抖后CPU启动信号
wire        btn_up;      // 上键消抖后信�?
wire        btn_down;    // 下键消抖后信�?
wire        btn_left;    // 左键消抖后信�?
wire        btn_right;   // 右键消抖后信�?

reg [1:0]   curr_an;        // 当前选中的数码管位（0-3�?
reg [3:0]   curr_seg [3:0]; // 四位数码管显示数据（0-9�?

// 1. 按键消抖模块
debounce center_debounce(
    .clk    (clk),
    
    .PB     (btn_center_in), 
    .PB_down(calc_start)
);
debounce up_debounce(
    .clk    (clk),
    
    .PB     (btn_up_in), 
    .PB_down(btn_up)
);
debounce down_debounce(
    .clk    (clk),
    
    .PB     (btn_down_in), 
    .PB_down(btn_down)
);
debounce left_debounce(
    .clk    (clk),
    
    .PB     (btn_left_in), 
    .PB_down(btn_left)
);
debounce right_debounce(
    .clk    (clk),
    
    .PB     (btn_right_in), 
    .PB_down(btn_right)
);

// 2. 数码管位选择（左右键控制�?
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        curr_an <= 2'd0; // 默认选中�?低位
    end else begin
        if(btn_left) begin
            curr_an <= (curr_an == 2'd0) ? 2'd3 : curr_an - 1'b1; // 循环左移
        end else if(btn_right) begin
            curr_an <= (curr_an == 2'd3) ? 2'd0 : curr_an + 1'b1; // 循环右移
        end
    end
end

// 3. 数�?�加减控制（上下键控制）
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        // 复位后四位数码管显示0000
        curr_seg[0] <= 4'd0;
        curr_seg[1] <= 4'd0;
        curr_seg[2] <= 4'd0;
        curr_seg[3] <= 4'd0;
    end else begin
        // 上键：当前位�?1�?0-9循环�?
        if(btn_up) begin
            curr_seg[curr_an] <= (curr_seg[curr_an] == 4'd9) ? 4'd0 : curr_seg[curr_an] + 1'b1;
        end
        // 下键：当前位�?1�?0-9循环�?
        else if(btn_down) begin
            curr_seg[curr_an] <= (curr_seg[curr_an] == 4'd0) ? 4'd9 : curr_seg[curr_an] - 1'b1;
        end
    end
end

// 4. 关联gcd_a/gcd_b�?8位（�?24位补0）与数码管数�?
assign gcd_a = {24'd0, curr_seg[3]*4'd10 + curr_seg[2]}; // 高两位→gcd_a�?0-99�?
assign gcd_b = {24'd0, curr_seg[1]*4'd10 + curr_seg[0]}; // 低两位→gcd_b�?0-99�?

// 5. 例化RISC-V CPU
rv32i_cpu rv32i_cpu(
    .clk        (clk),
    .rst_n      (rst_n),
    .calc_start (calc_start),  // 启动计算信号
    .gcd_a      (gcd_a),       // 输入数A
    .gcd_b      (gcd_b),       // 输入数B
    .gcd_result (gcd_result)   // 输出GCD结果
);

// 6.CPU状�?�信�?
wire cpu_state; // 0=空闲/计算中，1=完成
assign cpu_state = (gcd_result != 32'd0) ? 1'b1 : 1'b0;

// 7. 例化动�?�扫描数码管显示模块
wire [15:0] seg_data_16;
assign seg_data_16 = {curr_seg[3], curr_seg[2], curr_seg[1], curr_seg[0]};  // 将二维的4�?4位的curr_seg拼接�?16位一维信号seg_data_16
seg_display seg_display(
    .clk        (clk),
    .rst_n      (rst_n),
    .seg_data_16(seg_data_16), // 数码管显示数�?
    .gcd_result (gcd_result),  // GCD结果
    .cpu_state  (cpu_state),   // CPU状�??
    .seg_an     (seg_an),      // 数码管位选输�?
    .seg_seg    (seg_seg)      // 数码管段选输�?
);

endmodule