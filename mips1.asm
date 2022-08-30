###################################################################### 
# CSCB58 Summer 2022 Project 
# University of Toronto, Scarborough 
# 
# Student Name: Vikram Chandra Narra, Student Number: 1007846048, UTorID: Narravik
# 
# Bitmap Display Configuration: 
# - Unit width in pixels: 8 
# - Unit height in pixels: 8 
# - Display width in pixels: 256 
# - Display height in pixels: 256 
# - Base Address for Display: 0x10008000 
# 
# Basic features that were implemented successfully 
# - Basic feature a/b/c (all were applied)
# 
# Additional features that were implemented successfully 
# - Additional Features a/b/c (all were applied)
# - Idk if made it clear in the video but the cars accelerate faster for each level
#
# - Firstly, the theme of the game is Gotham City. We follow the adventure of joker, as he 
#   swerves and veers past incoming officers who are out to get him. Can you make him escape?
# - Created relative velocity, so that it appears that the car is Speeding very quickly, 
#   relative to the other cars on the screen, by using the illusion of the cars on the right side. 
# - When the cars on the right are stationary that means that the user is travelling at the same speed as them. 
#
# Link to the video demo 
# - https://utoronto.zoom.us/rec/share/kiiCnSr4y-OG0aPMo7XsE2IDNsvFuO6H2dRO5JqOthPdA9GpVaLx9wKfGFMSMJFy.aXV8IMLZCZ93Yt4L?startTime=1660270206000
# 
# Any additional information that the TA needs to know: 
# - Firstly, the theme of the game is Gotham City. We follow the adventure of joker, as he 
#   swerves and veers past incoming officers who are out to get him. Can you make him escape?
# - Created relative velocity, so that it appears that the car is Speeding very quickly, 
#   relative to the other cars on the screen, by using the illusion of the cars on the right side. 
# - When the cars on the right are stationary that means that the user is travelling at the same speed as them. 
######################################################################
    .eqv    BLACK               0x000000
    .eqv    GRAY		 0x808080
    .eqv    WHITE               0xffffff
    .eqv    YELLOW              0xf29200
    .eqv    ORANGE              0xf26200
    .eqv    BLUE                0x2391ff
    .eqv    GREEN               0x1ed760
    .eqv    PURPLE              0xb006f0
    .eqv    RED                 0xda4032
    .eqv    PINK		 0xffc0cb


    .eqv	KEY_EVNT    0xFFFF0000	# keystroke event logger
    .eqv	KEY_W	    0x00000077	# hex value for ASCII code 'w'  // jumping
    .eqv	KEY_A	    0x00000061	# hex value for ASCII code 'a'  // Left
    .eqv	KEY_S	    0x00000073	# hex value for ASCII code 's'  // Right    
    .eqv	KEY_D	    0x00000064	# hex value for ASCII code 'd'  // down
    .eqv	KEY_Q	    0x00000071	# hex value for ASCII code 'q'  // Exit
    
    
    .data
    	display_address: 	.word 0x10008000
    	powerup1:		.word -248		#132 - 248 (29 span * 128) [Blue] +1 Life
    	powerup2:		.word -248		#132 - 248 (29 span * 128) [Orange] Car will be invisible
    	lives:			.word 2	#Lives [2, 1, 0, (-1)]
    	progress:		.word 0
    	tempVar:		.word 0
    	powerupActivated:	.word 0 #1 - means that an extra life was touched, 2 means that the car will be invisible
	constants:		.word 4096, 6144, 8192, 10240
	invisible:		.word 0
	difficulty:		.word 100
    .text

    	main:
	addi $s0, $zero, 0 # Time
    	addi $s1, $zero, 1960  #New Car position (1928, 1960, 1992, 2024)
    	addi $s2, $zero, 1 #Enemies Speed (Factor of 128 per frame) [1,2,3] (Left)
    	addi $s3, $zero, 0 #Enemies Speed (Factor of 128 per frame) [1,2,3] (Right)
    	addi $s4, $zero, -760 #Enemy Car 1 -760 (8 - 3464)
    	addi $s5, $zero, -3672 #Enemy Car 2 (40 - 3496)
    	addi $s6, $zero, 2760 #Enemy Car 3 (3528 - 72)
    	addi $s7, $zero, 3176 #Enemy Car 4 (3560 - 104)
	
      	jal color
	jal spawn_car
	
	
    	mini1:
	li $t9, 0xffff0000
	lw $t8, 0($t9)
	beq $t8, 1 ,mini2
	j mini1
	mini2:
	lw $t2, 4($t9)
    	beq $t2, KEY_Q, main_loop
    	j mini2
	
	main_loop:
	addi $s0, $s0, 1
	beq $s0, 1000, game_finished
	lw $t0, lives
	beq $t0, -1, game_over
	
	beq $s0, 1, level1_screen
	beq $s0, 333, level2_screen
	beq $s0, 666, level3_screen
	inter:
	beq $s0, 333, difficulty1
	beq $s0, 666, difficulty2
	relay:
	beq $s0, 200, generate_powerup2
	beq $s0, 400, generate_powerup2
	beq $s0, 600, generate_powerup2
	beq $s0, 800, generate_powerup2
	beq $s0, 100, generate_powerup1
	beq $s0, 300, generate_powerup1
	beq $s0, 500, generate_powerup1
	beq $s0, 700, generate_powerup1
	beq $s0, 900, generate_powerup1
	continue:
	
	jal take_input
	jal move_car_up1
	jal move_car_up2
	jal move_car_down1
	jal move_car_down2
	

	lw $t0, powerupActivated
	beq $t0, 2, incrementer
	interlap:
	lw $t0, powerupActivated
	bgt $t0, 0, continue2
	#----------------------------------Check for Collision----------
	addi $sp, $sp, -4
	sw $s4, 0($sp)
	jal enemy_collision
	addi $t0, $t0, -4
	sw $s5, 0($sp)
	jal enemy_collision
	addi $sp, $sp, -4
	sw $s6, 0($sp)
	jal enemy_collision
	addi $sp, $sp, -4
	sw $s7, 0($sp)
	jal enemy_collision
	jal powerup_activated_collision

	#---------------------------------REdraw-----------------------
	continue2:
	jal color

	jal print
	jal display_progres
	jal bonus_life
	jal invisibility
	
	addi $sp, $sp, -4
	sw $s4, 0($sp)	
	jal spawn_enemy_car1
	addi $sp, $sp, -4
	sw $s5, 0($sp)	
	jal spawn_enemy_car1
	addi $sp, $sp, -4
	sw $s6, 0($sp)	
	jal spawn_enemy_car2
	addi $sp, $sp, -4
	sw $s7, 0($sp)	
	jal spawn_enemy_car2
	
	jal spawn_car
	#-------------------------------------
	
	lw $t0, difficulty
	li $v0, 32
	move $a0, $t0
	syscall
	
	j main_loop
	
