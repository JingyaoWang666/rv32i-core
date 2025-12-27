// a simple clock generator
module clock_divider(
    input clk_in,
    input rst_n,
    output reg clk_out
);

initial begin
    clk_out = 0;
end

reg [6:0] count;
    always @(posedge clk_in or negedge rst_n) begin
        if(!rst_n)
            clk_out <= 0;
        else if(count == 7'd99) begin
            clk_out <= ~clk_out;
            count <= 7'd0;
        end
        else
            count <= count + 1;
    end

endmodule