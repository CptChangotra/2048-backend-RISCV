.text
.globl place

# 	a0 board address
# 	a1 board length
#	a2 field number to place into
#	a3 number to place
#   t0 address proxy
#   t1 extracted half word from target tile
#   t2 zero as a test for emptiness
#
#	a0 == 0 iff place succesfull else 1
#

place:
	li t0 0
    li t2 0
    # Go to tile
    j go_to_tile


check_empty:
#   Load the half word
    lhu t1 0(t0)
#   If half word is empty beq, then do lay the tile.
    beq t1 t2 laying_the_tile
#   Else do nothing.
    j exit


go_to_tile:
#   Do a left shift on t2 a2 times to get the offset,--
#   --given a2 is the integer index
    slli t2 a2 1
#   Complete target address t0 proxy by adding starting --
#   -- address and offset
#   Target = Starting + Offset (derived from index)
    add t0 a0 t2
    j check_empty


laying_the_tile:
#   sh store half word a3
    sh a3 0(t0)
    li a0 0
    jr ra

exit:
    li a0 1
    jr ra
