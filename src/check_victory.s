.text
.globl check_victory


#
#	a0 board address (address) (extraction with loading)
#	a1 board length (integer: direct operations)
#
#	a0 == 1 if 2048 found
#

check_victory:
    addi sp sp -16
    sw ra 0(sp)
    sw s0 4(sp)
    sw s1 8(sp)

    li t0 0         # O+++ffset
    li t3 0         # Tile counter
    mv s0 a0        # s0 := Address
    mv s1 a1        # s1 := MAX counter 
    li s2 2048      # s2 := 2048 for Comparison

loop:
    beq t3 s1 end
    slli t0 t0 1
    add t1 s0 t0
    lhu t2 0(t1)    # t2 := Half word
    bge t2 s2 won
    addi t3 t3 1
    j loop

won:
    li a0 1

    sw ra 0(sp)
    sw s0 4(sp)
    sw s1 8(sp)
    sw s2 12(sp)
    addi sp sp 16

    jr ra

end:
    li a0 0

    sw ra 0(sp)
    sw s0 4(sp)
    sw s1 8(sp)
    sw s2 12(sp)
    addi sp sp 16

    jr ra