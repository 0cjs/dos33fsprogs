; Parallax Sierpinski/xor boxes HGR

; by deater (Vince Weaver) <vince@deater.net>

; Already heavily optimized:

; only 128 lines
;	frame 0: 27c78	= 162,936 cycles  = roughly 6.1 fps
; full 192 lines
;	frame 0: 3bf5f	= 245,599 cycles  = roughly 4 fps

;hgr_lookup_h    =       $1000
;hgr_lookup_l    =       $1100
;div4_lookup	=	$90

sier_parallax:

.if 0
	;===================
	; init screen

; already done for us

;	jsr	HGR			; clear PAGE1
;	jsr	HGR2			; clear PAGE2

	;===================
        ; int tables

        ldx     #191
sinit_loop:
        txa
        pha
        jsr     HPOSN
        pla
        tax
        lda     GBASL
        sta     hgr_lookup_l,X
        lda     GBASH
	and	#$1F				; 20 30    001X 40 50  010X
        sta     hgr_lookup_h,X


        dex
        cpx     #$ff
        bne     sinit_loop

	ldx	#39
div4_loop:
	txa
	asl
	asl
	sta	div4_lookup,X
	dex
	bpl	div4_loop

.endif

parallax_forever:

	; increment offsets

	inc	large_smc+1						; 6
	inc	medium_smc+1						; 6

	;========================
	; flip page

	lda	HGR_PAGE                ; $40 or $20

	eor	#$60                    ; flip draw_page
	sta	HGR_PAGE

	asl
	asl
	rol
	eor	#$1
	tax
	lda     PAGE1,X			; flip show_page


	ldy	#159			; init Y

yloop:

	;==============
	; point output to current line

	lda     hgr_lookup_l,Y						; 4+
        sta     out_smc+1						; 4
        lda     hgr_lookup_h,Y						; 4+
	ora	HGR_PAGE						; 3
        sta     out_smc+2						; 4

	;==============
	; current column (work backwards)

	ldx	#39							; 2
xloop:

	;===========================
	; Boxes

	tya								; 2

	; carry always clear here?
large_smc:
	sbc	#$DD							; 2
	eor	div4_lookup,X						; 4
	and	#$40							; 2

	bne	draw_white						; 2/3

	; 0 means transparent

skip_color_large:

	;===========================
	; Sierpinski

	tya								; 2
medium_smc:
	adc	#$DD			; go other way			; 2
	and	div4_lookup,X		; sierpinski			; 4


	bne	draw_black		; draw black			; 2/3
draw_purple:
	lda	#$55			; purple/green			; 2
	bne	draw_color		; bra				; 3
draw_black:
	lda	#$00							; 2
	beq	draw_color		; bra				; 3

	; white block
draw_white:
	lda	#$7f							; 2

	;========================
	; actually draw color

draw_color:
out_smc:
	sta	$2000,X							; 5

	dex								; 2
	bpl	xloop							; 2/3

	dey								; 2
	cpy	#32							; 2
	bne	yloop							; 2/3

	; stop after 512 frames

	lda	FRAMEH
	cmp	#2

	bne	parallax_forever		; bra			; 3
