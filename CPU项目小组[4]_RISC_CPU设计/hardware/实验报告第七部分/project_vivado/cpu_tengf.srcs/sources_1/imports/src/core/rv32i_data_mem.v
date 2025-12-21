//Data memory module
//Based on the control signals from the control module (mem_read, mem_write) and funct3 (to distinguish LB/LH/LW/SB/SH/SW), implement byte/halfword/word access with proper sign/zero extension.
module rv32i_data_mem (
    input  wire        clk,
    input  wire        rst_n,

    input  wire        mem_read,
    input  wire        mem_write,
    input  wire [2:0]  funct3,      // to distinguish LB/LH/LW/SB/SH/SW
    input  wire [31:0] addr,        // byte address
    input  wire [31:0] write_data,  // from rs2_data

    output reg  [31:0] read_data    // properly sign/zero extended
);
    // TODO: implement byte/halfword/word access with sign extension

    reg [31:0] data_mem [0:127]; 
    integer i;     

    always @(*) begin
        if (mem_read) begin
            case (funct3)
                `FUNCT3_LB: begin
                    // Load Byte with sign extension
                    case (addr[1:0])
                        2'b00: read_data = {{24{data_mem[addr[31:2]][7]}}, data_mem[addr[31:2]][7:0]};
                        2'b01: read_data = {{24{data_mem[addr[31:2]][15]}}, data_mem[addr[31:2]][15:8]};
                        2'b10: read_data = {{24{data_mem[addr[31:2]][23]}}, data_mem[addr[31:2]][23:16]};
                        2'b11: read_data = {{24{data_mem[addr[31:2]][31]}}, data_mem[addr[31:2]][31:24]};
                    endcase
                end
                `FUNCT3_LH: begin
                    // Load Halfword with sign extension
                    case (addr[1])
                        1'b0: read_data = {{16{data_mem[addr[31:2]][15]}}, data_mem[addr[31:2]][15:0]};
                        1'b1: read_data = {{16{data_mem[addr[31:2]][31]}}, data_mem[addr[31:2]][31:16]};
                    endcase
                end
                `FUNCT3_LW: begin
                    // Load Word
                    read_data = data_mem[addr[31:2]];
                end
                default: read_data = 32'b0; // Undefined action
            endcase
        end else begin
            read_data = 32'b0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 128; i = i + 1)
                data_mem[i] <= 32'b0;
             // Optionally initialize memory on reset
        end else if (mem_write) begin
            case (funct3)
                `FUNCT3_SB: begin
                    // Store Byte
                    case (addr[1:0])
                        2'b00: data_mem[addr[31:2]][7:0]   <= write_data[7:0];
                        2'b01: data_mem[addr[31:2]][15:8]  <= write_data[7:0];
                        2'b10: data_mem[addr[31:2]][23:16] <= write_data[7:0];
                        2'b11: data_mem[addr[31:2]][31:24] <= write_data[7:0];
                    endcase
                end
                `FUNCT3_SH: begin
                    // Store Halfword
                    case (addr[1])
                        1'b0: data_mem[addr[31:2]][15:0]  <= write_data[15:0];
                        1'b1: data_mem[addr[31:2]][31:16] <= write_data[15:0];
                    endcase
                end
                `FUNCT3_SW: begin
                    // Store Word
                    data_mem[addr[31:2]] <= write_data;
                end
                default: ; // No need to store
            endcase
        end
    end

endmodule