# CPU polls x31 in a software loop; when x31 LSB is 1, start GCD calculation

# Poll the start signal (x31) in a loop until triggered
wait_start:
    mv t0, x31       # read x31 (mapped to calc_start)
    andi t0, t0, 1   # extract LSB (actual calc_start value)
    beqz t0, wait_start  # if zero, keep waiting

# Start GCD calculation when start signal detected
gcd_calc:
    mv a0, x28       # read x28 (gcd_a) into a0
    mv a1, x29       # read x29 (gcd_b) into a1
    jal ra, gcd_func # call GCD function
    mv x30, a0       # write result to x30 (update gcd_result output)
    j wait_start     # wait for next start

# GCD function implemented purely in RV32I (no rem instruction)
# Inputs: a0 = dividend, a1 = divisor; Output: a0 = result (GCD)
gcd_func:
    beq a1, x0, gcd_end  # if divisor is 0, finish (RV32I)
    # Subroutine: compute a0 % a1 using repeated subtraction
    mv t1, a0            # t1 = a0 (dividend)
gcd_rem:
    blt t1, a1, gcd_rem_end  # if t1 < a1 then remainder is t1 (blt is RV32I)
    sub t1, t1, a1       # t1 = t1 - a1 (subtraction, RV32I)
    j gcd_rem            # loop subtraction (RV32I)
gcd_rem_end:
    mv a0, a1            # a0 = previous divisor
    mv a1, t1            # a1 = remainder
    j gcd_func           # continue Euclidean loop (RV32I)
gcd_end:
    ret                  # pseudo-instruction -> jalr x0, ra, 0 (RV32I)


# 1. Assemble: convert gcd.s to object file gcd.o
# riscv-none-elf-as -march=rv32i -mabi=ilp32 .\gcd.s -o .\gcd.o

# 2. Link: produce ELF file (set start address 0x0)
# riscv-none-elf-ld -Ttext=0x0 .\gcd.o -o .\gcd.elf

# 3. Export .mem file (usable by Verilog)
# riscv-none-elf-objcopy -O verilog -j .text .\gcd.elf .\inst_mem_init.mem
