.import move_left.s
.import merge.s

.text
.globl complete_move


#
#	a0 buffer address
#	a1 buffer length
#
#	|----|----|----|----|		|----|----|----|----|
#	|  2 |  2 |  0 |  4 |  => 	|  4 |  4 |  0 |  0 |
#	|----|----|----|----|		|----|----|----|----|
#
#   BONUS: Return the number of merges in a0 and the
#          total base score of the merges in a1.


complete_move:
    # Allocate.
    addi sp sp -20
    sw ra 0(sp)
    sw s0 4(sp)             # To preserve buffer address.       
    sw s1 8(sp)             # To preserve buffer length.
    sw s2 12(sp)            # To store the number of merges from merge.s.
    sw s3 16(sp)            # To store the score of merges from merge.s.        

    mv s0 a0                # Buffer address of row stored in s0.
    mv s1 a1                # Buffer length of row stored in s1.
    
    # Move left
    jal ra move_left
    
    # Merge
    mv a0 s0                # Restore buffer address for merge.
    mv a1 s1                # Restore buffer length for merge.
    jal ra merge            # merge.s returns a0 = no. of merges & a1 = score of merges.
    
    # Saving return values from merge.
    mv s2 a0  
    mv s3 a1  
    
    # Move left
    mv a0 s0  
    mv a1 s1  
    jal ra move_left

    
    mv a0 s2                # a0 extracted from merge returned.
    mv a1 s3                # a1 extracted from merge returned.
    
exit:
    # Free up.
    lw ra 0(sp)
    lw s0 4(sp)
    lw s1 8(sp)
    lw s2 12(sp)
    lw s3 16(sp)
    addi sp sp 20
    jr ra
