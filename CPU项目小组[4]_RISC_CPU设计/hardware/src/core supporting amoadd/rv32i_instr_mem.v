// Instruction Memory
// addr is the current PC output, and typically addr[31:2] is used internally as the word-addressing index.

// (This is because the addressing granularity of this rv32i is 1 byte/8 bits, meaning a PC output of 1 represents 1 byte.
// In this design, the fixed instruction length is 32 bits = 4 bytes = 1 word. If 4-byte aligned,
// instruction addresses would all start with a multiple of 4, the lower two bits of the PC would always be 0, and updates would be pc+4.
// The lower two bits would carry no information. However, to be closer to a general-purpose address bus/32-bit byte address,
// to unify with the data access bus, and because other complex functions might use the lower two bits, they are included here.)

`include "rv32i_defs.vh"
module rv32i_instr_mem (
    input  wire [31:0] addr,        // byte address from PC
    output wire [31:0] instr
);
    
reg [31:0] instr_mem [0:`INSTR_MEM_DEPTH-1];

// initialize inst_mem，load binary file at time 0
initial begin
    // initialize the starting address
    $readmemb("inst_mem_init.mem", instr_mem, 0, `INSTR_MEM_DEPTH-1);
end

assign instr = instr_mem[addr[`INSTR_MEM_WIDTH+2-1:2]];

endmodule