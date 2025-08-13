.text
.globl merge

#
#	a0 buffer address
#	a1 buffer length
#
#	|----|----|----|----|		|----|----|----|----|
#	|  2 |  2 |  0 |  4 |  => 	|  4 |  0 |  0 |  4 |
#	|----|----|----|----|		|----|----|----|----|
#
#   BONUS: Return the number of merges in a0 and the
#          total base score of the merges in a1.

merge:
    # Epilogue 
    addi sp sp -20
    sw ra 0(sp)
    #sw a0 4(sp)
    sw s1 4(sp)
    sw s2 8(sp)
    sw s0 12(sp)            # To store the merge counter.
    sw s7 16(sp)            # To store the total base score.
    # Epilogue ended
    
    li s0 0
    li s7 0
    li t0 0                 # Loop counter.
    addi s1 a1 -1           # s1 = MAX loop counter.

    # Memory leak happened because I stored a0 onto s1, which ultiamtely is also--
    # -- on the stack, hence confusing the memory with 2 address for the same thing.
    # Ghar ka nah ghaat ka, dushman RAM ka.


loop:
    bge t0 s1 end
    slli t1 t0 2            # Offset obtained.
    add t1 a0 t1            # Address obtained for [i] tile.
    lw t2 0(t1)             # Address loaded for [i] tile.
    lhu t3 0(t2)            # Tile value obtained [i]

    addi s2 t0 1            # s2 := Index counter for [i + 1] (We skipped one house in the street)
    slli t1 s2 2            # Offset for [i + 1] obtained := i offset + 4
    add t1 a0 t1            # Address obtained for [i + 1] tile.
    lw t4 0(t1)             # Address loaded for [i + 1] tile.
    lhu t5 0(t4)            # Tile value obtained [i + 1]

    beq t3 t5 merging
    j no_merge

merging:
    beq t3 zero no_merge
    add t3 t3 t5            # [i] = [i] + [i + 1]
    sw t3 0(t2)
    sw zero 0(t4)           # [i + 1] = 0
    addi t0 t0 1            # loopCounter++ ==> ultimately at line 33 iCounter++ and at line 38 nextTileCounter++
    addi s0 s0 1            # mergeCounter++
    add s7 s7 t3            # totalScore += newly merged tile [i] (after [i] + [i + 1])
    j loop

no_merge:
    addi t0 t0 1            # loopCounter++
    j loop

end:
    mv a0 s0
    mv a1 s7

    # Prologue
    lw ra 0(sp)
    #lw a0 4(sp)
    lw s1 4(sp)
    lw s2 8(sp)
    lw s0 12(sp)
    lw s7 16(sp)
    addi sp sp 20

    jr ra