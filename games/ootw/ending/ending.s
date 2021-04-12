; ootw -- It's the End of the Game as We Know It

; TODO: missing a bunch of frames


; by Vince "Deater" Weaver	<vince@deater.net>

.include "../zp.inc"
.include "../hardware.inc"

ending:

	;=========================
	; set up sound
	;=========================
	lda	#0
	sta	DONE_PLAYING

	lda	#1
	sta	LOOP

	; detect mockingboard

	jsr	mockingboard_detect

	bcc	mockingboard_notfound

mockingboard_found:

;	jsr	mockingboard_patch	; patch to work in slots other than 4?

	;=======================
	; Set up 50Hz interrupt
	;========================

	jsr	mockingboard_init
	jsr	mockingboard_setup_interrupt

	;============================
	; Init the Mockingboard
	;============================

	jsr	reset_ay_both
	jsr	clear_ay_both

	;==================
	; init song
	;==================

	jsr	pt3_init_song


	jmp	done_setup_sound

mockingboard_notfound:
	; patch out cli/sei calls

	lda	#$EA
	sta	cli_smc
	sta	sei_smc

done_setup_sound:

repeat_ending:

	;===========================
	; Enable graphics
	;===========================

	bit	LORES
	bit	SET_GR
	bit	FULLGR
	bit	KEYRESET

	;=================================
	; Setup pages (is this necessary?)
	;=================================

;	lda	#0
;	sta	DRAW_PAGE
;	lda	#1
;	sta	DISP_PAGE



	;============
	; start music
	;============

cli_smc:
	cli	; enable interrupts

	;=====================================
	; friend arrive, board dragon sequence
	;=====================================

	lda	#<pickup_sequence
	sta	INTRO_LOOPL
	lda	#>pickup_sequence
	sta	INTRO_LOOPH

	jsr	run_sequence

	;=========================
	; wing open sequence
	;=========================

	lda	#<wing_sequence
	sta	INTRO_LOOPL
	lda	#>wing_sequence
	sta	INTRO_LOOPH

	jsr	run_sequence

	;=========================
	; flying sequence
	;=========================

	lda	#<flying_sequence
	sta	INTRO_LOOPL
	lda	#>flying_sequence
	sta	INTRO_LOOPH

	jsr	run_sequence

;===========================
; real end
;===========================

quit_level:
	jsr	TEXT
	jsr	HOME
	lda	KEYRESET		; clear strobe

	;======================
	; scroll credits
	;======================

	jsr	end_credits


	;======================
	; wait before rebooting
	;======================

	; wait wait wait

	jsr	wait_until_keypressed

	; disable music

	jsr	clear_ay_both
sei_smc:
	sei

	; reboot to title

	lda	#$ff			; force cold reboot
	sta	$03F4
	jmp	($FFFC)

;	jmp	repeat_ending



	;======================
	; wait until keypressed
	;======================
wait_until_keypressed:
	lda	KEYPRESS
	bpl	wait_until_keypressed
	bit	KEYRESET
	rts


	;	sequence:	0 = done
	;			255 reload $C00 with PTR
	;			0..127 wait TIME, then overlay $C00 with X
	;			128..254 wait TIME then overlay $C00 with next
	;	note: pauses *before* flipping to new graphic


	; dragon moves its head a bit when we arrive
	; repeats twice pulling self
	; then again but slightly to right
	; two more times
	; friend pops up, pauses a while

