.data

board:
.half 0,0,0,0
.half 0,0,0,0
.half 0,0,0,0
.half 0,0,0,0

buffer:
.word 0,0,0,0
score:
.word 0

pretty_print:
.byte 1

greeterstr:
.asciiz "----- 2048 -----\n pretty print? (0/1)\n" 
movestr: 
.asciiz "Move (w/a/s/d/q): "

newline:
.asciiz "\n"
msgVictory1:
.asciiz " Game ends with "
msgVictory2:
.asciiz " points\n"

msgInvalid:
.asciiz "Invalid Input, please try again\n> "

.text

.import "util.s"
.import "place.s"
.import "buffer.s"
.import "check_victory.s"
.import "printboard.s"

.globl main

# main marks the programms entry point
main:
    li a0 6575

    jal random_init

    li a0 4
    la a1 greeterstr
    ecall #print greeting string

    # ask if pretty print should be enabled
    jal vscode_last_int
    la t0 pretty_print   
    sb a0 0(t0)

    la a0 buffer
    la a1 board
    jal init

    jal place_new
    jal place_new

    jal print_call

checkmove:
    la a0 board
    li a1 16
##################
    addi sp sp -4
    sw ra 0(sp)

    jal check_victory

    lw ra 0(sp)
    addi sp sp 4
##################
    li t0 1
    beq a0 t0 win
    li s1 0

movepos:
    li s0 4
    la s1 buffer
    la s2 board

    li a0 4
    la a1 movestr
    ecall

    jal vscode_last_char

    mv s4 a0                #accepted moves are w a s d
    li a0 4                    # input q to quit game
    la a1 newline
    ecall 
    li s6 1


    li s3 'w'
    beq s3 s4 w

    li s3 'a'
    beq s3 s4 a

    li s3 's'
    beq s3 s4 s

    li s3 'd'
    beq s3 s4 d

    li s3 'q'
    beq s3 s4 win

    li a0 4
    la a1 msgInvalid
    ecall 

j movepos

w:
    li a0 0
    li a1 8
    li a2 -22
    jal check_gen

    li t0 1
    bne a0 t0 invalid

    li a0 0
    li a1 8
    li a2 -22
    jal move_gen

    lw t0 score
    add t0 t0 a0
    la t1 score      
    sw t0 0(t1) 

j movedone

a:

    li a0 0
    li a1 2
    li a2 2
    jal check_gen

    li t0 1
    bne a0 t0 invalid

    li a0 0
    li a1 2
    li a2 2
    jal move_gen

    lw t0 score
    add t0 t0 a0
    la t1 score
    sw t0 0(t1)

j movedone


s:

    li a0 24
    li a1 -8
    li a2 26
    jal check_gen

    li t0 1
    bne a0 t0 invalid

    li a0 24
    li a1 -8
    li a2 26
    jal move_gen

    lw t0 score
    add t0 t0 a0
    la t1 score
    sw t0 0(t1)

j movedone


d:
    li a0 6
    li a1 -2
    li a2 14
    jal check_gen

    li t0 1
    bne a0 t0 invalid

    li a0 6
    li a1 -2
    li a2 14
    jal move_gen

    lw t0 score
    add t0 t0 a0
    la t1 score 
    sw t0 0(t1)

j movedone

movedone:
    la a0 buffer
    la a1 board
    jal place_new

invalid:
    li a0 24       #s
    li a1 -8
    li a2 26
    jal check_gen
    li t0 1
    beq a0 t0 not_lost

    li a0 6        #d
    li a1 -2
    li a2 14
    jal check_gen
    li t0 1
    beq a0 t0 not_lost

    li a0 0        #a
    li a1 2
    li a2 2
    jal check_gen
    li t0 1
    beq a0 t0 not_lost

    li a0 0        #w
    li a1 8
    li a2 -22
    jal check_gen
    li t0 1
    beq a0 t0 not_lost
j lost

not_lost:
# Print board after each turn
    jal print_call

j checkmove


lost:
win:
    li a0 4
    la a1 msgVictory1
    ecall 

    li a0 1
    la a1 score
    lw a1 0(a1)
    ecall 

    li a0 4
    la a1 msgVictory2
    ecall 

# Print final board
    jal print_call

# end the programm with syscall 10 (only allowed for "main")
    li a0 10
    ecall 




place_new:
##################
    addi sp sp -4
    sw ra 0(sp)

    jal random

    lw ra 0(sp)
    addi sp sp 4
##################
    li t0 10
    rem a0 a0 t0
    li t0 9            #test for rnd= 9 => place 4
    beq t0 a0 rnd4
    li a3 2#
j cont
rnd4:
    li a3 4#
cont:
##################
    addi sp sp -4
    sw ra 0(sp)

    jal random

    lw ra 0(sp)
    addi sp sp 4
##################
    li t0 16
    rem a0 a0 t0

tryagain:
    mv a2 a0
    la a0 board
    li a1 16

##################
    addi sp sp -4
    sw ra 0(sp)

    jal place

    lw ra 0(sp)
    addi sp sp 4
##################
    bnez a0 cont
    jr ra




print_call:

##################
    addi sp sp -4
    sw ra 0(sp)

    la a0 board
    li a1 16
    lbu t0 pretty_print
    beqz t0 print_board_line_2
    jal printboard
    jal ra print_linebreak
    j end_print_2
print_board_line_2:
    lw a2 score
    jal print_board_state_oneline
end_print_2:

    lw ra 0(sp)
    addi sp sp 4
##################

    ret

