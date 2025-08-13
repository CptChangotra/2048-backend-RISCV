	.data
	.globl main

message:
	.asciiz "check_victory returned: "

board:
	.half 2048,0,0,0
	.half 0,0,0,0
	.half 0,0,0,0
	.half 0,0,0,0

unmodified_copy:
	.half 2048,0,0,0
	.half 0,0,0,0
	.half 0,0,0,0
	.half 0,0,0,0
	
	.text

# .import "../../src/util.s" # done by printboard
.import "../../src/place.s"
.import "../../src/buffer.s"
.import "../../src/check_victory.s"
.import "../../src/printboard.s"

.import "../test_utils.s"

main:
	la a0 board
	li a1 16
	jal check_victory
	mv t0 a0

	li a0 4
	la a1 message
	ecall

	li a0 1
	mv a1 t0
	ecall

	la a0 board
	la a1 unmodified_copy
	li a2 16
	jal assert_eq_board
	li	a0 10
	ecall
