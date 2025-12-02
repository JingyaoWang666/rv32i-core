// 新增硬件输入输出端口（CPU 顶层）

module riscv_cpu_top(
    // 时钟/复位
    input  wire         clk,        // Basys3 100MHz时钟（W5）
    input  wire         rst_n,      // 复位（BTNC，低有效）
    // Basys3输入：16位开关
    input  wire [15:0]  sw_in,      // 接SW15~SW0
    // Basys3输出：LED+数码管
    output wire [15:0]  led_out,    // 接LD15~LD0
    output wire [7:0]   seg_en,     // 数码管位选（共阴极）
    output wire [7:0]   seg_data    // 数码管段选（a~g+dp）
);

// 内部信号
wire [31:0] gcd_a;       // GCD输入数A（从开关高8位扩展为32位）
wire [31:0] gcd_b;       // GCD输入数B（从开关低8位扩展为32位）
wire [31:0] gcd_result;  // CPU计算出的GCD结果
wire        calc_start;  // 按键触发计算（消抖后）

// 1. 开关值扩展为32位（RV32I是32位寄存器）
assign gcd_a = {24'd0, sw_in[15:8]};  // 高8位→数A（0~255）
assign gcd_b = {24'd0, sw_in[7:0]};   // 低8位→数B（0~255）

// 2. 按键消抖模块（避免按键抖动导致误触发）
key_debounce key_debounce(
    .clk    (clk),
    .rst_n  (rst_n),
    .key_in (~BTNC),  // Basys3按键默认高电平，按下为低
    .key_out(calc_start)
);

// 3. 你的RISC-V CPU核心模块（新增输入：gcd_a/gcd_b/calc_start，输出：gcd_result）
rv32i_cpu rv32i_cpu(
    .clk        (clk),
    .rst_n      (rst_n),
    .calc_start (calc_start),  // 启动计算信号
    .gcd_a      (gcd_a),       // 输入数A
    .gcd_b      (gcd_b),       // 输入数B
    .gcd_result (gcd_result)   // 输出GCD结果
);

// 4. LED输出（直接显示32位结果的低16位）
assign led_out = gcd_result[15:0];

// 5. 数码管驱动模块（将32位结果转为8位十进制显示）
seg_display seg_display(
    .clk        (clk),
    .rst_n      (rst_n),
    .data_in    (gcd_result),  // GCD结果
    .seg_en     (seg_en),      // 数码管位选
    .seg_data   (seg_data)     // 数码管段选
);

endmodule