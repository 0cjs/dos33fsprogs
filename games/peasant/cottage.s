; THATCHED ROOF COTTAGES

cottage:

	;************************
	; Cottage
	;************************

	lda	#<(cottage_lzsa)
	sta	getsrc_smc+1
	lda	#>(cottage_lzsa)
	sta	getsrc_smc+2

	lda	#$40

	jsr	decompress_lzsa2_fast

	lda	#<peasant_text
	sta	OUTL
	lda	#>peasant_text
	sta	OUTH

	jsr	hgr_put_string


	jsr	wait_until_keypress

	rts


peasant_text:
	.byte 25,2,"Peasant's Quest",0


cottage_text1:
	.byte 0,0,"YOU are Rather Dashing, a",0
	.byte 0,0,"humble peasant living in",0
	.byte 0,0,"the peasant kingdom of",0
	.byte 0,0,"Peasantry.",0

; wait a few seconds

cottage_text2:
	.byte 0,0,"You return home from a",0
	.byte 0,0,"vacation on Scalding Lake",0
	.byte 0,0,"only to find that TROGDOR",0
	.byte 0,0,"THE BURNINATOR has",0
	.byte 0,0,"burninated your thatched",0
	.byte 0,0,"roof cottage along with all",0
	.byte 0,0,"your goods and services.",0

; wait a few seconds, then start walking toward cottage

cottage_text3:
	.byte 0,0,"With nothing left to lose,",0
	.byte 0,0,"you swear to get revenge on",0
	.byte 0,0,"the Wingaling Dragon in the",0
	.byte 0,0,"name of burninated peasants",0
	.byte 0,0,"everywhere.",0

; Walk to edge of screen







