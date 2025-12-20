module seg_display(
    input  wire         clk,            // 100MHz system clock
    input  wire         rst_n,          // active-low reset
    input  wire [15:0]  seg_data_16,    // four 7-seg digits packed into 16 bits: [15:12]=seg3, [11:8]=seg2, [7:4]=seg1, [3:0]=seg0
    input  wire [31:0]  gcd_result,     // GCD calculation result (optional display)
    input  wire         cpu_state,      // CPU state (0 = idle/calculating, 1 = done)
    output reg [3:0]    seg_an,         // digit enable (common-cathode, active low)
    output reg [7:0]    seg_seg         // segment outputs (a~g + dp, active low)
);

// split the 16-bit bus back into four 4-bit digit signals
wire [3:0] curr_seg[3:0];
assign curr_seg[0] = seg_data_16[3:0];   // digit 0 (least significant)
assign curr_seg[1] = seg_data_16[7:4];   // digit 1
assign curr_seg[2] = seg_data_16[11:8];  // digit 2
assign curr_seg[3] = seg_data_16[15:12]; // digit 3 (most significant)


// 1. Clock divider: 100MHz → scan clock (avoid flicker)
wire scan_clk;
clk_divider_100M_to_50kHz my_div(
    .clk_100M(clk),
    .rst_n(rst_n),
    .scan_clk(scan_clk)
);
reg [1:0] scan_an;
always @(posedge scan_clk)
    scan_an <= scan_an + 2'b1;    // current scan position (2 bits, 0-3)

// 2. Select the digit value for the current scan position (4-bit)
reg [3:0] scan_seg;                      // current digit value (4 bits)
always @(*) begin
    if(cpu_state == 1'b1) begin          // if calculation finished: display GCD result
        case(scan_an)
            2'd0: scan_seg = gcd_result % 4'd10; // ones place
            2'd1: scan_seg = gcd_result / 4'd10; // tens place (simple division)
            default: scan_seg = 4'd0;
        endcase
    end else begin
        scan_seg = curr_seg[scan_an];     // idle/calculating: display input digits
    end
end

// 3. Digit enable control
always @(*) begin
    case(scan_an)
        2'd0: seg_an = 4'b1110; // digit 0 (LSB)
        2'd1: seg_an = 4'b1101; // digit 1
        2'd2: seg_an = 4'b1011; // digit 2
        2'd3: seg_an = 4'b0111; // digit 3 (MSB)
        default: seg_an = 4'b1111;
    endcase
end

// 4. Segment encoding for digits 0-9 (active low)
always @(*) begin
    case(scan_seg)
        4'd0: seg_seg = 8'b11000000; // 0 (dp off, a-g on)
        4'd1: seg_seg = 8'b11111001; // 1
        4'd2: seg_seg = 8'b10100100; // 2
        4'd3: seg_seg = 8'b10110000; // 3
        4'd4: seg_seg = 8'b10011001; // 4
        4'd5: seg_seg = 8'b10010010; // 5
        4'd6: seg_seg = 8'b10000010; // 6
        4'd7: seg_seg = 8'b11111000; // 7
        4'd8: seg_seg = 8'b10000000; // 8
        4'd9: seg_seg = 8'b10010000; // 9
        default: seg_seg = 8'b11111111; // all segments off
    endcase
end

endmodule