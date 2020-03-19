	;=============================
	; meche_link_book
	;=============================
meche_link_book:

	; clear screen
	lda	#0
	sta	clear_all_color+1

	jsr	clear_all
	jsr	page_flip

	jsr	clear_all
	jsr	page_flip

	;====================================
	; load linking audio (12k) to $9000

	lda	#<linking_filename
	sta	OUTL
	lda	#>linking_filename
	sta	OUTH

        jsr	opendir_filename


	; play sound effect?

	lda	#<linking_noise
	sta	BTC_L
	lda	#>linking_noise
	sta	BTC_H
	ldx	#LINKING_NOISE_LENGTH		; 45 pages long???
	jsr	play_audio

	lda	#3
	sta	LOCATION
	lda	#DIRECTION_W
	sta	DIRECTION

	jsr	change_location
	rts


meche_movie:
	.word meche_sprite0,meche_sprite1,meche_sprite2
	.word meche_sprite3,meche_sprite4,meche_sprite5
	.word meche_sprite6,meche_sprite7,meche_sprite8
	.word meche_sprite9,meche_sprite10

meche_sprite0:
	.byte 9,6
	.byte $77,$77,$77,$77,$77,$77,$55,$77,$77
	.byte $77,$77,$77,$77,$77,$47,$49,$49,$47
	.byte $57,$77,$77,$77,$77,$ff,$55,$88,$88
	.byte $05,$67,$00,$60,$60,$00,$67,$86,$60
	.byte $00,$00,$06,$06,$68,$66,$66,$68,$66
	.byte $00,$00,$00,$00,$00,$06,$66,$66,$66

meche_sprite1:
	.byte 9,6
	.byte $77,$77,$77,$47,$45,$45,$45,$74,$77
	.byte $77,$77,$74,$ff,$8f,$ff,$ff,$77,$77
	.byte $07,$07,$07,$ff,$08,$0f,$0f,$07,$07
	.byte $77,$77,$00,$67,$67,$60,$66,$66,$66
	.byte $66,$66,$86,$66,$66,$88,$66,$66,$66
	.byte $88,$66,$68,$66,$66,$66,$66,$66,$66

meche_sprite2:
	.byte 9,6
	.byte $77,$47,$45,$45,$47,$47,$77,$77,$77
	.byte $74,$ff,$8f,$5f,$55,$77,$77,$77,$77
	.byte $70,$0f,$08,$f5,$08,$77,$77,$67,$67
	.byte $77,$77,$00,$67,$67,$66,$66,$66,$66
	.byte $77,$66,$66,$66,$66,$88,$66,$66,$66
	.byte $66,$66,$66,$66,$66,$88,$66,$66,$66

meche_sprite3:
	.byte 9,6
	.byte $55,$55,$55,$57,$77,$77,$77,$77,$77
	.byte $f5,$ff,$5f,$5f,$77,$77,$77,$77,$77
	.byte $88,$0f,$05,$f5,$77,$77,$77,$57,$57
	.byte $08,$70,$00,$57,$57,$55,$55,$65,$65
	.byte $57,$55,$55,$65,$65,$88,$66,$66,$66
	.byte $65,$66,$66,$66,$88,$88,$00,$66,$66

meche_sprite4:
	.byte 9,6
	.byte $00,$70,$77,$77,$77,$77,$77,$77,$77
	.byte $00,$77,$77,$77,$77,$77,$77,$77,$dd
	.byte $00,$77,$77,$77,$77,$77,$77,$55,$dd
	.byte $57,$57,$57,$57,$57,$76,$57,$66,$6d
	.byte $66,$60,$66,$60,$66,$66,$88,$55,$55
	.byte $66,$66,$66,$66,$66,$66,$88,$66,$66

meche_sprite5:
	.byte 9,6
	.byte $77,$77,$77,$77,$77,$77,$77,$77,$77
	.byte $77,$77,$77,$77,$77,$d7,$dd,$dd,$77
	.byte $77,$77,$77,$55,$57,$dd,$dd,$dd,$d7
	.byte $77,$67,$67,$55,$67,$dd,$dd,$dd,$dd
	.byte $66,$66,$66,$65,$66,$6d,$6d,$6d,$66
	.byte $56,$56,$56,$56,$56,$56,$66,$66,$66

meche_sprite6:
	.byte 9,6
	.byte $77,$77,$77,$77,$77,$77,$77,$77,$77
	.byte $77,$77,$77,$77,$d7,$77,$77,$77,$77
	.byte $77,$77,$77,$77,$dd,$dd,$77,$77,$77
	.byte $77,$77,$88,$dd,$dd,$dd,$67,$66,$66
	.byte $77,$67,$88,$dd,$dd,$dd,$66,$66,$66
	.byte $56,$65,$88,$dd,$dd,$dd,$66,$66,$66

meche_sprite7:
	.byte 9,6
	.byte $77,$77,$77,$77,$77,$87,$87,$88,$78
	.byte $77,$77,$77,$77,$88,$d8,$77,$77,$77
	.byte $77,$77,$77,$77,$88,$dd,$77,$88,$87
	.byte $77,$77,$77,$67,$88,$dd,$dd,$88,$88
	.byte $67,$67,$66,$66,$88,$dd,$dd,$dd,$dd
	.byte $66,$62,$22,$22,$88,$dd,$dd,$dd,$dd

meche_sprite8:
	.byte 9,6
	.byte $77,$77,$77,$77,$77,$77,$77,$77,$87
	.byte $77,$77,$77,$77,$77,$88,$77,$88,$77
	.byte $77,$77,$77,$77,$87,$88,$87,$88,$87
	.byte $77,$77,$77,$77,$88,$88,$88,$88,$88
	.byte $67,$67,$26,$26,$88,$88,$88,$88,$88
	.byte $62,$62,$62,$62,$68,$88,$88,$88,$88

meche_sprite9:
	.byte 9,6
	.byte $77,$77,$77,$77,$77,$77,$88,$88,$88
	.byte $77,$77,$77,$77,$77,$88,$88,$88,$88
	.byte $77,$77,$77,$77,$87,$88,$88,$88,$88
	.byte $77,$77,$77,$87,$88,$88,$88,$88,$88
	.byte $26,$26,$26,$88,$88,$88,$88,$88,$88
	.byte $62,$62,$62,$88,$88,$88,$88,$88,$88

meche_sprite10:
	.byte 9,6
	.byte $77,$77,$77,$77,$77,$77,$77,$47,$77
	.byte $77,$77,$77,$77,$77,$74,$f4,$f4,$88
	.byte $77,$77,$77,$77,$57,$57,$ff,$ff,$88
	.byte $77,$77,$55,$55,$77,$77,$77,$87,$88
	.byte $62,$62,$62,$62,$62,$62,$62,$88,$88
	.byte $66,$66,$66,$66,$66,$66,$66,$88,$88




linking_filename:
	.byte "LINK_NOISE.BTC",0
