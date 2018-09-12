	;=================================
	; action_stars
	;=================================
	; and take 4504 cycles to do it

	; we take 4501, so waste 3
action_stars:

	jsr	draw_stars			; 6+4492 = 4498

	ldy	FRAME	;nop			; 3

	jmp	check_keyboard			; 3


	;=================================
	; action_launch_firework
	;=================================
	; and take 4504 cycles to do it

	; we take 419 so waste 4085
action_launch_firework:

	; Try X=203 Y=4 cycles=405

        ldy	#4							; 2
Xloop1:	ldx	#203							; 2
Xloop2:	dex								; 2
	bne	Xloop2							; 2nt/3
	dey								; 2
	bne	Xloop1							; 2nt/3

	jsr	launch_firework			; 6+410 = 416

	jmp	check_keyboard			; 3


	;=================================
	; action_move_rocket
	;=================================
	; and take 4504 cycles to do it

	; we take 1245 so waste 3259
action_move_rocket:

	; Try X=35 Y=18 cycles=3259

        ldy	#18							; 2
Yloop1:	ldx	#35							; 2
Yloop2:	dex								; 2
	bne	Yloop2							; 2nt/3
	dey								; 2
	bne	Yloop1							; 2nt/3

	jsr	move_rocket			; 6+1236 = 1242

	jmp	check_keyboard			; 3


	;=================================
	; action_start_explosion
	;=================================
	; and take 4504 cycles to do it

	; we take 445 so waste 4059
action_start_explosion:

	; Try X=30 Y=26 cycles=4057 R2

	nop

        ldy	#26							; 2
Zloop1:	ldx	#30							; 2
Zloop2:	dex								; 2
	bne	Zloop2							; 2nt/3
	dey								; 2
	bne	Zloop1							; 2nt/3

	jsr	start_explosion			; 6+436 = 442

	jmp	check_keyboard			; 3


	;=================================
	; action_continue_explosion
	;=================================
	; and take 4504 cycles to do it

	; we take 4495 so waste 9
action_continue_explosion:
	lda	STATE
	lda	STATE
	lda	STATE

	jsr	continue_explosion			; 6+4486 = 4492

	jmp	check_keyboard				; 3


