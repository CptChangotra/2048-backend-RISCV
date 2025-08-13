.text
.globl move_one

#
#	a0 buffer address
#	a1 buffer length
#	t0 index
#	t1 offset

#
#	|----|----|----|----|----|		|----|----|----|----|----|
#	|  2 |  0 |  2 |  0 |  4 |	=> 	|  2 |  2 |  0 |  4 |  0 |
#	|----|----|----|----|----|		|----|----|----|----|----|
#
#	a0 1 iff something changed else 0

move_one:
    addi sp sp -16
    sw s1 0(sp)
    sw ra 4(sp)
    sw s0 8(sp)
    sw s2 12(sp)
    
    mv s0 a0          # Save buffer address in s0
    li t0 0           # Loop counter
    li t6 0           # Change boolean
    addi s1 a1 -1    # s1 = buffer length - 1
    
loop:

    beq t0 s1 end
    slli t1 t0 2
    add t1 s0 t1     # s0 is the same as the address pointer.
    lw t2 0(t1)       # t2: address of i tile
    lhu t3 0(t2)      # t3: value before swap i tile


    addi s2 t0 1     # Might be the reason of overbound!!!
    bge s2 s1 no_swap # Test for prevent overbound!!!!


    slli t1 s2 2     # Jump to next tile.
    add t1 s0 t1     # s0 is the same as the address pointer.
    lw t4 0(t1)       # t4: address of the i + 1 tile
    lhu t5 0(t4)      # t5: value before swap i + 1 tile
    bnez t5 swap
    
no_swap:
    addi t0 t0 1
    j loop
    
swap:
    # Store i + 1 in the address of i now
    bnez t3 no_swap
    sh t5 0(t2)
    sh zero 0(t4)
    addi t6 t6 1
    addi t0 t0 1
    j loop
    
end:
    # Set the return value based on whether changes were made.
    li a0 0           # Default to 0 (no changes)
    beq t6 zero prologue
    li a0 1           # Set to 1 if changes were made
    
prologue:
    # Restore saved registers
    lw s1 0(sp)
    lw ra 4(sp)
    lw s0 8(sp)
    lw s2 12(sp)
    addi sp sp 16
    
    jr ra