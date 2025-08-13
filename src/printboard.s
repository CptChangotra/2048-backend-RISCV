.data
row_line:              .asciiz "-----------------------------\n"
empty_row:             .asciiz "|      |      |      |      |\n"
one_digit:             .asciiz "|    "
two_digit:             .asciiz "|   "
three_digit:           .asciiz "|  "
four_digit:            .asciiz "| "
empty_space:           .asciiz " "
string_end_of_line:    .asciiz "|\n"

.text
.globl printboard
printboard:
    addi sp sp -32
    sw s0 0(sp)
    sw s1 4(sp)
    sw s2 8(sp)
    sw s3 12(sp)
    sw s4 16(sp)
    sw s5 20(sp)
    sw s6 24(sp)
    sw ra 28(sp)

    li t0 0         # t0 := Row counter (MAX 4)
    li t1 0         # t1 := Total tile counter (MAX 16)
    li t2 0         # t2 := Offset index
    li s0 4
    li s1 16
    li s2 9
    li s3 99
    li s4 999
    li s5 9999
    mv s6 a0

top:
    li a0 4
    la a1 row_line
    ecall

    li a0 4
    la a1 empty_row
    ecall

loop:
    beq t1 s1 end_of_gui
    beq t0 s0 end_of_line
    j digit

end_of_line:
    li a0 4
    la a1 string_end_of_line
    ecall

    li a0 4
    la a1 empty_row
    ecall

    li t0 0
    j top

end_of_gui:
    # Print charcter "|"
    li a0 11
    li a1 124
    ecall

    # Print newline
    li a0 11
    li a1 10
    ecall

    li a0 4
    la a1 empty_row
    ecall


    li a0 4
    la a1 row_line
    ecall

    lw s0 0(sp)
    lw s1 4(sp)
    lw s2 8(sp)
    lw s3 12(sp)
    lw s4 16(sp)
    lw s5 20(sp)
    lw s6 24(sp)
    lw ra 28(sp)
    addi sp sp 32

    jr ra

digit:
    slli t3 t2 1
    add t4 s6 t3
    lhu t6 0(t4)

    blt t6 s2 print_one_digit
    blt t6 s3 print_two_digit
    blt t6 s4 print_three_digit
    blt t6 s5 print_four_digit
    j print_four_digit


print_one_digit:
    li a0 4
    la a1 one_digit
    ecall

    li a0 1
    mv a1 t6
    ecall

    li a0 4
    la a1 empty_space
    ecall

    addi t2 t2 1
    addi t0 t0 1
    addi t1 t1 1
    j loop

print_two_digit:
    li a0 4
    la a1 two_digit
    ecall

    li a0 1
    mv a1 t6
    ecall

    li a0 4
    la a1 empty_space
    ecall

    addi t2 t2 1
    addi t0 t0 1
    addi t1 t1 1
    j loop

print_three_digit:
    li a0 4
    la a1 three_digit
    ecall

    li a0 1
    mv a1 t6
    ecall

    li a0 4
    la a1 empty_space
    ecall

    addi t2 t2 1
    addi t0 t0 1
    addi t1 t1 1
    j loop

print_four_digit:
    li a0 4
    la a1 four_digit
    ecall

    li a0 1
    mv a1 t6
    ecall

    li a0 4
    la a1 empty_space
    ecall

    addi t2 t2 1
    addi t0 t0 1
    addi t1 t1 1
    j loop
