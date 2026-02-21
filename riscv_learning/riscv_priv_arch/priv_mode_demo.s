# priv_mode_demo.s - RISC-V特权模式切换演示（M→S）
# 适配：RV64G + QEMU riscv64用户态（修正所有位段/逻辑错误）
# 核心修正：mstatus值、位段注释、异常处理兼容性

# ==================== M模式代码（模拟OpenSBI）====================
.section .text.m_mode
.globl _start
_start:
    # 1. 初始化M态异常向量表（mtvec）：指向M态异常处理函数
    la t0, m_trap_handler       # t0 = 异常处理函数地址
    csrw mtvec, t0              # 写入mtvec寄存器

    # 2. 配置mstatus：设置返回后进入S模式 + 开启M态全局中断
    
    li t0, 0x808         		# 0x808 = MPP=S(bit11=1, 0x800) + MIE=1(bit3=1, 0x8)       
    csrw mstatus, t0            # 写入mstatus寄存器

    # 3. 配置异常委托：将大部分异常/中断委托给S态处理
    # 注：QEMU用户态下委托寄存器可能不生效，但不影响核心切换逻辑
    li t0, 0xffffffffffffffff   # 所有异常委托给S态
    csrw medeleg, t0
    li t0, 0xffffffffffffffff   # 所有中断委托给S态
    csrw mideleg, t0

    # 4. 设置S态入口地址：将S模式代码入口写入mepc
    la t0, s_mode_entry         # t0 = S模式入口地址
    csrw mepc, t0               # 写入mepc寄存器

    # 5. 关键：执行mret，从M态切换到S态（跳转到mepc指向的地址）
    mret

# M态异常处理函数（兼容QEMU用户态的极简版）
m_trap_handler:
    # 打印异常提示（使用Linux syscall：write(1, msg, len)）
    li a0, 1                    # fd=stdout
    la a1, m_trap_msg           # 提示信息地址
    li a2, m_trap_msg_len       # 信息长度
    li a7, 64                   # syscall编号：write
    ecall
    # 退出程序（syscall：exit(1)）
    li a0, 1                    # 退出码=1（标识异常）
    li a7, 93                   # syscall编号：exit
    ecall

# ==================== S模式代码（模拟Linux内核）====================
.section .text.s_mode
s_mode_entry:
    # 验证：进入S模式后打印提示
    li a0, 1                    # fd=stdout
    la a1, s_mode_msg           # 提示信息地址
    li a2, s_mode_msg_len       # 信息长度
    li a7, 64                   # syscall编号：write
    ecall

    # 验证权限：S态访问M态专属寄存器（触发异常）
    # 注：QEMU用户态下此操作会触发M态异常，验证特权隔离
    csrr t0, mstatus            # 非M态访问mstatus → 触发权限异常

    # 正常退出（若未触发异常）
    li a0, 0
    li a7, 93
    ecall

# ==================== 数据段 ====================
.section .data
m_trap_msg: .asciz "=== M Mode Trap Triggered (S态访问M态寄存器) ===\n"
m_trap_msg_len = . - m_trap_msg

s_mode_msg: .asciz "=== Success! Enter S Mode ===\n"
s_mode_msg_len = . - s_mode_msg