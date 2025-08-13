#! /usr/bin/env python3


import atexit
import socket
import sys
import subprocess
import re
import random
import os
from time import sleep

MOVES = 0

def replace(file, pattern, subst):
    # Read contents from file as a single string
    file_handle = open(file, 'r')
    file_string = file_handle.read()
    file_handle.close()

    # Use RE package to allow for replacement (also allowing for (multiline) REGEX)
    file_string = (re.sub(pattern, subst, file_string))

    # Write contents to file.
    # Using mode 'w' truncates the file.
    file_handle = open(file, 'w')
    file_handle.write(file_string)
    file_handle.close()

def read_until_newline(con):
    buff = ""
    while True:
        rcv = con.recv(2048)
        if len(rcv) == 0:
            return None
        dec = rcv.decode('UTF-8')
        buff += dec
        if '\n' in dec:
            return buff.replace("\n", "")




#create server socket
#in the next step the gui process will bind to it
HOST = 'localhost'
PORT = 55555
serversocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
serversocket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

try:
    serversocket.bind((HOST, PORT))
except socket.error:
    print("Failed to bind socket")
    sys.exit()

serversocket.listen(10)


# start gui subprocess
gui = subprocess.Popen(["java", "-jar", "gui.jar"])
print("GUI started")

conn, addr = serversocket.accept()
print("Connected to: " + addr[0] + " " + str(addr[1]))
serversocket.close()

#replace seed in main.asm
cmd = "git update-index --skip-worktree src/main.s"
os.system(cmd)
random.seed()
# replace('src/main.s', "li \$a0 [0-9]{4,4}", "li $a0 " + str(random.randint(1000, 9999)))
# replace('src/main.s', "li a0 [0-9]{4,4}", "li a0 " + str(random.randint(1000, 9999)))


# start MIPS program
# SOURCES = ["src/check_victory.asm", "src/main.asm", "src/buffer.asm", "src/merge.asm", "src/move_check.asm", "src/move_left.asm", "src/complete_move.asm",
#            "src/move_one.asm", "src/place.asm", "src/printboard.asm", "src/points.asm", "src/util.asm", ]
# proc = subprocess.Popen(["./mars", "ae127", "se126", "me", "nc", "sm", "10000000"] + SOURCES, stdin=subprocess.PIPE,
#                         stdout=subprocess.PIPE, stderr=subprocess.PIPE, encoding='UTF-8')
proc = subprocess.Popen(["./venus", "src/main.s"], stdin=subprocess.PIPE,
                        stdout=subprocess.PIPE, stderr=subprocess.PIPE, encoding='UTF-8')

#reade and write in- and output of the MIPS-program
input = proc.stdin
output = proc.stdout

# read greeting
output.readline()
output.readline()
input.write("0\n")  # set pretty_print to False
input.flush()

def cleanup():
    if proc.poll() is None:
        proc.kill()

atexit.register(cleanup)

while True:
    MOVES += 1
    # check if both subprocesses are still running
    if not proc.poll() is None or not gui.poll() is None:
        print("Subprocess died")
        sys.exit(1)

    # read the board state
    state = output.readline()

    if (" Game ends with " in state):
        state = output.readline()
        conn.send(state.encode())
        conn.send("Game Over\n".encode())
        sys.exit()

    # send state to gui
    conn.send(state.encode())

    # receive next move
    move = read_until_newline(conn)
    # if move is None the GUI was terminated
    if move is None:
        sys.exit()

    msg = ""
    if move == "NORTH":
        msg = "w"
    if move == "SOUTH":
        msg = "s"
    if move == "WEST":
        msg = "a"
    if move == "EAST":
        msg = "d"

    # send move to MIPS sim
    input.write(msg + "\n")
    input.flush()
    output.readline()  # read the newline character
