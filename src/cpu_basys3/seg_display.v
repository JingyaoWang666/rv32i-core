module seg_display(
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] data_in,  // GCD结果（0~255）
    output reg  [7:0]  seg_en,   // 位选（bit0=最右位）
    output reg  [7:0]  seg_data  // 段选（a~g+dp，bit0=a，bit7=dp）
);

// 数码管段码表（共阴极，0~9）
reg [7:0] seg_code[0:9];
initial begin
    seg_code[0] = 8'b00000011; // 0
    seg_code[1] = 8'b10011111; // 1
    seg_code[2] = 8'b00100101; // 2
    seg_code[3] = 8'b00001101; // 3
    seg_code[4] = 8'b10011001; // 4
    seg_code[5] = 8'b01001001; // 5
    seg_code[6] = 8'b01000001; // 6
    seg_code[7] = 8'b00011111; // 7
    seg_code[8] = 8'b00000001; // 8
    seg_code[9] = 8'b00001001; // 9
end

reg [3:0]  digit;       // 当前显示的数字
reg [15:0] cnt;         // 扫描计数器（控制数码管刷新）
reg [2:0]  seg_sel;     // 数码管位选择（0~7）
wire [3:0] data_bcd[7:0];// BCD码分解结果

// 1. 将32位结果转为8位BCD码（仅处理0~255，简化版）
assign data_bcd[0] = data_in % 10;    // 个位
assign data_bcd[1] = (data_in/10) % 10;// 十位
assign data_bcd[2] = (data_in/100) % 10;// 百位
assign data_bcd[3] = 4'd0;
assign data_bcd[4] = 4'd0;
assign data_bcd[5] = 4'd0;
assign data_bcd[6] = 4'd0;
assign data_bcd[7] = 4'd0;

// 2. 数码管扫描（100MHz→1kHz刷新）
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt <= 16'd0;
        seg_sel <= 3'd0;
    end else begin
        if(cnt == 16'd99999) begin  // 1ms刷新一次
            cnt <= 16'd0;
            seg_sel <= seg_sel + 1'b1;
        end else begin
            cnt <= cnt + 1'b1;
        end
    end
end

// 3. 位选和段选赋值
always @(*) begin
    seg_en = 8'b11111111;  // 初始全灭（共阴极，低电平点亮）
    case(seg_sel)
        3'd0: begin seg_en = 8'b11111110; digit = data_bcd[0]; end
        3'd1: begin seg_en = 8'b11111101; digit = data_bcd[1]; end
        3'd2: begin seg_en = 8'b11111011; digit = data_bcd[2]; end
        3'd3: begin seg_en = 8'b11110111; digit = data_bcd[3]; end
        3'd4: begin seg_en = 8'b11101111; digit = data_bcd[4]; end
        3'd5: begin seg_en = 8'b11011111; digit = data_bcd[5]; end
        3'd6: begin seg_en = 8'b10111111; digit = data_bcd[6]; end
        3'd7: begin seg_en = 8'b01111111; digit = data_bcd[7]; end
        default: begin seg_en = 8'b11111111; digit = 4'd0; end
    endcase
    seg_data = seg_code[digit];
end

endmodule