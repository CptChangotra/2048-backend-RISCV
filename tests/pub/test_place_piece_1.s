	.data
	.globl main

message:
	.asciiz "place returned: "

board:
	.half 0,0,0,0
	.half 0,0,0,0
	.half 0,0,0,0
	.half 0,0,0,0
	
	.text
.import "../../src/place.s"
.import "../../src/buffer.s"
.import "../../src/check_victory.s"
.import "../../src/printboard.s"

.import "../test_utils.s"

main:
	la a0 board
	li a1 16
	li a2 0
	li a3 2
	jal place	
	mv t0 a0
	la a1 message
	li a0 4
	ecall
	mv a1 t0
	li a0 1
	ecall
	li	a0 11	
	li	a1 10 # '\n'
	ecall
	la a0 board
	li a1 16
	jal print_board_test
	li	a0 10
	ecall
