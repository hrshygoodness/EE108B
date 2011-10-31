# pong.s

# Memory-mapped instructions
# --------------------------
# sw $s0, 0xff	-> store data in $s0 to VGA interface
# color in bits 18...16
# x in bits 13...8 (0 <= x < 40)
# y in bits 5...0 (0 <= y < 30)
#
# lw $s0, 0xfd	-> load data from Sega controller into $s0
# bits 4...0 = (b/c, right, left, down, up)

################
# With the exception of the memory mapped I/O devices,
# you should offset all memory accesses with $sp for 
# correct functioning in xspim.
#
# main function
# keep looping through, checking for user input and moving the
# ball around the screen until the game ends
###############

main:
	
	# initialize constants (feel free to change these)
	# remember that you cannot use the lower addresses in xspim (read the lab handout for explanation).
	addi	$t0, $0, 39		# maximum x coordinate
	sw		$t0, 0($sp)
	addi	$t0, $0, 29		# maximum y coordinate
	sw		$t0, 4($sp)
	add		$t0, $0, $0		# background color (black)
	sw		$t0, 8($sp)
	addi	$t0, $0, 0x02	# paddle color
	sw		$t0, 12($sp)
	addi	$t0, $0, 0x04	# ball color
	sw		$t0, 16($sp)
	addi	$t0, $0, 1		# ball height/width, paddle/width
	sw		$t0, 20($sp)
	addi	$t0, $0, 6		# paddle height
	sw		$t0, 24($sp)
	
	#initial ball state
	addi 	$t0, $0, 20		# initial ball x
	sw 		$t0, 28($sp)
	addi 	$t0, $0, 15		# initial ball y
	sw 		$t0, 32($sp)
	addi	$t1, $0, -1		# initial ball dx
	sw		$t1, 36($sp)
	addi	$t2, $0, -1		# initial ball dy
	sw		$t2, 40($sp)
		
	#initial paddle state
	addi 	$t0, $0, 0		# initial paddle x
	sw 		$t0, 44($sp)	
	addi 	$t0, $0, 12		# initial paddle y
	sw 		$t0, 48($sp)
	
	#initialize ball state
	lw 		$s0, 28($sp)	# $s0 = initial ball_x (20)
	lw 		$s1, 32($sp)	# $s1 = initial ball_y (15)

	# initial paddle state
	lw		$s2, 44($sp)	# $s2 = initial paddle_x (0...should always be 0)
	lw		$s3, 48($sp)	# $s3 = initial paddle_y (12)


game_loop:
		
	# cover up old ball/paddle by coloring them with background color


	# prepare to color region of board black. Lower left corner {x_min, y_max}
	# upper right corner is {x_max, y_min}
#	lw	$a0,0($0)
#	add $a1, $0, $0
#	sll $a1, $a1, 8
#	lw	$t0, 4($sp)
#	add $a1, $a1, $t0
#	lw  $a2, 0($sp)
#	sll	$a2, $a2, 8
#	add $a2, $a2, $0
#	jal	color_region


	# get user input and move paddle


	
	# move the ball vertically and horizontally	
							# ball_x = ball_x + dx
							# ball_Y = ball_y + dy
	
	# if the ball is at the left edge, determine if it
	# collided with the paddle, ending the game if it didn't
							# Lab1 = if ball hits edge (or paddle)
							# negate dx and dy for next update


	# draw the ball and paddle in their new positions
	lw  $a0, 16($sp)		# $a0 = ball color (0x04)
	add $a1, $0, $s0		# $a1 = initall ball_x (x0 = 20)
	add $a2, $0, $s1		# $a2 = initial ball_y (y0 = 15)
	jal color_ball
	lw	$a0, 12($sp)		# $a0 = paddle color (0x02) 0x004000ac
	add	$a1, $0, $s3		# $a1 = initial paddle_y (y0 = 12)
	jal	color_paddle


	# stall for a while so the paddle and ball don't move too quickly.
	# change this code if you want to vary the game speed.
	
	lui	$a0, 0x4
	ori	$a0, $a0, 0xffff	# stall for 0x4ffff
	jal	stall
	
	j game_loop
	
	# game over: keep looping until the restart button is pressed,
	# then start a new game
	
###############
# function: stall
# arguments:
#   $a0: number of cycles (x3) to stall for
###############

