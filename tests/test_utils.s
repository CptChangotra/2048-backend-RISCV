.data
.globl assert_eq_board
.globl print_board_test

message_size:
.asciiz "Board Size: "

message_content:
.asciiz "Board Content: "

error_message:
.asciiz "\Assertion failed: Board was modified!"

.text

# -- assert_eq_board --
# a0 : board 1 (address of array of half words)
# a1 : board 2 (address of array of half words)
# a2 : size of both boards (number of elements in the array a0 and a1)
# Behaviour:
# Check if the board states are equal. If not, print the
# message "Assertion failed: Board was modified!" and exits the program.

# https://github.com/61c-teach/venus/wiki/Environmental-Calls

assert_eq_board:
    li t0 0

e_loop:
    bge t0 a2 success
	lhu t1 0(a0)
    lhu t2 0(a1)
	bne t1 t2 exit_board_modified

    addi t0 t0 1
    addi a0 a0 2
    addi a1 a1 2

	j e_loop

success:
	jr ra

exit_board_modified:
    la a0 error_message
	li a0 4
	ecall 
    li a0 10
    ecall 

# -- print_board_test --
# a0 : board (address of array of half words)
# a1 : size of the board (number of elements in the array a0)
# Behaviour:
# Print "Board Size: " followed by the size of the board.
# Print newline.
# Print "Board Content: " followed by the numbers from the
# sequence a0 separated by a space character
# Print newline.

print_board_test:
	mv t0 a0
	mv t1 a1

	la a1 message_size
	li a0 4
	ecall 


# print size
	li a0 1
	mv a1 t1
	ecall 
	li a0 11
	li a1 10 # '\n'
	ecall 

	la a1 message_content
	li a0 4
	ecall 

pr_loop:
	beqz t1 pr_exit
	lhu a1 0(t0)
# print value
	li a0 1
	ecall 
# print space
	li a0 11
	li a1 32 # ' '
	ecall 
	addi t0 t0 2
	addi t1 t1 -1
	j pr_loop

pr_exit:
	jr ra