#--------------------------------------------------------------END LOOP-------------------------------------------
	difficulty1:
	la $t0, difficulty
	addi $t1, $0, 75
	sw $t1, 0($t0)
	j relay
	difficulty2:
	la $t0, difficulty
	addi $t1, $0, 50
	sw $t1, 0($t0)
	j relay
	incrementer:
	la $t0, invisible
	lw $t1, 0($t0)
	beq $t1, 50, end_perk
	addi $t1, $t1, 1
	sw $t1, 0($t0)
	j interlap
	end_perk:
	la $t0, invisible
	sw $0, 0($t0)
	
	la $t1, powerupActivated
	sw $0, 0($t1)
	j interlap

	game_over:
	jal game_over_screen
	
    	lw $t0, display_address
    	li $t1, BLUE
    	jal write_G
    	lw $t0, display_address
    	addi $t0, $t0, 24
        jal write_A
    	lw $t0, display_address
    	addi $t0, $t0, 48
        jal write_M
        lw $t0, display_address
    	addi $t0, $t0, 72
        jal write_E
    	lw $t0, display_address
    	li $t1, BLUE
    	addi $t0, $t0, 1024
    	jal write_O
    	lw $t0, display_address
    	addi $t0, $t0, 24
        addi $t0, $t0, 1024
        jal write_V
    	lw $t0, display_address
    	addi $t0, $t0, 48
        addi $t0, $t0, 1024
        jal write_E
        lw $t0, display_address
    	addi $t0, $t0, 72
        addi $t0, $t0, 1024
        jal write_R
        addi $s0, $zero, 0 # Time
    	addi $s1, $zero, 1960  #New Car position (1928, 1960, 1992, 2024)
    	addi $s2, $zero, 1 #Enemies Speed (Factor of 128 per frame) [1,2,3] (Left)
    	addi $s3, $zero, 0 #Enemies Speed (Factor of 128 per frame) [1,2,3] (Right)
    	addi $s4, $zero, -760 #Enemy Car 1 -760 (8 - 3464)
    	addi $s5, $zero, -2520 #Enemy Car 2 (40 - 3496)
    	addi $s6, $zero, 2120 #Enemy Car 3 (3528 - 72)
    	addi $s7, $zero, 3176 #Enemy Car 4 (3560 - 104)
    	
    	j loop1

    	loop1:
	li $t9, 0xffff0000
	lw $t8, 0($t9)
	beq $t8, 1 ,loop2
	j loop1
	loop2:
	lw $t2, 4($t9)
    	beq $t2, KEY_Q, loop3
    	j loop2
    	
    	loop3:
    	 	
    	jal color
	jal spawn_car
	
	addi $sp, $sp, -4
	sw $s4, 0($sp)	
	jal spawn_enemy_car1
	addi $sp, $sp, -4
	sw $s5, 0($sp)	
	jal spawn_enemy_car1
	addi $sp, $sp, -4
	sw $s6, 0($sp)	
	jal spawn_enemy_car2
	addi $sp, $sp, -4
	sw $s7, 0($sp)	
	jal spawn_enemy_car2
	
	jal reset_lives

	la $t0, progress
	sw $0, 0($t0)

	
	
	j main_loop
	

	game_finished:
	jal game_finished_screen
	lw $t0, display_address
    	li $t1, WHITE
    	jal write_G
    	lw $t0, display_address
    	addi $t0, $t0, 24
        jal write_A
    	lw $t0, display_address
    	addi $t0, $t0, 48
        jal write_M
        lw $t0, display_address
    	addi $t0, $t0, 72
        jal write_E
    	lw $t0, display_address
    	li $t1, BLUE
    	addi $t0, $t0, 1024
    	jal write_O
    	lw $t0, display_address
    	addi $t0, $t0, 24
        addi $t0, $t0, 1024
        jal write_V
    	lw $t0, display_address
    	addi $t0, $t0, 48
        addi $t0, $t0, 1024
        jal write_E
        lw $t0, display_address
    	addi $t0, $t0, 72
        addi $t0, $t0, 1024
        jal write_R
	addi $s0, $zero, 0 # Time
    	addi $s1, $zero, 1960  #New Car position (1928, 1960, 1992, 2024)
    	addi $s2, $zero, 1 #Enemies Speed (Factor of 128 per frame) [1,2,3] (Left)
    	addi $s3, $zero, 0 #Enemies Speed (Factor of 128 per frame) [1,2,3] (Right)
    	addi $s4, $zero, -760 #Enemy Car 1 -760 (8 - 3464)
    	addi $s5, $zero, -2520 #Enemy Car 2 (40 - 3496)
    	addi $s6, $zero, 2120 #Enemy Car 3 (3528 - 72)
    	addi $s7, $zero, 3176 #Enemy Car 4 (3560 - 104)
    	
    	j loop1a

    	loop1a:
	li $t9, 0xffff0000
	lw $t8, 0($t9)
	beq $t8, 1 ,loop2a
	j loop1a
	loop2a:
	lw $t2, 4($t9)
    	beq $t2, KEY_Q, loop3a
    	j loop2a
    	
    	loop3a:
    	 	
    	jal color
	jal spawn_car
	
	addi $sp, $sp, -4
	sw $s4, 0($sp)	
	jal spawn_enemy_car1
	addi $sp, $sp, -4
	sw $s5, 0($sp)	
	jal spawn_enemy_car1
	addi $sp, $sp, -4
	sw $s6, 0($sp)	
	jal spawn_enemy_car2
	addi $sp, $sp, -4
	sw $s7, 0($sp)	
	jal spawn_enemy_car2
	
	jal reset_lives

	la $t0, progress
	sw $0, 0($t0)
	jal display_progres
	
	
	j main_loop


