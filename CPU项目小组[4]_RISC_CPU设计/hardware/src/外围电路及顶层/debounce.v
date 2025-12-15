// This module synchronizes the input, filters out glitches using a 20ms timer,
// and generates a single-cycle pulse on the falling edge (button press) of the input.

module debounce (
    input wire clk,      // System clock (assumed to be 100MHz)
    //input wire rst_n,    // Asynchronous reset, active low
    input wire PB,      // Raw button input (active low, so idle is 1)
    output reg PB_down  // Single-cycle pulse indicating a debounced press
);

// -- State Machine Definition --
localparam
    S_IDLE    = 4'b0001, // Waiting for a button press (falling edge)
    S_FILTER0 = 4'b0010, // Filtering stage after press is detected
    S_DOWN    = 4'b0100, // Button is confirmed to be held down
    S_FILTER1 = 4'b1000; // Filtering stage after release is detected

reg [3:0]  state;          // FSM state register
reg        key_flag;       // Flag used to generate the output pulse
reg        key_state;      // Tracks if the key is considered pressed (0) or released (1)

// -- Input Synchronization --
// Two-stage synchronizer to bring the asynchronous button input into the clock domain.
reg PB_sync_1, PB_sync_2;
always @(posedge clk) begin
    
        PB_sync_1 <= PB;
        PB_sync_2 <= PB_sync_1;
    
end

// -- Edge Detection on Synchronized Signal --
reg PB_prev;
wire falling_edge, rising_edge;

always @(posedge clk) begin
    
        PB_prev <= PB_sync_2;
    
end

// A falling edge occurs when the previous state was high (1) and the current is low (0).
assign falling_edge = PB_prev & ~PB_sync_2;
// A rising edge occurs when the previous state was low (0) and the current is high (1).
assign rising_edge = ~PB_prev & PB_sync_2;

// -- Debounce Timer (20ms) --
// For a 100MHz clock, we wait 2,000,000 cycles for 20ms.
localparam CNT_MAX = 21'd1_999_999;
reg [20:0] cnt;
reg        en_cnt;     // Counter enable
wire       cnt_full;   // Flag indicating the timer has finished

always @(posedge clk) begin
    if (en_cnt) begin
        cnt <= cnt + 1'b1;
    end else begin
        cnt <= 0;
    end
end
assign cnt_full = (cnt == CNT_MAX);

// -- Main State Machine Logic --
always @(posedge clk) begin
    
        case (state)
            S_IDLE: begin
                key_flag <= 1'b0;
                if (falling_edge) begin // Button pressed
                    state  <= S_FILTER0;
                    en_cnt <= 1'b1;      // Start the timer
                end
            end

            S_FILTER0: begin
                if (cnt_full) begin      // 20ms has passed with the button held down
                    key_flag  <= 1'b1;   // Set flag to generate pulse
                    key_state <= 1'b0;   // Mark key as 'down'
                    en_cnt    <= 1'b0;   // Stop the timer
                    state     <= S_DOWN;
                end else if (rising_edge) begin // It was a glitch, button released too early
                    state  <= S_IDLE;
                    en_cnt <= 1'b0;      // Stop the timer
                end
            end

            S_DOWN: begin
                key_flag <= 1'b0;        // Reset flag after one cycle
                if (rising_edge) begin   // Button released
                    state  <= S_FILTER1;
                    en_cnt <= 1'b1;      // Start the timer
                end
            end

            S_FILTER1: begin
                if (cnt_full) begin      // 20ms has passed with the button released
                    key_state <= 1'b1;   // Mark key as 'up'
                    state     <= S_IDLE;
                    en_cnt    <= 1'b0;   // Stop the timer
                end else if (falling_edge) begin // Glitch, pressed again too early
                    state  <= S_DOWN;
                    en_cnt <= 1'b0;
                end
            end

            default: state <= S_IDLE;
        endcase
    
end

// -- Output Pulse Generation --
// Generate a single-cycle pulse when the key is confirmed to be pressed down.
always @(posedge clk) begin
    if (key_flag && !key_state) begin
        PB_down <= 1'b1;
    end else begin
        PB_down <= 1'b0;
    end
end

endmodule