.text
.globl move_check
#
# a0 buffer address
# a1 buffer length
#
# a0 == 1 iff left move possible and would change something
# else 0
#
move_check:
    addi sp, sp, -16
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
	sw a0 12(sp)
    
    li t5, 0            # Loop counter
    mv s0, a0           # s0 := buffer address
    addi s1, a1, -1     # s1 := MAX loop counter -- length - 1
    
loop:
    beq t5, s1, no_change
    
    # Tile [i]
    slli t0, t5, 2     # Offset for i = t5 * 4 (word-aligned).
    add t1, s0, t0     # Address of element i.
    lw t2, 0(t1)       # Load value at address.
    lhu t3, 0(t2)      # Load half-word from that address.
    
    # Tile [i + 1]
    addi t6, t5, 1     # i + 1
    slli t6, t6, 2     # Offset for i+1 = (t5 + 1) * 4.
    add t1, s0, t6     # Address of element i+1.
    lw t2, 0(t1)       # Load value at address.
    lhu t4, 0(t2)      # Load half-word from that address.
    
    beq t3, t4, same   	    # Check if tiles are the same.
    beq t3, zero, i_zero  	# Check if first tile is zero.

    
    addi t5, t5, 1     # Increment loop counter
    j loop             # Continue loop
    

same:
	beqz t4 skip
	bnez t4 change

skip:
	addi t5 t5 1
	j loop

change:
    li a0, 1
    j exit
    
i_zero:
	bnez t4 change
	addi t5 t5 1
	j loop

#iplus_zero:
#	addi t5 t5 1
#	j loop
    
no_change:
    li a0, 0
	j exit
    
exit:
    lw ra, 0(sp)       # Restore saved registers
    lw s0, 4(sp)
    lw s1, 8(sp)
	sw a0 12(sp)
    addi sp, sp, 16    # Restore stack pointer
    jr ra              # Return