.data
.globl random
.globl random_init
.globl print_board_state_oneline
.globl print_linebreak
.globl vscode_last_char
.globl vscode_last_int

rand:
.word 0

newline:
.asciiz "\n"

.text

############################
#a0 new random number
# next = ((next * 110351524 +12345) / (2^16)) % (2^15)
random:								# pseudo random number
	lw a0 rand
	li t0 110351524
	mul a0 a0 t0 
	li t0 12345
	add a0 a0 t0
	li t0 1
	sll a0 a0 t0
	li t0 17
	srl a0 a0 t0
	la t0 rand
	sw a0 0(t0)
	jr ra



# a0 seed
random_init:
	la t0 rand
	sw a0 0(t0)
	jr ra


# -- print_board_state_oneline --
# (Only used by main to interface with the GUI)
# a0 : board (address of array of half words)
# a1 : size of the board (number of elements in the array a0)
# a2 : points
# Behaviour:
# Print the board in row major order and seperate fields by a space character.
# Print points (after space).
# Print newline.

print_board_state_oneline:
	mv t0 a0
	mv t1 a1

pr2_loop:
	beqz t1 pr2_exit
	lhu a1 0(t0)
# print value
	li a0 1
	ecall 
# print space
	li a0 11
	li a1 ' '
	ecall 
	addi t0 t0 2
	addi t1 t1 -1
	j pr2_loop

pr2_exit:
# print points
	mv a1 a2
	li a0 1
	ecall 

	li a0 11
	li a1 10 # '\n'
	ecall 
	jr ra


print_linebreak:
    la a1 newline
    li a0 4
    ecall
    ret 


# reads inputs (and returns bit-concated in a0)
vscode_input:
	# activate terminal
    li a0 0x130
    ecall 

    # now an input can be made (and sent using enter)
    # afterward, the terminal needs to be activated again for new input

    li t0, 0                  # accumulator for number

vscode_input_poll:
    li a0 0x131
    ecall
    li t1 1
    beq a0 t1 vscode_input_poll    # a0 = 1 waiting for input 
	li t1 0
    beq a0 t1 vscode_input_done    # a0 = 0 all input read (buffer empty)
	# a0 = 2 input available (one character read) ==> accumulate
    
    slli t0 t0 8             
    or t0 t0 a1             

    j vscode_input_poll

vscode_input_done:
    mv a0 t0                 # return accumulated string
    ret



vscode_last_char:
	# save return adress 
    addi sp sp -4
    sw ra 0(sp)

	# get input 
    jal vscode_input

	# cut last char
    li t0 255
    and a0 a0 t0

	# get old return adress 
    lw ra 0(sp)
    addi sp sp 4
    ret



vscode_last_int:
	# save return adress 
    addi sp sp -4
    sw ra 0(sp)

	# get last char 
    jal vscode_last_char

	# convert to int
    li t0 48            # ASCII '0'
    sub a0 a0 t0        # convert char to digit

	# get old return adress 
    lw ra 0(sp)
    addi sp sp 4
    ret
	
	