

# 整数运算

## ADDI

**addi rd, rs1, imm**

将有符号立即数imm和寄存器rs1中的值相加，结果写入rd寄存器。

rd = rs1 + imm

其中：

imm为12bit，取值范围为[-2047, 2048]

rs1/rd为5bit，对应x0~x31共32个寄存器

## ADD

**add rd, rs1, rs2**

将有符号寄存器rs2和寄存器rs1中的值相加，结果写入rd寄存器

rd = rs1 + rs2

其中：

rs1/rs2/rd为5bit，对应x0~x31共32个寄存器

## SUB

**sub rd, rs1, rs2**

寄存器rs1减去寄存器rs2得到结果写入rd寄存器

rd = rs1 - rs2

## ANDI

**andi rd, rs1, imm**

将rs1和有符号imm求逻辑与，结果写入rd

rd = rs1 & imm

其中：

imm为12bit，取值范围为[-2047, 2048]

# 加载数据

## LUI

**lui rd, imm**

将imm左移20位后赋值给rd，低12位补0

rd = imm << 12



