.data
    .globl main
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
    li a1 4
    li a2 4

    jal printboard

    li a0 10
    ecall
