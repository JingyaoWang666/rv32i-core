# CPU 软件循环读取 x31，检测到 x31 的最低位为 1 时（外部硬件拨动开关使calc_start为 1 时），启动 GCD 计算

    .text           # 代码段
    .align 2        # 4字节对齐（RV32I要求）
    .global _start  # 定义入口符号（链接时需要）

# 循环检测启动信号（x31），直到触发
wait_start:
    mv t0, x31       # 读x31（映射calc_start）
    andi t0, t0, 1   # 提取最低位（calc_start的实际值）
    beqz t0, wait_start  # 若为0，继续等待

# 检测到启动信号，开始GCD计算
gcd_calc:
    mv a0, x28       # 读x28（gcd_a）到a0
    mv a1, x29       # 读x29（gcd_b）到a1
    jal ra, gcd_func # 调用GCD计算函数
    mv x30, a0       # 计算结果写入x30（同步更新gcd_result输出）
    j wait_start     # 等待下一次启动

/* 
# GCD计算函数（欧几里得算法）
# 需要RV32M的rem指令
gcd_func:
    beq a1, zero, gcd_end
    rem a2, a0, a1
    mv a0, a1
    mv a1, a2
    j gcd_func
gcd_end:
    ret 
*/

# 纯RV32I实现的GCD函数（替换rem）
# 输入：a0 = 被除数，a1 = 除数；输出：a0 = 余数
gcd_func:
    beq a1, x0, gcd_end  # 除数为0，结束（RV32I）
    # 子函数：计算a0 % a1（纯减法实现取余）
    mv t1, a0            # t1 = a0（被除数）
gcd_rem:
    blt t1, a1, gcd_rem_end  # t1 < a1时，余数就是t1（blt是RV32I）
    sub t1, t1, a1       # t1 = t1 - a1（减法，RV32I）
    j gcd_rem            # 循环减（RV32I）
gcd_rem_end:
    mv a0, a1            # a0 = 原除数
    mv a1, t1            # a1 = 余数
    j gcd_func           # 继续欧几里得循环（RV32I）
gcd_end:
    ret                  # 伪指令→jalr x0, ra, 0（RV32I）


# 1. 汇编：将gcd.s转为目标文件gcd.o
#riscv-none-elf-as -march=rv32i -mabi=ilp32 .\gcd.s -o .\gcd.o

# 2. 链接：转为ELF文件（指定起始地址0x0）
#riscv-none-elf-ld -Ttext=0x0 .\gcd.o -o .\gcd.elf

# 3. 导出Hex文件（Verilog可用）
#riscv-none-elf-objcopy -O verilog -j .text .\gcd.elf .\inst_mem_init.hex
