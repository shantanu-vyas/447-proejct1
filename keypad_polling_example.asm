	# CS 447 - Spring 2016
	#
	# demonstrates how to poll the keypad in the LED Display Simulator for
	# input, i.e., one of the arrow keys or the center button being pressed.
	# the program cycles through the possible LED colors by drawing a box in
	# the center of the display with some color.  the right arrow key increments
	# the color, and the left arrow key decrements it. the colors wrap around.
	#
	li	$s1,1			# $s1 holds current box color
	move	$a0,$s1			# draw initial box
	jal	_drawBox
poll:	la	$v0,0xffff0000		# address for reading key press status
	lw	$t0,0($v0)		# read the key press status
	andi	$t0,$t0,1
	beq	$t0,$0,poll		# no key pressed
	lw	$t0,4($v0)		# read key value
lkey:	addi	$v0,$t0,-226		# check for left key press
	bne	$v0,$0,rkey		# wasn't left key, so try right key
	addi	$s1,$s1,-1		# decrement current color
	andi	$s1,$s1,3		# mask high bits after decrement
	move	$a0,$s1			# argument for call
	jal	_drawBox		# redraw box in new color
	j	poll
rkey:	addi	$v0,$t0,-227		# check for right key press
	bne	$v0,$0,bkey		# wasn't right key, so check for center
	addi	$s1,$s1,1		# increment current color
	andi	$s1,$s1,3		# mask high bits after increment
	move	$a0,$s1			# argument for call
	jal	_drawBox		# redraw box in new color
	j	poll
bkey:	addi	$v0,$t0,-66		# check for center key press
	bne	$v0,$0,poll		# invalid key, ignore it
	li	$v0,10			# terminate program
	syscall
	
	# draws a box at (29,29) to (34,34) of the color indicated in $a0
_drawBox:
	addi	$sp,$sp,-4		# non-leaf, save some stack space
	sw	$ra,0($sp)
	move	$a2,$a0			# copy color to $a2
	li	$a0,29
	li	$a1,29
_drawBoxL:
	jal	_setLED
	addi	$a0,$a0,1		# increment x
	slti	$t0,$a0,35
	bne	$t0,$0,_drawBoxL
	li	$a0,29			# reset x position
	addi	$a1,$a1,1		# increment y
	slti	$t0,$a1,35
	bne	$t0,$0,_drawBoxL
	lw	$ra,0($sp)		# reload spilled $ra value
	addi	$sp,$sp,4
	jr	$ra
		
	# void _setLED(int x, int y, int color)
	#   sets the LED at (x,y) to color
	#   color: 0=off, 1=red, 2=orange, 3=green
	#
	# warning:   x, y and color are assumed to be legal values (0-63,0-63,0-3)
	# arguments: $a0 is x, $a1 is y, $a2 is color 
	# trashes:   $t0-$t3
	# returns:   none
	#
_setLED:
	# byte offset into display = y * 16 bytes + (x / 4)
	sll	$t0,$a1,4      # y * 16 bytes
	srl	$t1,$a0,2      # x / 4
	add	$t0,$t0,$t1    # byte offset into display
	li	$t2,0xffff0008	# base address of LED display
	add	$t0,$t2,$t0    # address of byte with the LED
	# now, compute led position in the byte and the mask for it
	andi	$t1,$a0,0x3    # remainder is led position in byte
	neg	$t1,$t1        # negate position for subtraction
	addi	$t1,$t1,3      # bit positions in reverse order
	sll	$t1,$t1,1      # led is 2 bits
	# compute two masks: one to clear field, one to set new color
	li	$t2,3		
	sllv	$t2,$t2,$t1
	not	$t2,$t2        # bit mask for clearing current color
	sllv	$t1,$a2,$t1    # bit mask for setting color
	# get current LED value, set the new field, store it back to LED
	lbu	$t3,0($t0)     # read current LED value	
	and	$t3,$t3,$t2    # clear the field for the color
	or	$t3,$t3,$t1    # set color field
	sb	$t3,0($t0)     # update display
	jr	$ra
