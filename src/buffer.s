.data
.globl init
.globl move_gen
.globl check_gen
#
# all functions in this file are called in the main
#

bu:
.word 0
bo:
.word 0
offsets:
.byte 0,0

.text
.import "complete_move.s"
.import "move_check.s"

init:
#a0 buffer address
#a1 board
    la t0 bu
    sw a0 0(t0)
    la t0 bo
    sw a1 0(t0)
    jr ra

move_gen:
#a0 inital offset
#a1 step offset
#a2 jump offset

    addi sp sp -24
    sw s1 0(sp)
    sw s2 4(sp)
    sw s4 8(sp)
    sw s5 12(sp)
    sw s6 16(sp)
    sw s7 20(sp)


    lw s1 bu
    lw s2 bo
    la t0 offsets
    sb a1 0(t0)
    sb a2 1(t0)
    add s7 s2 a0

    li s5 0
    li s6 0
    li s4 0

l:
    lb a1 offsets

    sw s7 0(s1)
    add s7 s7 a1
    sw s7 4(s1)
    add s7 s7 a1
    sw s7 8(s1)
    add s7 s7 a1
    sw s7 12(s1)

##################
    addi sp sp -4
    sw ra 0(sp)

    la a0 bu
    lw a0 0(a0)
    li a1 4
    jal complete_move
    add s6 s6 a0
    add s4 s4 a1

    lw ra 0(sp)
    addi sp sp 4
##################
    la t0 offsets
    lb a2 1(t0)

    add s7 s7 a2
    addi s5 s5 1
    li t0 3
    ble s5 t0 l

    beqz s6 end
    addi s6 s6 -1
    li t0 1
    sll s6 t0 s6
    mul s6 s6 s4

end:
    mv a0 s6

    lw s1 0(sp)
    lw s2 4(sp)
    lw s4 8(sp)
    lw s5 12(sp)
    lw s6 16(sp)
    lw s7 20(sp)
    addi sp sp 24

    jr ra

check_gen:
#a0 inital offset
#a1 step offset
#a2 jump offset
    addi sp sp -16
    sw s1 0(sp)
    sw s2 4(sp)
    sw s5 8(sp)
    sw s7 12(sp)


    lw s1 bu
    lw s2 bo
    la t0 offsets
    sb a1 0(t0)
    sb a2 1(t0)
    add s7 s2 a0

    li a0 0
    li s5 0
c:
    lb a1 offsets
    li t0 3
    bgt s5 t0 check_end

    sw s7 0(s1)
    add s7 s7 a1
    sw s7 4(s1)
    add s7 s7 a1
    sw s7 8(s1)
    add s7 s7 a1
    sw s7 12(s1)

##################
    addi sp sp -4
    sw ra 0(sp)

    la a0 bu
    lw a0 0(a0)
    li a1 4
    jal move_check

    lw ra 0(sp)
    addi sp sp 4
##################
    bnez a0 check_end

    la t0 offsets
    lb a2 1(t0)

    add s7 s7 a2
    addi s5 s5 1
    j c

check_end:

    lw s1 0(sp)
    lw s2 4(sp)
    lw s5 8(sp)
    lw s7 12(sp)
    addi sp sp 16
    jr ra
