module clk_divider_100M_to_50kHz (
    input  wire clk_100M,   // input 100MHz clock
    input  wire rst_n,      // low level reset
    output reg  scan_clk    // output 50kHz clock
);

// define counter，width calculate：2^11 = 2048 > 2000，so 11 bits are enough
localparam CNT_MAX = 1999;  // counter maxium
reg [10:0] cnt;

// counter module 
always @(posedge clk_100M or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 11'd0;
    end else if (cnt == CNT_MAX) begin
        cnt <= 11'd0;
    end else begin
        cnt <= cnt + 11'd1;
    end
end

// output clock inversion (50% duty cycle)
always @(posedge clk_100M or negedge rst_n) begin
    if (!rst_n) begin
        scan_clk <= 1'b0;
    end else if (cnt == CNT_MAX / 2) begin  // invert when 1000
        scan_clk <= ~scan_clk;
    end
end

endmodule