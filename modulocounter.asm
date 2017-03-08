.text

li $t0 100
li $t2 16
div $t0 $t2

mflo $a0
li $v0 1
syscall

mfhi $a0
li $v0 1
syscall