.data
.globl points


.text
# a0 board address
# a1 dirction  ( 'w','a','s','d')
#
# a0 should contain the points
#
# a = points gain this turn (naive)
# v = number of merges this turn
# points = a * 2 ^ (v - 1)
#
points:
	jr ra