stall:
	add	 $t0, $0, $0
stall_loop:
	beq	 $t0, $a0, end_stall
	addi $t0, $t0, 1
	j	 stall_loop
end_stall:
	jr	 $ra
	
###############
# function: color_ball
# arguments:
#   $a0: color of the ball
#   $a1: x coordinate of lower left corner of ball
#   $a2: y coordinate of lower left corner of ball
###############

color_ball:
	add $t5, $a1, $0	# $t5 = x-coord
	add $t6, $a2, $0	# $t6 = y-coord

	sll	 $a1, $a1, 8
	add	 $a1, $a1, $a2	# $a1 = {x,y}
	add	 $a2, $t5, $0 
	sll	 $a2, $a2, 8
	add	 $a2, $a2, $t6	# $a2 = {x,y}
	jal	 color_region
	jr	 $ra

		
#	add  $t0, $0, $a0
#	sll  $t0, $t0, 8
#	add  $t0, $t0, $a1
#	sll  $t0, $t0, 8
#	add  $t0, $t0, $a2
#	sw 	 $t0, 0xFF($0)
#	jr	 $ra
		

###############
# function: color_paddle
# arguments:
#   $a0: color of the paddle
#   $a1: y coordinate of bottom of paddle
###############

color_paddle:
	add	 $t6, $0, $a1	# $t6 = y-coord of bottom paddle
	add	 $t3, $0, $0		# initialize i to 0. $t3 = 0
	lw	 $t4, 24($sp)	# $t4 = height of the paddle, $t4 = 24($sp)
	j	 test0			# create a for loop that colors from the bottom of paddle
							# to top of paddle
loop0:	
	sll	 $t0, $a0, 16	# Set paddle color. paddle_x doesn't change
	add	 $t0, $t0,$t6	# Set paddle_y file for color update
	sw	 $t0, 0xFF($0)
	addi $t6, $t6, 1		# increment position along paddle by 1
	addi $t3, $t3, 1		# increment i by 1			
test0:
	slt	 $t5, $t3, $t4
	bne	 $t5, $0, loop0	# if i ($t3) < paddle height, goto loop1
	jr	 $ra

###############
# function: color_region
# arguments:
#   $a0: color of region
#   $a1: coordinate of lower left corner of region
#        x in bits 13...8, y in bits 5...0
#   $a2: coordinate of upper right corner of region
#        x in bits 13...8, y in bits 5...0
###############

color_region:
#	add	 $t0, $0, $0		# i = 0, $t0 = 0 (i iterates over x)
#	add	 $t3, $0, $0		# j = 0, $t3 = 0 (j iterates over y)
	andi $t4, $a1, 0x3F		# $t4 = y_max
#	add	 $t0, $0, $t4		# i = x_min
	andi $t5, $a1, 0x3F00	# get mask of x-coordinate 
	srl	 $t5, $t5, 0x08		# $t5 = x_min. Shift down the x-coord to get the x_min
    addi $t4, $t4, 1      	# increment y_max by 1 to account for limit test with slt
	andi $t6, $a2, 0x3F		# $t6 = y_min
	andi $t7, $a2, 0x3F00	# get mask of x-coordinate 
	srl	 $t7, $t7, 0x08		# $t7 = x_max. Shift down the x-coord to get the x_max
	addi $t7, $t7, 1		# increment x_max by 1 to account for limit test with slt
	j	 test1Outer
loop1Outer:
	j	 test1Inner		
loop1Inner:
	add	 $t0, $0, $a0
	sll	 $t0, $t0, 8		# shift 3-bit color mask to bit 8
	add	 $t0, $t0, $t5
	sll	 $t0, $t0, 8		# place x-coord data in bitfield and shift left by 8
	add	 $t0, $t0, $t6		# place y-coord data in bitfield
	sw	 $t0, 0xFF($0)
	addi $t5, $t5, 1		# increment inner-loop index by 1
test1Inner:
	slt	 $t8, $t5, $t7
	bne	 $t8, $0, loop1Inner# if x < x_max, goto loop1Inner
	addi $t6, $t6, 1		# increment outer-loop index
test1Outer:
	slt	 $t8, $t6, $t4	
	bne	 $t8, $0, loop1Outer# if y < y_max goto loop1Outer
	jr	 $ra

