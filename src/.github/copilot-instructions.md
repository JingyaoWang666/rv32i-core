<!-- .github/copilot-instructions.md -->

# Copilot / AI Agent Instructions for rv32i-core

Purpose: give AI coding agents the minimum, concrete knowledge they need to be productive in this repo.

High-level architecture
- Core components live under `core/` and are simple, single-module functional blocks that connect in `rv32i_cpu.v` (top-level CPU):
  - `rv32i_pc_reg.v` — program counter register (async active-low reset)
  - `rv32i_instr_mem.v` — instruction memory (word-address via `addr[<width>+2-1:2]`)
  - `rv32i_control.v` — main control (outputs `alu_src`, `mem_read`, `mem_write`, `mem_to_reg`, `reg_write`, `branch`, `jump`, `imm_type`, `alu_op_main`)
  - `rv32i_imm_gen.v` — immediate generation (uses `imm_type` from control)
  - `rv32i_reg_file.v` — register file (32×32, x0 must be hardwired to 0)
  - `rv32i_alu_control.v` — maps `alu_op_main` + `funct` fields to internal `alu_op` (see `rv32i_defs.vh`)
  - `rv32i_alu.v` — ALU implementing ops defined in `rv32i_defs.vh`
  - `rv32i_data_mem.v` — data memory (support LB/LH/LW/SB/SH/SW and proper sign/zero extension)
  - `rv32i_branch_unit.v` — branch/jump decision & target calculation (expects `is_jalr` flag optionally)

Key project-wide conventions
- Macro/encoding central place: `core/rv32i_defs.vh` — opcode, funct3/funct7 values and internal `ALU_OP_*` encodings. When adding instructions, edit this file.
- Reset: modules use active-low asynchronous reset named `rst_n` (follow this signal name and polarity).
- Instruction memory addressing: `rv32i_instr_mem` expects a byte `addr`; it indexes memory with `addr[INSTR_MEM_WIDTH+2-1:2]` (word aligned).
- Register file: `x0` must always read as zero and writes to x0 should be ignored.
- Control signaling: `imm_type` is a 2-bit field produced by `rv32i_control` and consumed by `rv32i_imm_gen`.
- ALU control split: `alu_op_main` (2 bits) from main control + `funct3/funct7` → `rv32i_alu_control` → 4-bit `alu_op` used by `rv32i_alu`.

Simulation / build hints
- This repo contains plain Verilog; simulated using common tools. Two quick options (run from `src/`):

  - Icarus Verilog (fast, free):
    ```powershell
    iverilog -o tb.vvp core\*.v testbench\*.v ; vvp tb.vvp
    ```

  - Vivado / XSIM: create a simple simulation project or run `xvlog`/`xsim` from Vivado tools (not scripted here). The testbench file is `testbench/tb_rv32i_cpu.v` and writes `rv32i_cpu.vcd` by default.

How firmware / test vectors are loaded
- Instruction memory (`instr_mem`) is a Verilog `reg [31:0] instr_mem[...]` inside `rv32i_instr_mem.v`. Tests typically preload it from a testbench using `$readmemh` / `$readmemb` or by directly assigning values in the testbench before deasserting reset. Example (in the testbench):

  - Example to load hex file from `tb`: ` $readmemh("firmware.hex", dut.instr_mem);` — adjust hierarchical name depending on instance path.

Project-specific patterns for agents
- Prefer minimal, local changes: add missing logic inside modules left with `// TODO:` rather than reorganizing files.
- When implementing a module, follow existing signal names and widths (do not rename `rst_n`, `clk`, `rd_we`, etc.).
- Use macros from `rv32i_defs.vh` instead of hard-coded constants for opcodes and ALU ops.
- For default/safe values, codebase uses `ALU_OP_HLT` as a safe default in `rv32i_alu_control.v` and `rv32i_alu.v` initializes `result = 0` before `case`.

Examples of common edits an AI agent may be asked to do
- Implement `rv32i_control.v` main control logic: produce `alu_src`, `imm_type`, `alu_op_main` per opcode using `rv32i_defs.vh` macros.
- Implement `rv32i_reg_file.v`: 32 registers, x0 fixed to zero, synchronous write on rising `clk` when `rd_we` asserted.
- Implement `rv32i_data_mem.v`: byte/halfword/word accesses with sign-extension using `funct3`.

Quick checklist before submitting PR
- Run the testbench simulation (Icarus or Vivado) and confirm `rv32i_cpu.vcd` or console output looks reasonable.
- Use macros from `rv32i_defs.vh` for any opcode/ALU references.
- Preserve signal names and reset polarity.

If anything is unclear or you need repository-specific examples (e.g., the exact hierarchical path to `instr_mem` in the DUT instance), ask for the preferred simulator and I will provide concrete load/read commands and a short test vector to exercise that change.