#-------------------------------------------------------------------------------------------------------------------
	level1_screen:
	jal white_screen
	jal one
	li $v0, 32
	li $a0, 1000
	syscall
	j inter
	
	level2_screen:
	jal white_screen
	jal two
	li $v0, 32
	li $a0, 1000
	syscall
	j inter

	level3_screen:
	jal white_screen
	jal three
	li $v0, 32
	li $a0, 1000
	syscall
	j inter
	
	
	
	
	
	two:
	li $t1, RED
	lw $t3, display_address
	addi $t3, $t3, 64
	addi $t3, $t3, 1792
	sw $t1, 4($t3)
	sw $t1, 8($t3)
	sw $t1, 12($t3)
	sw $t1, 140($t3)
	sw $t1, 268($t3)
	sw $t1, 264($t3)
	sw $t1, 260($t3)
	sw $t1, 388($t3)
	sw $t1, 516($t3)
	sw $t1, 520($t3)
	sw $t1, 524($t3)
	jr $ra

	
	one:
	li $t1, RED
	lw $t3, display_address
	addi $t3, $t3, 64
	addi $t3, $t3, 1792
	sw $t1, 8($t3)
	sw $t1, 136($t3)
	sw $t1, 264($t3)
	sw $t1, 392($t3)
	sw $t1, 520($t3)
	jr $ra
	three:
	li $t1, RED
	lw $t3, display_address
	addi $t3, $t3, 64
	addi $t3, $t3, 1792
	sw $t1, 4($t3)
	sw $t1, 8($t3)
	sw $t1, 12($t3)
	sw $t1, 140($t3)
	sw $t1, 264($t3)
	sw $t1, 268($t3)
	sw $t1, 396($t3)
	sw $t1, 524($t3)
	sw $t1, 520($t3)
	sw $t1, 516($t3)


	jr $ra

	reset_lives:
	la $t0, lives
	addi $t2, $0, 2
	sw $t2, 0($t0)
	jr $ra
	
	
	collision_happened:
	addi $s0, $0, 0
	la $t0, progress
	sw $0, 0($t0)
	addi $t0, $0, 0
	addi $t1, $0, 0
	la $t0, lives
	lw $t1, 0($t0)
	addi $t1, $t1, -1
	sw $t1, 0($t0)
	li $v0, 1
	move $a0, $t1
	syscall
	

    	addi $s1, $zero, 1960  #New Car position (1928, 1960, 1992, 2024)
    	addi $s2, $zero, 1 #Enemies Speed (Factor of 128 per frame) [1,2,3] (Left)
    	addi $s3, $zero, 0 #Enemies Speed (Factor of 128 per frame) [1,2,3] (Right)
    	addi $s4, $zero, -760 #Enemy Car 1 -760 (8 - 3464)
    	addi $s5, $zero, -2520 #Enemy Car 2 (40 - 3496)
    	addi $s6, $zero, 2120 #Enemy Car 3 (3528 - 72)
    	addi $s7, $zero, 3176 #Enemy Car 4 (3560 - 104)
    	
	jal color
	jal spawn_car
	
	addi $sp, $sp, -4
	sw $s4, 0($sp)	
	jal spawn_enemy_car1
	addi $sp, $sp, -4
	sw $s5, 0($sp)	
	jal spawn_enemy_car1
	addi $sp, $sp, -4
	sw $s6, 0($sp)	
	jal spawn_enemy_car2
	addi $sp, $sp, -4
	sw $s7, 0($sp)	
	jal spawn_enemy_car2
	


	li $v0, 32
	li $a0, 1000
	syscall
	j main_loop
	#Lose a life
	#Restart the positions of the game (press q) to start
	

	display_progres: #Checked
	addi $t9, $0, 32
	div $s0, $t9
	mflo $t1
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	lw $t8, progress
    	lw $t0, display_address
	lw $t3, display_address
	li $t2, 0
	li $t4, GREEN
	
	mul $t9, $t1, 128


	progress_loop:	#Checked
    	bge $t2, $t9, exit
    	sw $t4, 0($t3)
    	addi $t2, $t2, 128
    	add $t3, $t0, $t2
    	j progress_loop 
    	
	exit: #Checked
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	

	#New Car position (1928, 1960, 1992, 2024)
	generate_powerup1:	
	li $v0, 42
	li $a0, 0
	li $a1, 4
	syscall
	beq $a0, 0, set1
	beq $a0, 1, set2
	beq $a0, 2, set3
	beq $a0, 3, set4
	
	j continue
	set1:
	la $t0, powerup1
	addi $t1, $0, 1928
	beq $t1, $s1, generate_powerup1
	lw $t8, powerup2
	beq $t1, $t8, generate_powerup1
	sw $t1, 0($t0)
	j continue
	set2:
	la $t0, powerup1
	addi $t1, $0, 1960
	beq $t1, $s1, generate_powerup1
	lw $t8, powerup2
	beq $t1, $t8, generate_powerup1
	sw $t1, 0($t0)
	j continue
	set3:
	la $t0, powerup1
	addi $t1, $0, 1992
	beq $t1, $s1, generate_powerup1
	lw $t8, powerup2
	beq $t1, $t8, generate_powerup1
	sw $t1, 0($t0)
	j continue
	set4:
	la $t0, powerup1
	addi $t1, $0, 2024
	beq $t1, $s1, generate_powerup1
	lw $t8, powerup2
	beq $t1, $t8, generate_powerup1
	sw $t1, 0($t0)
	j continue
	
	generate_powerup2:	
	li $v0, 42
	li $a0, 0
	li $a1, 4
	syscall
	beq $a0, 0, set1a
	beq $a0, 1, set2a
	beq $a0, 2, set3a
	beq $a0, 3, set4a
	
	j continue
	set1a:
	la $t0, powerup2
	addi $t1, $0, 1928
	beq $t1, $s1, generate_powerup2
	lw $t8, powerup1
	beq $t1, $t8, generate_powerup2
	sw $t1, 0($t0)
	j continue
	set2a:
	la $t0, powerup2
	addi $t1, $0, 1960
	beq $t1, $s1, generate_powerup2
	lw $t8, powerup1
	beq $t1, $t8, generate_powerup2
	sw $t1, 0($t0)
	j continue
	set3a:
	la $t0, powerup2
	addi $t1, $0, 1992
	beq $t1, $s1, generate_powerup2
	lw $t8, powerup1
	beq $t1, $t8, generate_powerup2
	sw $t1, 0($t0)
	j continue
	set4a:
	la $t0, powerup2
	addi $t1, $0, 2024
	beq $t1, $s1, generate_powerup2
	lw $t8, powerup1
	beq $t1, $t8, generate_powerup2
	sw $t1, 0($t0)
	j continue
	
	
	print:
	
	lw $t0, lives
	beq $t0, 2, print2
	beq $t0, 1, print1
	beq $t0, 0, print0

	print2:
	li $t1, RED
	lw $t3, display_address
	addi $t3, $t3, 104
	addi $t3, $t3, 128
	sw $t1, 4($t3)
	sw $t1, 8($t3)
	sw $t1, 12($t3)
	sw $t1, 140($t3)
	sw $t1, 268($t3)
	sw $t1, 264($t3)
	sw $t1, 260($t3)
	sw $t1, 388($t3)
	sw $t1, 516($t3)
	sw $t1, 520($t3)
	sw $t1, 524($t3)
	jr $ra

	
	print1:
	li $t1, RED
	lw $t3, display_address
	addi $t3, $t3, 104
	addi $t3, $t3, 128
	sw $t1, 8($t3)
	sw $t1, 136($t3)
	sw $t1, 264($t3)
	sw $t1, 392($t3)
	sw $t1, 520($t3)
	jr $ra
	print0:
	li $t1, RED
	lw $t3, display_address
	addi $t3, $t3, 104
	addi $t3, $t3, 128
	sw $t1, 4($t3)
	sw $t1, 8($t3)
	sw $t1, 12($t3)
	sw $t1, 140($t3)
	sw $t1, 268($t3)
	sw $t1, 396($t3)
	sw $t1, 524($t3)
	sw $t1, 520($t3)
	sw $t1, 516($t3)
	sw $t1, 388($t3)
	sw $t1, 260($t3)
	sw $t1, 132($t3)
	jr $ra
	
	
	
	bonus_life:
	la $t9, powerup1
	lw $t0, 0($t9)
	lw $t3, display_address
	add $t0, $t3, $t0
	li $t1, PINK
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, -4($t0)
	sw $t1, 128($t0)
	sw $t1, -128($t0)
	jr $ra
	
	invisibility:
	la $t9, powerup2
	lw $t0, 0($t9)
	lw $t3, display_address
	add $t0, $t3, $t0
	li $t1, ORANGE
	sw $t1, 4($t0)
	sw $t1, -4($t0)
	sw $t1, 128($t0)
	sw $t1, -128($t0)
	sw $t1, 124($t0)
	sw $t1, -124($t0)
	sw $t1, 132($t0)
	sw $t1, -132($t0)
	jr $ra
	
	get_constant:
	la $t0, constants
	
	
	move_car_down1:
	mul $t3, $s2, 128
	add $s4, $s4, $t3
	bge $s4, 3464, reset_enemy_car1
	jr $ra
	
	reset_enemy_car1:
	li $v0, 42
	li $a0, 0
	li $a1, 4
	syscall
	
	move $t1, $a0
	la $t0, constants
	mul $t4, $t1, 4
	add $t3, $t0, $t4
	lw $t5, 0($t3)
	sub $t5, $0, $t5
	add $s4, $s4, $t5
	jr $ra
	
	move_car_down2:
	mul $t3, $s2, 128
	add $s5, $s5, $t3
	bge $s5, 3496, reset_enemy_car2
	jr $ra
	
	reset_enemy_car2:
	li $v0, 42
	li $a0, 0
	li $a1, 4
	syscall
	
	move $t1, $a0
	la $t0, constants
	mul $t4, $t1, 4
	add $t3, $t0, $t4
	lw $t5, 0($t3)
	sub $t5, $0, $t5
	add $s5, $s5, $t5
	jr $ra

	move_car_up1:
	mul $t3, $s3, 128
	add $s6, $s6, $t3
	bge $s6, 3496, reset_enemy_car3
	jr $ra
	
	reset_enemy_car3:

	li $v0, 42
	li $a0, 0
	li $a1, 4
	syscall
	
	move $t1, $a0
	la $t0, constants
	mul $t4, $t1, 4
	add $t3, $t0, $t4
	lw $t5, 0($t3)
	sub $t5, $0, $t5
	add $s6, $s6, $t5
	jr $ra

	move_car_up2:
	mul $t3, $s3, 128
	add $s7, $s7, $t3
	bge $s7, 3496, reset_enemy_car4
	jr $ra
	
	reset_enemy_car4:

	li $v0, 42
	li $a0, 0
	li $a1, 4
	syscall
	
	move $t1, $a0
	la $t0, constants
	mul $t4, $t1, 4
	add $t3, $t0, $t4
	lw $t5, 0($t3)
	sub $t5, $0, $t5
	add $s7, $s7, $t5
	jr $ra

	enemy_collision:
	lw $t1, 0($sp)
	addi $sp, $sp, 4
	lw $t0, display_address
	add $t5, $t0, $t1
	li $t8, BLACK
	li $t9, RED
	li $t1, PURPLE
	addi $t7, $zero, 1

	

	lw $t4, 0($t5)
	beq $t4, $t1, collid
	lw $t4, 4($t5)
	beq $t4, $t1, collid
	lw $t4, 8($t5)
	beq $t4, $t1, collid
	lw $t4, 12($t5)
	beq $t4, $t1, collid
	lw $t4, 16($t5)
	beq $t4, $t1, collid
	addi $t5, $t5, 128
	lw $t4, 0($t5)
	beq $t4, $t1, collid
	lw $t4, 4($t5)
	beq $t4, $t1, collid
	lw $t4, 8($t5)
	beq $t4, $t1, collid
	lw $t4, 12($t5)
	beq $t4, $t1, collid
	lw $t4, 16($t5)
	beq $t4, $t1, collid
	addi $t5, $t5, 128
	lw $t4, 0($t5)
	beq $t4, $t1, collid
	lw $t4, 4($t5)
	beq $t4, $t1, collid
	lw $t4, 8($t5)
	beq $t4, $t1, collid
	lw $t4, 12($t5)
	beq $t4, $t1, collid
	lw $t4, 16($t5)
	beq $t4, $t1, collid
	addi $t5, $t5, 128
	lw $t4, 0($t5)
	beq $t4, $t1, collid
	lw $t4, 4($t5)
	beq $t4, $t1, collid
	lw $t4, 8($t5)
	beq $t4, $t1, collid
	lw $t4, 12($t5)
	beq $t4, $t1, collid
	lw $t4, 16($t5)
	beq $t4, $t1, collid
	addi $t5, $t5, 128
	lw $t4, 0($t5)
	beq $t4, $t1, collid
	lw $t4, 4($t5)
	beq $t4, $t1, collid
	lw $t4, 8($t5)
	beq $t4, $t1, collid
	lw $t4, 12($t5)
	beq $t4, $t1, collid
	lw $t4, 16($t5)
	beq $t4, $t1, collid
	

	jr $ra
	
	collid:
	j collision_happened



	game_over_screen:
	lw $t0, display_address
	lw $t3, display_address
	li $t2, 0
	li $t1, RED
	j draw_background1
	
	draw_background1:
	beq $t2, 16384, end_game_over
    	sw $t1, 0($t3)
    	addi $t2, $t2, 4
    	add $t3, $t0, $t2
    	j draw_background1
    	
    	end_game_over:
	jr $ra
	
	
	game_finished_screen:
	lw $t0, display_address
	lw $t3, display_address
	li $t2, 0
	li $t1, GREEN
	j draw_background2
	
	draw_background2:
	beq $t2, 16384, end_game_finished
    	sw $t1, 0($t3)
    	addi $t2, $t2, 4
    	add $t3, $t0, $t2
    	j draw_background2
    	
    	end_game_finished:
	jr $ra
	
	white_screen:
	lw $t0, display_address
	lw $t3, display_address
	li $t2, 0
	li $t1, WHITE
	j draw_background3
	
	draw_background3:
	beq $t2, 16384, white_screen_end
    	sw $t1, 0($t3)
    	addi $t2, $t2, 4
    	add $t3, $t0, $t2
    	j draw_background2
    	
    	white_screen_end:
	jr $ra

	#New Car position (1928, 1960, 1992, 2024)
	move_1928:
	addi $s1, $0, 1928
	jr $ra
	move_1960:
	addi $s1, $0, 1960
	jr $ra
	move_1992:
	addi $s1, $0, 1992
	jr $ra
	move_2024:
	addi $s1, $0, 2024
	jr $ra
	
	return:
	jr $ra
	
	speed1:
	addi $s2, $0, 1
	addi $s3, $0, 0
	jr $ra
	speed2:
	addi $s2, $0, 2
	addi $s3, $0, 1
	jr $ra
	speed3:
	addi $s2, $0, 3
	addi $s3, $0, 2
	jr $ra

	take_input:
	li $t9, 0xffff0000
	lw $t8, 0($t9)
	beq $t8,1,keypress

	jr $ra
		keypress:
		lw $t2,4($t9)
		beq $t2, KEY_W, press_w
		beq $t2, KEY_A, press_a
		beq $t2, KEY_S, press_s
		beq $t2, KEY_D, press_d
		beq $t2, KEY_Q, press_q

		jr $ra
		press_w:
		beq $s2, 3, return
		beq $s2, 2, speed3
		beq $s2, 1, speed2
		
		jr $ra
		press_a:
		#New Car position (1928, 1960, 1992, 2024)
		beq $s1, 1928, collision_happened
		beq $s1, 1960, move_1928
		beq $s1, 1992, move_1960
		beq $s1, 2024, move_1992
		jr $ra
		press_s:
		beq $s2, 1, return
		beq $s2, 3, speed2
		beq $s2, 2, speed1
		jr $ra
		press_d:
		beq $s1, 1928, move_1960
		beq $s1, 1960, move_1992
		beq $s1, 1992, move_2024
		beq $s1, 2024, collision_happened
		jr $ra
		press_q:
		j game_over
		

	
	spawn_car:
	move $t1, $s1
	lw $t0, display_address
	add $t5, $t0, $t1
	li $t4, GREEN
	li $t9, PURPLE
	li $t8, RED



	sw $t8, 0($t5)
	sw $t4, 4($t5)
	sw $t4, 8($t5)
	sw $t4, 12($t5)
	sw $t8, 16($t5)
	addi $t5, $t5, 128

	sw $t9, 4($t5)
	sw $t9, 8($t5)
	sw $t9, 12($t5)

	addi $t5, $t5, 128

	sw $t9, 4($t5)
	sw $t9, 8($t5)
	sw $t9, 12($t5)

	addi $t5, $t5, 128	

	sw $t9, 4($t5)
	sw $t9, 8($t5)
	sw $t9, 12($t5)

	addi $t5, $t5, 128
	sw $t4, 0($t5)
	sw $t9, 4($t5)
	sw $t9, 8($t5)
	sw $t9, 12($t5)
	sw $t4, 16($t5)




		
	jr $ra
	
	powerup_activated_collision:
	move $t1, $s1
	lw $t0, display_address
	add $t5, $t0, $t1
	li $t2, PINK
	li $t1, ORANGE
	addi $t7, $zero, 1

	

	lw $t4, 0($t5)
	beq $t4, $t1, activated
	beq $t4, $t2, activated1
	lw $t4, 4($t5)
	beq $t4, $t1, activated
	beq $t4, $t2, activated1
	lw $t4, 8($t5)
	beq $t4, $t1, activated
	beq $t4, $t2, activated1
	lw $t4, 12($t5)
	beq $t4, $t1, activated
	beq $t4, $t2, activated1
	lw $t4, 16($t5)
	beq $t4, $t1, activated
	beq $t4, $t2, activated1
	addi $t5, $t5, 128
	lw $t4, 0($t5)
	beq $t4, $t1, activated
	beq $t4, $t2, activated1
	lw $t4, 4($t5)
	beq $t4, $t1, activated
	beq $t4, $t2, activated1
	lw $t4, 8($t5)
	beq $t4, $t1, activated
	beq $t4, $t2, activated1
	lw $t4, 12($t5)
	beq $t4, $t1, activated
	beq $t4, $t2, activated1
	lw $t4, 16($t5)
	beq $t4, $t1, activated
	beq $t4, $t2, activated1
	addi $t5, $t5, 128
	lw $t4, 0($t5)
	beq $t4, $t1, activated
	beq $t4, $t2, activated1
	lw $t4, 4($t5)
	beq $t4, $t1, activated
	beq $t4, $t2, activated1
	lw $t4, 8($t5)
	beq $t4, $t1, activated
	beq $t4, $t2, activated1
	lw $t4, 12($t5)
	beq $t4, $t1, activated
	beq $t4, $t2, activated1
	lw $t4, 16($t5)
	beq $t4, $t1, activated
	beq $t4, $t2, activated1
	addi $t5, $t5, 128
	lw $t4, 0($t5)
	beq $t4, $t1, activated
	beq $t4, $t2, activated1
	lw $t4, 4($t5)
	beq $t4, $t1, activated
	beq $t4, $t2, activated1
	lw $t4, 8($t5)
	beq $t4, $t1, activated
	beq $t4, $t2, activated1
	lw $t4, 12($t5)
	beq $t4, $t1, activated
	beq $t4, $t2, activated1
	lw $t4, 16($t5)
	beq $t4, $t1, activated
	beq $t4, $t2, activated1
	addi $t5, $t5, 128
	lw $t4, 0($t5)
	beq $t4, $t1, activated
	beq $t4, $t2, activated1
	lw $t4, 4($t5)
	beq $t4, $t1, activated
	beq $t4, $t2, activated1
	lw $t4, 8($t5)
	beq $t4, $t1, activated
	beq $t4, $t2, activated1
	lw $t4, 12($t5)
	beq $t4, $t1, activated
	beq $t4, $t2, activated1
	lw $t4, 16($t5)
	beq $t4, $t1, activated
	beq $t4, $t2, activated1
	addi $t5, $t5, 128
	lw $t4, 0($t5)
	beq $t4, $t1, activated
	beq $t4, $t2, activated1
	lw $t4, 4($t5)
	beq $t4, $t1, activated
	beq $t4, $t2, activated1
	lw $t4, 8($t5)
	beq $t4, $t1, activated
	beq $t4, $t2, activated1
	lw $t4, 12($t5)
	beq $t4, $t1, activated
	beq $t4, $t2, activated1
	lw $t4, 16($t5)
	beq $t4, $t1, activated
	beq $t4, $t2, activated1
	addi $t5, $t5, 128
	lw $t4, 0($t5)
	beq $t4, $t1, activated
	beq $t4, $t2, activated1
	lw $t4, 4($t5)
	beq $t4, $t1, activated
	beq $t4, $t2, activated1
	lw $t4, 8($t5)
	beq $t4, $t1, activated
	beq $t4, $t2, activated1
	lw $t4, 12($t5)
	beq $t4, $t1, activated
	beq $t4, $t2, activated1
	lw $t4, 16($t5)
	beq $t4, $t1, activated
	beq $t4, $t2, activated1


	jr $ra

	activated1:
	la $t0, powerupActivated
	la $t1, powerup1
	addi $t9, $0, -248
	sw $t9, 0($t1)
	
	la $t3, lives
	lw $t4, 0($t3)
	addi $t4, $0, 2
	sw $t4, 0($t3)		#Powerup (1) (Blue)
	jr $ra

	activated:
	la $t0, powerupActivated
	la $t1, powerup2
	addi $t9, $0, -248
	sw $t9, 0($t1)
	
	addi $t7, $0, 2
	sw $t7, 0($t0)			#Powerup (2) (Orange)
	jr $ra
	
	spawn_enemy_car1:
	lw $t1, 0($sp)
	addi $sp, $sp, 4
	lw $t0, display_address
	add $t5, $t0, $t1
	li $t8, WHITE
	li $t9, BLUE
	li $t1, RED
	li $t2, BLACK

	sw $t2, 0($t5)
	sw $t2, 4($t5)
	sw $t2, 8($t5)
	sw $t2, 12($t5)
	sw $t2, 16($t5)
	addi $t5, $t5, 128
	sw $t8, 0($t5)
	sw $t8, 4($t5)
	sw $t8, 8($t5)
	sw $t8, 12($t5)
	sw $t8, 16($t5)
	addi $t5, $t5, 128	
	sw $t8, 0($t5)
	sw $t1, 4($t5)
	sw $t8, 8($t5)
	sw $t9, 12($t5)
	sw $t8, 16($t5)
	addi $t5, $t5, 128
	sw $t8, 0($t5)
	sw $t8, 4($t5)
	sw $t8, 8($t5)
	sw $t8, 12($t5)
	sw $t8, 16($t5)
	addi $t5, $t5, 128
	sw $t9, 0($t5)
	sw $t2, 4($t5)
	sw $t2, 8($t5)
	sw $t2, 12($t5)
	sw $t9, 16($t5)
	
	jr $ra

	spawn_enemy_car2:
	lw $t1, 0($sp)
	addi $sp, $sp, 4
	lw $t0, display_address
	add $t5, $t0, $t1
	li $t8, WHITE
	li $t9, BLUE
	li $t1, RED
	li $t2, BLACK

	sw $t9, 0($t5)
	sw $t2, 4($t5)
	sw $t2, 8($t5)
	sw $t2, 12($t5)
	sw $t9, 16($t5)
	addi $t5, $t5, 128
	sw $t8, 0($t5)
	sw $t8, 4($t5)
	sw $t8, 8($t5)
	sw $t8, 12($t5)
	sw $t8, 16($t5)
	addi $t5, $t5, 128	
	sw $t8, 0($t5)
	sw $t1, 4($t5)
	sw $t8, 8($t5)
	sw $t9, 12($t5)
	sw $t8, 16($t5)
	addi $t5, $t5, 128
	sw $t8, 0($t5)
	sw $t8, 4($t5)
	sw $t8, 8($t5)
	sw $t8, 12($t5)
	sw $t8, 16($t5)
	addi $t5, $t5, 128
	sw $t2, 0($t5)
	sw $t2, 4($t5)
	sw $t2, 8($t5)
	sw $t2, 12($t5)
	sw $t2, 16($t5)
	
	jr $ra

    	color:
	lw $t0, display_address
	lw $t3, display_address
	li $t2, 0
	li $t1, GRAY
	li $t4, YELLOW
	li $t9, WHITE
	j draw_background
	
	draw_background:
	
	bge $t2, 16384, finish
    	sw $t1, 0($t3)
        sw $t1, 4($t3)
        sw $t1, 8($t3)
        sw $t1, 12($t3)
    	sw $t1, 16($t3)
        sw $t1, 20($t3)
        sw $t1, 24($t3)
        sw $t1, 28($t3)
    	sw $t9, 32($t3)
        sw $t1, 36($t3)
        sw $t1, 40($t3)
        sw $t1, 44($t3)
    	sw $t1, 48($t3)
        sw $t1, 52($t3)
        sw $t1, 56($t3)
        sw $t1, 60($t3)
    	sw $t4, 64($t3)
        sw $t1, 68($t3)
        sw $t1, 72($t3)
        sw $t1, 76($t3)
    	sw $t1, 80($t3)
        sw $t1, 84($t3)
        sw $t1, 88($t3)
        sw $t1, 92($t3)
    	sw $t9, 96($t3)
        sw $t1, 100($t3)
        sw $t1, 104($t3)
        sw $t1, 108($t3)
    	sw $t1, 112($t3)
        sw $t1, 116($t3)
        sw $t1, 120($t3)
        sw $t1, 124($t3)
    	addi $t2, $t2, 128
    	add $t3, $t0, $t2
    	sw $t1, 0($t3)
        sw $t1, 4($t3)
        sw $t1, 8($t3)
        sw $t1, 12($t3)
    	sw $t1, 16($t3)
        sw $t1, 20($t3)
        sw $t1, 24($t3)
        sw $t1, 28($t3)
    	sw $t9, 32($t3)
        sw $t1, 36($t3)
        sw $t1, 40($t3)
        sw $t1, 44($t3)
    	sw $t1, 48($t3)
        sw $t1, 52($t3)
        sw $t1, 56($t3)
        sw $t1, 60($t3)
    	sw $t4, 64($t3)
        sw $t1, 68($t3)
        sw $t1, 72($t3)
        sw $t1, 76($t3)
    	sw $t1, 80($t3)
        sw $t1, 84($t3)
        sw $t1, 88($t3)
        sw $t1, 92($t3)
    	sw $t9, 96($t3)
        sw $t1, 100($t3)
        sw $t1, 104($t3)
        sw $t1, 108($t3)
    	sw $t1, 112($t3)
        sw $t1, 116($t3)
        sw $t1, 120($t3)
        sw $t1, 124($t3)
    	addi $t2, $t2, 128
    	add $t3, $t0, $t2
    	sw $t1, 0($t3)
        sw $t1, 4($t3)
        sw $t1, 8($t3)
        sw $t1, 12($t3)
    	sw $t1, 16($t3)
        sw $t1, 20($t3)
        sw $t1, 24($t3)
        sw $t1, 28($t3)
    	sw $t9, 32($t3)
        sw $t1, 36($t3)
        sw $t1, 40($t3)
        sw $t1, 44($t3)
    	sw $t1, 48($t3)
        sw $t1, 52($t3)
        sw $t1, 56($t3)
        sw $t1, 60($t3)
    	sw $t4, 64($t3)
        sw $t1, 68($t3)
        sw $t1, 72($t3)
        sw $t1, 76($t3)
    	sw $t1, 80($t3)
        sw $t1, 84($t3)
        sw $t1, 88($t3)
        sw $t1, 92($t3)
    	sw $t9, 96($t3)
        sw $t1, 100($t3)
        sw $t1, 104($t3)
        sw $t1, 108($t3)
    	sw $t1, 112($t3)
        sw $t1, 116($t3)
        sw $t1, 120($t3)
        sw $t1, 124($t3)
    	addi $t2, $t2, 128
    	add $t3, $t0, $t2
    	sw $t1, 0($t3)
        sw $t1, 4($t3)
        sw $t1, 8($t3)
        sw $t1, 12($t3)
    	sw $t1, 16($t3)
        sw $t1, 20($t3)
        sw $t1, 24($t3)
        sw $t1, 28($t3)
    	sw $t9, 32($t3)
        sw $t1, 36($t3)
        sw $t1, 40($t3)
        sw $t1, 44($t3)
    	sw $t1, 48($t3)
        sw $t1, 52($t3)
        sw $t1, 56($t3)
        sw $t1, 60($t3)
    	sw $t4, 64($t3)
        sw $t1, 68($t3)
        sw $t1, 72($t3)
        sw $t1, 76($t3)
    	sw $t1, 80($t3)
        sw $t1, 84($t3)
        sw $t1, 88($t3)
        sw $t1, 92($t3)
    	sw $t9, 96($t3)
        sw $t1, 100($t3)
        sw $t1, 104($t3)
        sw $t1, 108($t3)
    	sw $t1, 112($t3)
        sw $t1, 116($t3)
        sw $t1, 120($t3)
        sw $t1, 124($t3)
    	addi $t2, $t2, 128
    	add $t3, $t0, $t2
    	sw $t1, 0($t3)
        sw $t1, 4($t3)
        sw $t1, 8($t3)
        sw $t1, 12($t3)
    	sw $t1, 16($t3)
        sw $t1, 20($t3)
        sw $t1, 24($t3)
        sw $t1, 28($t3)
    	sw $t1, 32($t3)
        sw $t1, 36($t3)
        sw $t1, 40($t3)
        sw $t1, 44($t3)
    	sw $t1, 48($t3)
        sw $t1, 52($t3)
        sw $t1, 56($t3)
        sw $t1, 60($t3)
    	sw $t4, 64($t3)
        sw $t1, 68($t3)
        sw $t1, 72($t3)
        sw $t1, 76($t3)
    	sw $t1, 80($t3)
        sw $t1, 84($t3)
        sw $t1, 88($t3)
        sw $t1, 92($t3)
    	sw $t1, 96($t3)
        sw $t1, 100($t3)
        sw $t1, 104($t3)
        sw $t1, 108($t3)
    	sw $t1, 112($t3)
        sw $t1, 116($t3)
        sw $t1, 120($t3)
        sw $t1, 124($t3)
    	addi $t2, $t2, 128
    	add $t3, $t0, $t2
    	
    	j draw_background
    	
    	finish:
        jr $ra

  write_G:
            sw $t1, 0($t0)
            sw $t1, 4($t0)
            sw $t1, 8($t0)
            sw $t1, 12($t0)
            sw $t1, 16($t0)
            addi $t0, $t0, 128
            sw $t1, 0($t0)
            addi $t0, $t0, 128
            sw $t1, 0($t0)
            addi $t0, $t0, 128
            sw $t1, 0($t0)
            sw $t1, 16($t0)
            addi $t0, $t0, 128
            sw $t1, 0($t0)
            sw $t1, 16($t0)
            addi $t0, $t0, 128
            sw $t1, 0($t0)
            sw $t1, 4($t0)
            sw $t1, 8($t0)
            sw $t1, 12($t0)
            sw $t1, 16($t0)

            jr $ra

        write_A:
            sw $t1, 0($t0)
            sw $t1, 4($t0)
            sw $t1, 8($t0)
            sw $t1, 12($t0)
            sw $t1, 16($t0)
            addi $t0, $t0, 128
            sw $t1, 0($t0)
            sw $t1, 16($t0)
            addi $t0, $t0, 128
            sw $t1, 0($t0)
            sw $t1, 16($t0)
            addi $t0, $t0, 128
            sw $t1, 0($t0)
            sw $t1, 4($t0)
            sw $t1, 8($t0)
            sw $t1, 12($t0)
            sw $t1, 16($t0)
            addi $t0, $t0, 128
            sw $t1, 0($t0)
            sw $t1, 16($t0)
            addi $t0, $t0, 128
            sw $t1, 0($t0)
            sw $t1, 16($t0)

            jr $ra

        write_M:
            sw $t1, 0($t0)
            sw $t1, 16($t0)
            addi $t0, $t0, 128
            sw $t1, 0($t0)
            sw $t1, 4($t0)
            sw $t1, 12($t0)
            sw $t1, 16($t0)
            addi $t0, $t0, 128
            sw $t1, 0($t0)
            sw $t1, 8($t0)
            sw $t1, 16($t0)
            addi $t0, $t0, 128
            sw $t1, 0($t0)
            sw $t1, 16($t0)
            addi $t0, $t0, 128
            sw $t1, 0($t0)
            sw $t1, 16($t0)
            addi $t0, $t0, 128
            sw $t1, 0($t0)
            sw $t1, 16($t0)

            jr $ra
        write_E:
            sw $t1, 0($t0)
            sw $t1, 4($t0)
            sw $t1, 8($t0)
            sw $t1, 12($t0)
            sw $t1, 16($t0)
            addi $t0, $t0, 128
            sw $t1, 0($t0)
            addi $t0, $t0, 128
            sw $t1, 0($t0)
            addi $t0, $t0, 128
            sw $t1, 0($t0)
            sw $t1, 4($t0)
            sw $t1, 8($t0)
            sw $t1, 12($t0)
            addi $t0, $t0, 128
            sw $t1, 0($t0)
            addi $t0, $t0, 128
            sw $t1, 0($t0)
            sw $t1, 4($t0)
            sw $t1, 8($t0)
            sw $t1, 12($t0)
            sw $t1, 16($t0)

            jr $ra

        write_R1:
            sw $t1, 0($t0)
            sw $t1, 4($t0)
            sw $t1, 8($t0)
            sw $t1, 12($t0)
            sw $t1, 16($t0)
            addi $t0, $t0, 128
            sw $t1, 0($t0)
            sw $t1, 16($t0)
            addi $t0, $t0, 128
            sw $t1, 0($t0)
            sw $t1, 4($t0)
            sw $t1, 8($t0)
            sw $t1, 12($t0)
            sw $t1, 16($t0)
            addi $t0, $t0, 128
            sw $t1, 0($t0)
            sw $t1, 4($t0)
            sw $t1, 8($t0)
            addi $t0, $t0, 128
            sw $t1, 0($t0)
            sw $t1, 12($t0)
            addi $t0, $t0, 128
            sw $t1, 0($t0)
            sw $t1, 16($t0)
            jr $ra

        write_V:
            sw $t1, 0($t0)
            sw $t1, 16($t0)
            addi $t0, $t0, 128
            sw $t1, 0($t0)
            sw $t1, 16($t0)
            addi $t0, $t0, 128
            sw $t1, 0($t0)
            sw $t1, 16($t0)
            addi $t0, $t0, 128
            sw $t1, 0($t0)
            sw $t1, 16($t0)
            addi $t0, $t0, 128
            sw $t1, 0($t0)
            sw $t1, 16($t0)
            addi $t0, $t0, 128
            sw $t1, 4($t0)
            sw $t1, 8($t0)
            sw $t1, 12($t0)
            jr $ra


        write_O:
            sw $t1, 0($t0)
            sw $t1, 4($t0)
            sw $t1, 8($t0)
            sw $t1, 12($t0)
            addi $t0, $t0, 128
            sw $t1, 0($t0)
            sw $t1, 12($t0)
            addi $t0, $t0, 128
            sw $t1, 0($t0)
            sw $t1, 12($t0)
            addi $t0, $t0, 128
            sw $t1, 0($t0)
            sw $t1, 12($t0)
            addi $t0, $t0, 128
            sw $t1, 0($t0)
            sw $t1, 12($t0)
            addi $t0, $t0, 128
            sw $t1, 0($t0)
            sw $t1, 4($t0)
            sw $t1, 8($t0)
            sw $t1, 12($t0)
            jr $ra


        write_R:
            sw $t1, 0($t0)
            sw $t1, 4($t0)
            sw $t1, 8($t0)
            sw $t1, 12($t0)
            sw $t1, 16($t0)
            addi $t0, $t0, 128
            sw $t1, 0($t0)
            sw $t1, 16($t0)
            addi $t0, $t0, 128
            sw $t1, 0($t0)
            sw $t1, 16($t0)
            addi $t0, $t0, 128
            sw $t1, 0($t0)
            sw $t1, 4($t0)
            sw $t1, 8($t0)
            sw $t1, 12($t0)
            sw $t1, 16($t0)
            addi $t0, $t0, 128
            sw $t1, 0($t0)
            sw $t1, 4($t0)
            sw $t1, 8($t0)
            addi $t0, $t0, 128
            sw $t1, 0($t0)
            sw $t1, 12($t0)
            addi $t0, $t0, 128
            sw $t1, 0($t0)
            sw $t1, 16($t0)
            

            jr $ra



	
	end:
	li $v0, 10
	syscall
