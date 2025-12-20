// top_module, contain basys3 hardware connections
module riscv_cpu_top(
    input  wire         clk,           // Basys3 100MHz clk (W5)
    input  wire         rst_n,         
    input  wire         btn_center_in, // center button (start CPU, connected to BTNC)
    input  wire         btn_up_in,     // up button (+ 1, connected to BTNU)
    input  wire         btn_down_in,   // down button (- 1, connected to BTND)
    input  wire         btn_left_in,   // left button (digit + 1, connected to BTNL)
    input  wire         btn_right_in,  // right button (digit - 1, connected to BTNR)

    output wire [3:0]   seg_an,        // 7-seg digit
    output wire [7:0]   seg_seg        // 7-seg segments (a~g + dp)
);

// Internal signals
wire [31:0] gcd_a;       // GCD input A
wire [31:0] gcd_b;       // GCD input B
wire [31:0] gcd_result;  // GCD result computed by CPU

wire        calc_start;  // CPU start signal after debounce
wire        btn_up;      // debounced up button
wire        btn_down;    // debounced down button
wire        btn_left;    // debounced left button
wire        btn_right;   // debounced right button

reg [1:0]   curr_an;        // currently selected 7-seg digit (0-3)
reg [3:0]   curr_seg [3:0]; // four 4-bit BCD digits to display (0-9)

wire clk_1MHz;

clock_divider clock_divider(
    .clk_in(clk),
    .rst_n(rst_n),
    .clk_out(clk_1MHz)
);

// 1. Button debounce modules
assign calc_start = btn_center_in; 

debounce up_debounce(
    .clk    (clk),
    //.rst_n  (rst_n),
    .PB     (btn_up_in), 
    .PB_down(btn_up)
);
debounce down_debounce(
    .clk    (clk),
    //.rst_n  (rst_n),
    .PB     (btn_down_in), 
    .PB_down(btn_down)
);
debounce left_debounce(
    .clk    (clk),
    //.rst_n  (rst_n),
    .PB     (btn_left_in), 
    .PB_down(btn_left)
);
debounce right_debounce(
    .clk    (clk),
    //.rst_n  (rst_n),
    .PB     (btn_right_in), 
    .PB_down(btn_right)
);

// 2. Digit selection (controlled by left/right buttons)
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        curr_an <= 2'd0; // default select least significant digit
    end else begin
        if(btn_right) begin
            curr_an <= (curr_an == 2'd0) ? 2'd3 : curr_an - 1'b1; // rotate left
        end else if(btn_left) begin
            curr_an <= (curr_an == 2'd3) ? 2'd0 : curr_an + 1'b1; // rotate right
        end
    end
end

// 3. Value increment/decrement (controlled by up/down buttons)
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        // after reset, display 0000 on four digits
        curr_seg[0] <= 4'd0;
        curr_seg[1] <= 4'd0;
        curr_seg[2] <= 4'd0;
        curr_seg[3] <= 4'd0;
    end else begin
        // Up button: +1 (0-9 wrap)
        if(btn_up) begin
            curr_seg[curr_an] <= (curr_seg[curr_an] == 4'd9) ? 4'd0 : curr_seg[curr_an] + 1'b1;
        end
        // Down button: -1 (0-9 wrap)
        else if(btn_down) begin
            curr_seg[curr_an] <= (curr_seg[curr_an] == 4'd0) ? 4'd9 : curr_seg[curr_an] - 1'b1;
        end
    end
end

// 4. assign low 8 bits of gcd_a/gcd_b to seg display
assign gcd_a = {24'd0, curr_seg[3]*8'd10 + curr_seg[2]}; // upper two digits -> gcd_a (0-99)
assign gcd_b = {24'd0, curr_seg[1]*8'd10 + curr_seg[0]}; // lower two digits -> gcd_b (0-99)

// 5. Instantiate RISC-V CPU
rv32i_cpu rv32i_cpu(
    .clk        (clk_1MHz),
    .rst_n      (rst_n),
    .calc_start (calc_start),  // start calculation signal
    .gcd_a      (gcd_a),       // input A
    .gcd_b      (gcd_b),       // input B
    .gcd_result (gcd_result)   // output GCD result
);

// 6. CPU status signal
wire cpu_state; // 0=idle/calculating, 1=done
assign cpu_state = (gcd_result != 32'd0) ? 1'b1 : 1'b0;

// 7. Instantiate multiplexed 7-seg display module
wire [15:0] seg_data_16;
assign seg_data_16 = {curr_seg[3], curr_seg[2], curr_seg[1], curr_seg[0]};  // pack four 4-bit digits into 16-bit bus
seg_display seg_display(
    .clk        (clk),
    .rst_n      (rst_n),
    .seg_data_16(seg_data_16), // display digits
    .gcd_result (gcd_result),  // GCD result
    .cpu_state  (cpu_state),   // CPU state
    .seg_an     (seg_an),      // digit enable outputs
    .seg_seg    (seg_seg)      // segment outputs
);

endmodule