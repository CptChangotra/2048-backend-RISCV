.import move_one.s

.text
.globl move_left

#
#	a0 buffer address
#	a1 buffer length
#
#	|----|----|----|----|		|----|----|----|----|
#	|  0 |  2 |  0 |  4 |	=> 	|  2 |  4 |  0 |  0 |
#	|----|----|----|----|		|----|----|----|----|
#

move_left:
    addi sp sp -12
    sw a0 0(sp)
    sw ra 4(sp)
    sw s2 8(sp)
    addi s2 a1 -1
    li t0 0         # Loop counter.

    # Once the loop iterates, a0 and a1 get overwritten by --
    # -- move_one.s, so we need to preserve them in s(x)--
    # -- so that we could reload the original a0 and a1 -- 
    # -- back for the next iteration.
    mv s0 a0        # Preserve address pointer to s0.
    mv s1 a1        # Preserve length counter to s1.

loop:
    beq t0 s2 end

    mv a0 s0        # Load back the address pointer to a0.
    mv a1 s1        # Load back the length counter to a1.
    jal ra move_one # move_one's return value decides if the loop ends or not.
    # a0 and a1 now get overwritten, but get restored at --
    # -- line 33-34 for the next iteration thanks to line 27-28.
    addi t0 t0 1    # loopCounter++
    bnez a0 loop    # if a0 != 0, loop again -- else go below for the end.
    j end

end:
    lw s0 0(sp)
    lw ra 4(sp)
    lw s2 8(sp)
    addi sp sp 12
    jr ra