pickup_sequence:
	.byte   255						; load to bg
	.word	rooftop_bg_lzsa					; this
	.byte	128+20	;	.word	rooftop01_lzsa		; next
	.byte	128+20	;	.word	rooftop02_lzsa		; next
	.byte	128+20	;	.word	rooftop03_lzsa		; next
	.byte	128+20	;	.word	rooftop04_lzsa		; next
	.byte	128+20	;	.word	rooftop05_lzsa		; next
	.byte	128+20	;	.word	rooftop06_lzsa		; next
	.byte	128+20	;	.word	rooftop07_lzsa		; next
	.byte	128+20	;	.word	rooftop08_lzsa		; next
	.byte	128+20	;	.word	rooftop09_lzsa		; next
	.byte	128+20	;	.word	rooftop10_lzsa		; next
	.byte	128+20	;	.word	rooftop11_lzsa		; next
	.byte	128+20	;	.word	rooftop12_lzsa		; next
	.byte	128+20	;	.word	rooftop13_lzsa		; next
	.byte	128+20	;	.word	rooftop14_lzsa		; next
	.byte	128+20	;	.word	rooftop15_lzsa		; next
	.byte	128+20	;	.word	rooftop16_lzsa		; next
	.byte	128+20	;	.word	rooftop17_lzsa		; next
	.byte	128+20	;	.word	rooftop18_lzsa		; next
	.byte	128+20	;	.word	rooftop19_lzsa		; next
	.byte	128+20	;	.word	rooftop20_lzsa		; next
	.byte	128+20	;	.word	rooftop21_lzsa		; next
	.byte	128+20	;	.word	rooftop22_lzsa		; next
	.byte	128+20	;	.word	rooftop23_lzsa		; next
	.byte	128+20	;	.word	rooftop24_lzsa		; next
	.byte	128+20	;	.word	rooftop25_lzsa		; next
	.byte	128+20	;	.word	rooftop26_lzsa		; next
	.byte	128+20	;	.word	rooftop27_lzsa		; next
	.byte	128+20	;	.word	rooftop28_lzsa		; next
	.byte	128+20	;	.word	rooftop29_lzsa		; next
	.byte	0						; finish

wing_sequence:
	.byte   255						; load to bg
	.word	wing_bg_lzsa					;  this
	.byte	128+50	;	.word	left_unfurl1_lzsa	; next
	.byte	128+30	;	.word	left_unfurl2_lzsa	; next
	.byte	128+30	;	.word	left_unfurl3_lzsa	; next
	.byte	128+30	;	.word	left_unfurl4_lzsa	; next
	.byte	128+30	;	.word	left_unfurl5_lzsa	; next
	.byte	128+50	;	.word	right_unfurl1_lzsa	; next
	.byte	128+30	;	.word	right_unfurl2_lzsa	; next
	.byte	128+30	;	.word	right_unfurl3_lzsa	; next
	.byte	128+30	;	.word	right_unfurl4_lzsa	; next
	.byte	128+30	;	.word	right_unfurl5_lzsa	; next
	.byte	128+40	;	.word	onboard_lzsa		; next
	.byte	0						; finish

flying_sequence:
	.byte   255						; load to bg
	.word	sky_bg_lzsa					;  this
	.byte	128+50	;	.word	flying01_lzsa		; next
	.byte	128+50	;	.word	flying03_lzsa		; next
	.byte	128+50	;	.word	flying05_lzsa		; next
	.byte	128+50	;	.word	flying07_lzsa		; next
	.byte	128+50	;	.word	flying09_lzsa		; next
	.byte	128+50	;	.word	flying11_lzsa		; next
	.byte	128+50	;	.word	the_end01_lzsa		; next
	.byte	128+50	;	.word	the_end02_lzsa		; next
	.byte	128+50	;	.word	the_end03_lzsa		; next
	.byte	128+50	;	.word	the_end04_lzsa		; next
	.byte	128+50	;	.word	the_end05_lzsa		; next
	.byte	128+50	;	.word	the_end06_lzsa		; next
	.byte	128+50	;	.word	the_end07_lzsa		; next
	.byte	128+120	;	.word	the_end08_lzsa		; next
	.byte	128+50	;	.word	the_end09_lzsa		; next
	.byte	128+50	;	.word	the_end10_lzsa		; next
	.byte	0						; finish


.include "credits.s"


.include "../text_print.s"
.include "../gr_pageflip.s"
.include "../decompress_fast_v2.s"
.include "../gr_fast_clear.s"
.include "../gr_copy.s"
.include "../gr_offsets.s"
.include "../gr_overlay.s"
.include "../gr_run_sequence2.s"

.include "../pt3_player/pt3_lib_core.s"
.include "../pt3_player/pt3_lib_init.s"
.include "../pt3_player/interrupt_handler.s"
.include "../pt3_player/pt3_lib_mockingboard_detect.s"
.include "../pt3_player/pt3_lib_mockingboard_setup.s"

; backgrounds
.include "graphics/ending/ootw_c16_end.inc"

PT3_LOC = song

; must be page aligned
.align 256
song:
.incbin "music/ootw_outro.pt3"
