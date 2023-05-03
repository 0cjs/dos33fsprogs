	;===========================================
	; hgr draw sprite mask and save (only at 7-bit boundaries)
	;===========================================
	; SPRITE in INL/INH
	; Location at CURSOR_X CURSOR_Y

	; xsize, ysize  in first two bytes

	; sprite AT INL/INH

hgr_draw_sprite_mask_and_save:

	ldy	#0
	lda	(INL),Y			; load xsize
	sta	backup_sprite
	clc
	adc	CURSOR_X
	sta	sms_sprite_width_end_smc+1	; self modify for end of line

	iny				; load ysize
	lda	(INL),Y
	sta	backup_sprite+1
	sta	sms_sprite_ysize_smc+1	; self modify

	; point smc to sprite
	lda	INL			; 16-bit add
	sta	sms_sprite_smc1+1
	lda	INH
	sta	sms_sprite_smc1+2

	lda	MASKL
	sta	sms_mask_smc1+1
	lda	MASKH
	sta	sms_mask_smc1+2

	ldx	#0			; X is pointer offset
	stx	CURRENT_ROW		; actual row

	ldx	#2

hgr_sms_sprite_yloop:

	lda	CURRENT_ROW		; row

	clc
	adc	CURSOR_Y		; add in cursor_y

	; calc GBASL/GBASH

	tay				; get output ROW into GBASL/H
	lda	hposn_low,Y
	sta	GBASL
;	sta	INL
	lda	hposn_high,Y

	; eor	#$00 draws on page2
	; eor	#$60 draws on page1
;hgr_sprite_page_smc:
;	eor	#$00
	sta	GBASH
;	eor	#$60
;	sta	INH

	ldy	CURSOR_X

sms_sprite_inner_loop:


	lda     (GBASL),Y			; load bg
	sta	backup_sprite,X
sms_sprite_smc1:
        eor     $f000,X			; load sprite data
sms_mask_smc1:
	and	$f000,X
	eor	(GBASL),Y
	sta	(GBASL),Y		; store to screen

	inx				; increment sprite offset
	iny				; increment output position


sms_sprite_width_end_smc:
	cpy	#6			; see if reached end of row
	bne	sms_sprite_inner_loop	; if not, loop


	inc	CURRENT_ROW		; row
	lda	CURRENT_ROW		; row

sms_sprite_ysize_smc:
	cmp	#31			; see if at end
	bne	hgr_sms_sprite_yloop	; if not, loop

	rts

backup_sprite = $1800
