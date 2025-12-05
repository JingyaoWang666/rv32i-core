module debounce(
    input       clk, //
    input       PB,  // glitchy, asynchronous to clk, active high push-button signal
    
    output reg  PB_state,
    output      PB_down,
    output      PB_up
);

// two flip-flops to synchronize the PB signal the "clk" clock domain
reg PB_sync_0,PB_sync_1;

always @(posedge clk) 
    PB_sync_0 <= PB; 
always @(posedge clk) 
    PB_sync_1 <= PB_sync_0;

reg [17:0] PB_cnt;

// debouncer and posedge_check
wire PB_stay = (PB_state == PB_sync_1);  

always @(posedge clk) begin
    if (PB_stay) begin
        PB_cnt <= 0;
    end else begin
        PB_cnt <= PB_cnt + 16'd1;
        if (&PB_cnt) begin
            PB_state <= ~PB_state;
        end
    end
end

assign PB_down = (&PB_cnt) & PB_sync_1;
assign PB_up   = (&PB_cnt) & ~PB_sync_1;

endmodule