;===========================================
; Library to decode Vortex Tracker PT3 files
; in 6502 assembly for Apple ][ Mockingboard
;
; by Vince Weaver <vince@deater.net>

; Roughly based on the Formats.pas Pascal code from Ay_Emul

; Size Optimization -- Mem+Code (pt3_lib_end-note_a)
; + 3407 bytes -- original working implementation
; + 3302 bytes -- autogenerate the volume tables
; + 3297 bytes -- remove some un-needed bytes from struct
; + 3262 bytes -- combine some duplicated code in $1X/$BX env setting
; + 3253 bytes -- remove unnecessary variable
; + 3203 bytes -- combine common code in note decoder

; TODO
;   move some of these flags to be bits rather than bytes?
;   enabled could be bit 6 or 7 for fast checking
; NOTE_ENABLED,ENVELOPE_ENABLED,SIMPLE_GLISS,ENV_SLIDING,AMP_SLIDING?


; Use memset to set things to 0?

NOTE_VOLUME		=0
NOTE_TONE_SLIDING_L	=1
NOTE_TONE_SLIDING_H	=2
NOTE_ENABLED		=3
NOTE_ENVELOPE_ENABLED	=4
NOTE_SAMPLE_POINTER_L	=5
NOTE_SAMPLE_POINTER_H	=6
NOTE_SAMPLE_LOOP	=7
NOTE_SAMPLE_LENGTH	=8
NOTE_TONE_L		=9
NOTE_TONE_H		=10
NOTE_AMPLITUDE		=11
NOTE_NOTE		=12
NOTE_LEN		=13
NOTE_LEN_COUNT		=14
NOTE_ADDR_L		=15
NOTE_ADDR_H		=16
NOTE_ORNAMENT_POINTER_L	=17
NOTE_ORNAMENT_POINTER_H	=18
NOTE_ORNAMENT_LOOP	=19
NOTE_ORNAMENT_LENGTH	=20
NOTE_ONOFF		=21
NOTE_TONE_ACCUMULATOR_L	=22
NOTE_TONE_ACCUMULATOR_H	=23
NOTE_TONE_SLIDE_COUNT	=24
NOTE_ORNAMENT_POSITION	=25
NOTE_SAMPLE_POSITION	=26
NOTE_ENVELOPE_SLIDING	=27
NOTE_NOISE_SLIDING	=28
NOTE_AMPLITUDE_SLIDING	=29
NOTE_ONOFF_DELAY	=30
NOTE_OFFON_DELAY	=31
NOTE_TONE_SLIDE_STEP_L	=32
NOTE_TONE_SLIDE_STEP_H	=33
NOTE_TONE_SLIDE_DELAY	=34
NOTE_SIMPLE_GLISS	=35
NOTE_SLIDE_TO_NOTE	=36
NOTE_TONE_DELTA_L	=37
NOTE_TONE_DELTA_H	=38
NOTE_TONE_SLIDE_TO_STEP	=39

NOTE_STRUCT_SIZE=40

note_a:
	.byte	$0	; NOTE_VOLUME
	.byte	$0	; NOTE_TONE_SLIDING_L
	.byte	$0	; NOTE_TONE_SLIDING_H
	.byte	$0	; NOTE_ENABLED
	.byte	$0	; NOTE_ENVELOPE_ENABLED
	.byte	$0	; NOTE_SAMPLE_POINTER_L
	.byte	$0	; NOTE_SAMPLE_POINTER_H
	.byte	$0	; NOTE_SAMPLE_LOOP
	.byte	$0	; NOTE_SAMPLE_LENGTH
	.byte	$0	; NOTE_TONE_L
	.byte	$0	; NOTE_TONE_H
	.byte	$0	; NOTE_AMPLITUDE
	.byte	$0	; NOTE_NOTE
	.byte	$0	; NOTE_LEN
	.byte	$0	; NOTE_LEN_COUNT
	.byte	$0	; NOTE_ADDR_L
	.byte	$0	; NOTE_ADDR_H
	.byte	$0	; NOTE_ORNAMENT_POINTER_L
	.byte	$0	; NOTE_ORNAMENT_POINTER_H
	.byte	$0	; NOTE_ORNAMENT_LOOP
	.byte	$0	; NOTE_ORNAMENT_LENGTH
	.byte	$0	; NOTE_ONOFF
	.byte	$0	; NOTE_TONE_ACCUMULATOR_L
	.byte	$0	; NOTE_TONE_ACCUMULATOR_H
	.byte	$0	; NOTE_TONE_SLIDE_COUNT
	.byte	$0	; NOTE_ORNAMENT_POSITION
	.byte	$0	; NOTE_SAMPLE_POSITION
	.byte	$0	; NOTE_ENVELOPE_SLIDING
	.byte	$0	; NOTE_NOISE_SLIDING
	.byte	$0	; NOTE_AMPLITUDE_SLIDING
	.byte	$0	; NOTE_ONOFF_DELAY
	.byte	$0	; NOTE_OFFON_DELAY
	.byte	$0	; NOTE_TONE_SLIDE_STEP_L
	.byte	$0	; NOTE_TONE_SLIDE_STEP_H
	.byte	$0	; NOTE_TONE_SLIDE_DELAY
	.byte	$0	; NOTE_SIMPLE_GLISS
	.byte	$0	; NOTE_SLIDE_TO_NOTE
	.byte	$0	; NOTE_TONE_DELTA_L
	.byte	$0	; NOTE_TONE_DELTA_H
	.byte	$0	; NOTE_TONE_SLIDE_TO_STEP

note_b:
	.byte	$0	; NOTE_VOLUME
	.byte	$0	; NOTE_TONE_SLIDING_L
	.byte	$0	; NOTE_TONE_SLIDING_H
	.byte	$0	; NOTE_ENABLED
	.byte	$0	; NOTE_ENVELOPE_ENABLED
	.byte	$0	; NOTE_SAMPLE_POINTER_L
	.byte	$0	; NOTE_SAMPLE_POINTER_H
	.byte	$0	; NOTE_SAMPLE_LOOP
	.byte	$0	; NOTE_SAMPLE_LENGTH
	.byte	$0	; NOTE_TONE_L
	.byte	$0	; NOTE_TONE_H
	.byte	$0	; NOTE_AMPLITUDE
	.byte	$0	; NOTE_NOTE
	.byte	$0	; NOTE_LEN
	.byte	$0	; NOTE_LEN_COUNT
	.byte	$0	; NOTE_ADDR_L
	.byte	$0	; NOTE_ADDR_H
	.byte	$0	; NOTE_ORNAMENT_POINTER_L
	.byte	$0	; NOTE_ORNAMENT_POINTER_H
	.byte	$0	; NOTE_ORNAMENT_LOOP
	.byte	$0	; NOTE_ORNAMENT_LENGTH
	.byte	$0	; NOTE_ONOFF
	.byte	$0	; NOTE_TONE_ACCUMULATOR_L
	.byte	$0	; NOTE_TONE_ACCUMULATOR_H
	.byte	$0	; NOTE_TONE_SLIDE_COUNT
	.byte	$0	; NOTE_ORNAMENT_POSITION
	.byte	$0	; NOTE_SAMPLE_POSITION
	.byte	$0	; NOTE_ENVELOPE_SLIDING
	.byte	$0	; NOTE_NOISE_SLIDING
	.byte	$0	; NOTE_AMPLITUDE_SLIDING
	.byte	$0	; NOTE_ONOFF_DELAY
	.byte	$0	; NOTE_OFFON_DELAY
	.byte	$0	; NOTE_TONE_SLIDE_STEP_L
	.byte	$0	; NOTE_TONE_SLIDE_STEP_H
	.byte	$0	; NOTE_TONE_SLIDE_DELAY
	.byte	$0	; NOTE_SIMPLE_GLISS
	.byte	$0	; NOTE_SLIDE_TO_NOTE
	.byte	$0	; NOTE_TONE_DELTA_L
	.byte	$0	; NOTE_TONE_DELTA_H
	.byte	$0	; NOTE_TONE_SLIDE_TO_STEP

note_c:
	.byte	$0	; NOTE_VOLUME
	.byte	$0	; NOTE_TONE_SLIDING_L
	.byte	$0	; NOTE_TONE_SLIDING_H
	.byte	$0	; NOTE_ENABLED
	.byte	$0	; NOTE_ENVELOPE_ENABLED
	.byte	$0	; NOTE_SAMPLE_POINTER_L
	.byte	$0	; NOTE_SAMPLE_POINTER_H
	.byte	$0	; NOTE_SAMPLE_LOOP
	.byte	$0	; NOTE_SAMPLE_LENGTH
	.byte	$0	; NOTE_TONE_L
	.byte	$0	; NOTE_TONE_H
	.byte	$0	; NOTE_AMPLITUDE
	.byte	$0	; NOTE_NOTE
	.byte	$0	; NOTE_LEN
	.byte	$0	; NOTE_LEN_COUNT
	.byte	$0	; NOTE_ADDR_L
	.byte	$0	; NOTE_ADDR_H
	.byte	$0	; NOTE_ORNAMENT_POINTER_L
	.byte	$0	; NOTE_ORNAMENT_POINTER_H
	.byte	$0	; NOTE_ORNAMENT_LOOP
	.byte	$0	; NOTE_ORNAMENT_LENGTH
	.byte	$0	; NOTE_ONOFF
	.byte	$0	; NOTE_TONE_ACCUMULATOR_L
	.byte	$0	; NOTE_TONE_ACCUMULATOR_H
	.byte	$0	; NOTE_TONE_SLIDE_COUNT
	.byte	$0	; NOTE_ORNAMENT_POSITION
	.byte	$0	; NOTE_SAMPLE_POSITION
	.byte	$0	; NOTE_ENVELOPE_SLIDING
	.byte	$0	; NOTE_NOISE_SLIDING
	.byte	$0	; NOTE_AMPLITUDE_SLIDING
	.byte	$0	; NOTE_ONOFF_DELAY
	.byte	$0	; NOTE_OFFON_DELAY
	.byte	$0	; NOTE_TONE_SLIDE_STEP_L
	.byte	$0	; NOTE_TONE_SLIDE_STEP_H
	.byte	$0	; NOTE_TONE_SLIDE_DELAY
	.byte	$0	; NOTE_SIMPLE_GLISS
	.byte	$0	; NOTE_SLIDE_TO_NOTE
	.byte	$0	; NOTE_TONE_DELTA_L
	.byte	$0	; NOTE_TONE_DELTA_H
	.byte	$0	; NOTE_TONE_SLIDE_TO_STEP

pt3_version:		.byte	$0
pt3_frequency_table:	.byte	$0
pt3_speed:		.byte	$0
pt3_loop:		.byte	$0

pt3_noise_period:	.byte	$0
pt3_noise_add:		.byte	$0

pt3_envelope_period_l:	.byte	$0
pt3_envelope_period_h:	.byte	$0
pt3_envelope_slide_l:	.byte	$0
pt3_envelope_slide_h:	.byte	$0
pt3_envelope_slide_add_l:.byte	$0
pt3_envelope_slide_add_h:.byte	$0
pt3_envelope_add:	.byte	$0
pt3_envelope_type:	.byte	$0
pt3_envelope_type_old:	.byte	$0
pt3_envelope_delay:	.byte	$0
pt3_envelope_delay_orig:.byte	$0

pt3_mixer_value:	.byte	$0

pt3_pattern_done:	.byte	$0

temp_word_l:		.byte	$0
temp_word_h:		.byte	$0

note_command:		; shared space with sample_b0
sample_b0:		.byte	$0
sample_b1:		.byte	$0

convert_177:		.byte	$1

; Header offsets

PT3_VERSION		= $0D
PT3_HEADER_FREQUENCY	= $63
PT3_SPEED		= $64
PT3_LOOP		= $66
PT3_PATTERN_LOC_L	= $67
PT3_PATTERN_LOC_H	= $68
PT3_SAMPLE_LOC_L	= $69
PT3_SAMPLE_LOC_H	= $6A
PT3_ORNAMENT_LOC_L	= $A9
PT3_ORNAMENT_LOC_H	= $AA
PT3_PATTERN_TABLE	= $C9

ysave:	.byte	$00
freq_l:	.byte	$00
freq_h:	.byte	$00

e_slide_amount:	.byte	$0

prev_note:	.byte $0
prev_sliding_l:	.byte $0
prev_sliding_h:	.byte $0
decode_done:	.byte $0
current_val:	.byte $0

	;===========================
	; Load Ornament
	;===========================
	; ornament value in A
	; note offset in X

	; Ornament table pointers are 16-bits little endian
	; There are 16 of these pointers starting at $aa:$a9
	; Our ornament starts at address (A*2)+that pointer
	; We point ORNAMENT_H:ORNAMENT_L to this
	; then we load the length/data values
	; and then leave ORNAMENT_H:ORNAMENT_L pointing to begnning of
	; the ornament data

	; Optimization:
	;	Loop and length only used once, can be located negative
	;	from the pointer, but 6502 doesn't make addressing like that
	;	easy.  Can't self modify as channels A/B/C have own copies
	; 	of the var.

load_ornament:

	sty	ysave		; save Y value				; 3

	;pt3->ornament_patterns[i]=
        ;               (pt3->data[0xaa+(i*2)]<<8)|pt3->data[0xa9+(i*2)];

	asl			; A*2					; 2
	adc	#PT3_ORNAMENT_LOC_L					; 2
	tay								; 2

	; a->ornament_pointer=pt3->ornament_patterns[a->ornament];

	lda	PT3_LOC,Y						; 4+
	sta	ORNAMENT_L						; 3

	iny								; 2
	lda	PT3_LOC,Y						; 4+

	; we're assuming PT3 is loaded to a page boundary

	adc	#>PT3_LOC						; 2
	sta	ORNAMENT_H						; 3

	lda	#0							; 2
	sta	note_a+NOTE_ORNAMENT_POSITION,X				; 5

	tay								; 2

	; Set the loop value
	;     a->ornament_loop=pt3->data[a->ornament_pointer];
	lda	(ORNAMENT_L),Y						; 5+
	sta	note_a+NOTE_ORNAMENT_LOOP,X				; 5

	; Set the length value
	;     a->ornament_length=pt3->data[a->ornament_pointer];
	iny								; 2
	lda	(ORNAMENT_L),Y						; 5+
	sta	note_a+NOTE_ORNAMENT_LENGTH,X				; 5

	; Set the pointer to the value past the length

	lda	ORNAMENT_L						; 3
	adc	#$2							; 2
	sta	note_a+NOTE_ORNAMENT_POINTER_L,X			; 5
	lda	ORNAMENT_H						; 3
	adc	#$0							; 2
	sta	note_a+NOTE_ORNAMENT_POINTER_H,X			; 5

	ldy	ysave		; restore Y value			; 3

	rts								; 6

								;============
								;	87

	;===========================
	; Load Sample
	;===========================
	; sample in A
	; which note offset in X

	; Sample table pointers are 16-bits little endian
	; There are 32 of these pointers starting at $6a:$69
	; Our sample starts at address (A*2)+that pointer
	; We point SAMPLE_H:SAMPLE_L to this
	; then we load the length/data values
	; and then leave SAMPLE_H:SAMPLE_L pointing to begnning of
	; the sample data

	; Optimization:
	;	see comments on ornament setting

load_sample:

	sty	ysave							; 3

	;pt3->ornament_patterns[i]=
        ;               (pt3->data[0x6a+(i*2)]<<8)|pt3->data[0x69+(i*2)];

	asl			; A*2					; 2
	adc	#PT3_SAMPLE_LOC_L					; 2
	tay								; 2

	; Set the initial sample pointer
	;     a->sample_pointer=pt3->sample_patterns[a->sample];

	lda	PT3_LOC,Y						; 4+
	sta	SAMPLE_L						; 3

	iny								; 2
	lda	PT3_LOC,Y						; 4+

	; assume pt3 file is at page boundary
	adc	#>PT3_LOC						; 2
	sta	SAMPLE_H						; 3

	; Set the loop value
	;     a->sample_loop=pt3->data[a->sample_pointer];

	ldy	#0							; 2
	lda	(SAMPLE_L),Y						; 5+
	sta	note_a+NOTE_SAMPLE_LOOP,X				; 5

	; Set the length value
	;     a->sample_length=pt3->data[a->sample_pointer];

	iny								; 2
	lda	(SAMPLE_L),Y						; 5+
	sta	note_a+NOTE_SAMPLE_LENGTH,X				; 5

	; Set pointer to beginning of samples

	lda	SAMPLE_L						; 3
	adc	#$2							; 2
	sta	note_a+NOTE_SAMPLE_POINTER_L,X				; 5
	lda	SAMPLE_H						; 3
	adc	#$0							; 2
	sta	note_a+NOTE_SAMPLE_POINTER_H,X				; 5

	ldy	ysave							; 3

	rts								; 6
								;============
								;	 80

	;====================================
	; pt3_init_song
	;====================================
	;
	;	TODO: change to a memset type instruction?
	;	it will save bytes only if the labels are adjacent
	;	it will add a lot more cycles, though
pt3_init_song:
	lda	#$f							; 2
	sta	note_a+NOTE_VOLUME					; 4
	sta	note_b+NOTE_VOLUME					; 4
	sta	note_c+NOTE_VOLUME					; 4

	lda	#$0							; 2
	sta	DONE_SONG						; 3
	sta	note_a+NOTE_TONE_SLIDING_L				; 4
	sta	note_b+NOTE_TONE_SLIDING_L				; 4
	sta	note_c+NOTE_TONE_SLIDING_L				; 4
	sta	note_a+NOTE_TONE_SLIDING_H				; 4
	sta	note_b+NOTE_TONE_SLIDING_H				; 4
	sta	note_c+NOTE_TONE_SLIDING_H				; 4
	sta	note_a+NOTE_ENABLED					; 4
	sta	note_b+NOTE_ENABLED					; 4
	sta	note_c+NOTE_ENABLED					; 4
	sta	note_a+NOTE_ENVELOPE_ENABLED				; 4
	sta	note_b+NOTE_ENVELOPE_ENABLED				; 4
	sta	note_c+NOTE_ENVELOPE_ENABLED				; 4

	sta	pt3_noise_period					; 4
	sta	pt3_noise_add						; 4
	sta	pt3_envelope_period_l					; 4
	sta	pt3_envelope_period_h					; 4
	sta	pt3_envelope_type					; 4

	; default ornament/sample in A
	ldx	#(NOTE_STRUCT_SIZE*0)					; 2
	jsr	load_ornament						; 6+93
	lda	#1							; 2
	jsr	load_sample						; 6+86

	; default ornament/sample in B
	lda	#0							; 2
	ldx	#(NOTE_STRUCT_SIZE*1)					; 2
	jsr	load_ornament						; 6+93
	lda	#1							; 2
	jsr	load_sample						; 6+86

	; default ornament/sample in C
	lda	#0							; 2
	ldx	#(NOTE_STRUCT_SIZE*2)					; 2
	jsr	load_ornament						; 6+93
	lda	#1							; 2
	jsr	load_sample						; 6+86

	;=======================
	; load default speed
	; FIXME: change to self-modifying code

	lda	PT3_LOC+PT3_SPEED					; 4
	sta	pt3_speed						; 4

	;=======================
	; load loop
	; FIXME: change to self-modifying code

	lda	PT3_LOC+PT3_LOOP					; 4
	sta	pt3_loop						; 4


	;======================
	; calculate version
	ldx	#6							; 2
	lda	PT3_LOC+PT3_VERSION					; 4
	sec								; 2
	sbc	#'0'							; 2
	cmp	#9							; 2
	bcs	not_ascii_number	; bge				; 2/3
	tax								; 2

not_ascii_number:
	stx	pt3_version						; 3

	;=======================
	; Pick which volume number, based on version

	; if (PlParams.PT3.PT3_Version <= 4)

	cpx	#5							; 2

	; carry clear = 3.3/3.4 table
	; carry set = 3.5 table

	jsr	VolTableCreator						; 6+??

	rts								; 6









	;=====================================
	; Calculate Note
	;=====================================
	; note offset in X

calculate_note:

	lda	note_a+NOTE_ENABLED,X					; 4+
	bne	note_enabled						; 2/3

	sta	note_a+NOTE_AMPLITUDE,X					; 5
	jmp	done_note						; 3

note_enabled:

	lda	note_a+NOTE_SAMPLE_POINTER_H,X				; 4+
	sta	SAMPLE_H						; 3
	lda	note_a+NOTE_SAMPLE_POINTER_L,X				; 4+
	sta	SAMPLE_L						; 3

	lda	note_a+NOTE_ORNAMENT_POINTER_H,X			; 4+
	sta	ORNAMENT_H						; 3
	lda	note_a+NOTE_ORNAMENT_POINTER_L,X			; 4+
	sta	ORNAMENT_L						; 3


	lda	note_a+NOTE_SAMPLE_POSITION,X				; 4+
	asl								; 2
	asl								; 2
	tay								; 2

	;  b0 = pt3->data[a->sample_pointer + a->sample_position * 4];
	lda	(SAMPLE_L),Y						; 5+
	sta	sample_b0						; 4

	;  b1 = pt3->data[a->sample_pointer + a->sample_position * 4 + 1];
	iny								; 2
	lda	(SAMPLE_L),Y						; 5+
	sta	sample_b1						; 4

	;  a->tone = pt3->data[a->sample_pointer + a->sample_position*4+2];
	;  a->tone+=(pt3->data[a->sample_pointer + a->sample_position*4+3])<<8;
	iny								; 2
	lda	(SAMPLE_L),Y						; 5+
	sta	note_a+NOTE_TONE_L,X					; 4

	iny								; 2
	lda	(SAMPLE_L),Y						; 5+
	sta	note_a+NOTE_TONE_H,X					; 4

	;  a->tone += a->tone_accumulator;
	clc								; 2
	lda	note_a+NOTE_TONE_L,X					; 4+
	adc	note_a+NOTE_TONE_ACCUMULATOR_L,X			; 4+
	sta	note_a+NOTE_TONE_L,X					; 4+
	lda	note_a+NOTE_TONE_H,X					; 4+
	adc	note_a+NOTE_TONE_ACCUMULATOR_H,X			; 4+
	sta	note_a+NOTE_TONE_H,X					; 4+

	;=============================
	; Accumulate tone if set
	;	(if sample_b1 & $40)

	lda	#$40		; if (b1&0x40)
	bit	sample_b1
	beq	no_accum	;     (so, if b1&0x40 is zero, skip it)

	lda	note_a+NOTE_TONE_L,X	; tone_accumulator=tone
	sta	note_a+NOTE_TONE_ACCUMULATOR_L,X
	lda	note_a+NOTE_TONE_H,X
	sta	note_a+NOTE_TONE_ACCUMULATOR_H,X

no_accum:

	;============================
	; Calculate tone
	;  j = a->note + (pt3->data[a->ornament_pointer + a->ornament_position]
	clc
	lda	note_a+NOTE_ORNAMENT_POSITION,X
	tay
	lda	(ORNAMENT_L),Y
	adc	note_a+NOTE_NOTE,X

	;  if (j < 0) j = 0;
	bpl	note_not_negative
	lda	#0

	; if (j > 95) j = 95;
note_not_negative:
	cmp	#96
	bcc	note_not_too_high	; blt

	lda	#95

note_not_too_high:

	;  w = GetNoteFreq(j,pt3->frequency_table);

	jsr	GetNoteFreq

	;  a->tone = (a->tone + a->tone_sliding + w) & 0xfff;

	clc
	lda	note_a+NOTE_TONE_L,X
	adc	note_a+NOTE_TONE_SLIDING_L,X
	sta	note_a+NOTE_TONE_L,X
	lda	note_a+NOTE_TONE_H,X
	adc	note_a+NOTE_TONE_SLIDING_H,X
	sta	note_a+NOTE_TONE_H,X

	clc
	lda	note_a+NOTE_TONE_L,X
	adc	freq_l
	sta	note_a+NOTE_TONE_L,X
	lda	note_a+NOTE_TONE_H,X
	adc	freq_h
	and	#$0f
	sta	note_a+NOTE_TONE_H,X

	;=====================
	; handle tone sliding

	lda	note_a+NOTE_TONE_SLIDE_COUNT,X
	bmi	no_tone_sliding		;  if (a->tone_slide_count > 0) {
	beq	no_tone_sliding

	dec	note_a+NOTE_TONE_SLIDE_COUNT,X	; a->tone_slide_count--;
	bne	no_tone_sliding		; if (a->tone_slide_count==0) {


	; a->tone_sliding+=a->tone_slide_step
	clc
	lda	note_a+NOTE_TONE_SLIDING_L,X
	adc	note_a+NOTE_TONE_SLIDE_STEP_L,X
	sta	note_a+NOTE_TONE_SLIDING_L,X
	lda	note_a+NOTE_TONE_SLIDING_H,X
	adc	note_a+NOTE_TONE_SLIDE_STEP_H,X
	sta	note_a+NOTE_TONE_SLIDING_H,X

	; a->tone_slide_count = a->tone_slide_delay;
	lda	note_a+NOTE_TONE_SLIDE_DELAY,X
	sta	note_a+NOTE_TONE_SLIDE_COUNT,X

	lda	note_a+NOTE_SIMPLE_GLISS,X
	bne	no_tone_sliding		; if (!a->simplegliss) {

	; FIXME: do these need to be signed compares?

check1:
	lda	note_a+NOTE_TONE_SLIDE_STEP_H,X
	bpl	check2	;           if ( ((a->tone_slide_step < 0) &&

	;				(a->tone_sliding <= a->tone_delta) ||

	; 16 bit signed compare
	lda	note_a+NOTE_TONE_SLIDING_L,X	; NUM1-NUM2
	cmp	note_a+NOTE_TONE_DELTA_L,X	;
	lda	note_a+NOTE_TONE_SLIDING_H,X
	sbc	note_a+NOTE_TONE_DELTA_H,X
	bvc	sc_loser1			; N eor V
	eor	#$80
sc_loser1:
	bmi	slide_to_note	; then A (signed) < NUM (signed) and BMI will branch

	; equals case
	lda	note_a+NOTE_TONE_SLIDING_L,X
	cmp	note_a+NOTE_TONE_DELTA_L,X
	bne	check2
	lda	note_a+NOTE_TONE_SLIDING_H,X
	cmp	note_a+NOTE_TONE_DELTA_H,X
	beq	slide_to_note

check2:
	lda	note_a+NOTE_TONE_SLIDE_STEP_H,X
	bmi	no_tone_sliding		; ((a->tone_slide_step >= 0) &&

	;				(a->tone_sliding >= a->tone_delta)

	; 16 bit signed compare
	lda	note_a+NOTE_TONE_SLIDING_L,X	; NUM1-NUM2
	cmp	note_a+NOTE_TONE_DELTA_L,X	;
	lda	note_a+NOTE_TONE_SLIDING_H,X
	sbc	note_a+NOTE_TONE_DELTA_H,X
	bvc	sc_loser2			; N eor V
	eor	#$80
sc_loser2:
	bmi	no_tone_sliding	; then A (signed) < NUM (signed) and BMI will branch

slide_to_note:
	; a->note = a->slide_to_note;
	lda	note_a+NOTE_SLIDE_TO_NOTE,X
	sta	note_a+NOTE_NOTE,X
	lda	#0
	sta	note_a+NOTE_TONE_SLIDE_COUNT,X
	sta	note_a+NOTE_TONE_SLIDING_L,X
	sta	note_a+NOTE_TONE_SLIDING_H,X


no_tone_sliding:

	;=========================
	; Calculate the amplitude
	;=========================
calc_amplitude:
	; get base value from the sample (bottom 4 bits of sample_b1)

	lda	sample_b1		;  a->amplitude= (b1 & 0xf);
	and	#$f
	sta	note_a+NOTE_AMPLITUDE,X

	;========================================
	; if b0 top bit is set, it means sliding

	; adjust amplitude sliding

	lda	sample_b0		;  if ((b0 & 0x80)!=0) {
	and	#$80
	beq	done_amp_sliding	; so if top bit not set, skip

	;================================
	; if top bits 0b11 then slide up
	; if top buts 0b10 then slide down

	lda	sample_b0		;     if ((b0&0x40)!=0) {
	and	#$40
	beq	amp_slide_down

amp_slide_up:
	; if (a->amplitude_sliding < 15) {
	; a pain to do signed compares
	lda	note_a+NOTE_AMPLITUDE_SLIDING,X
	sec
	sbc	#15
	bvc	asu_signed
	eor	#$80
asu_signed:
	bpl	done_amp_sliding	; skip if A>=15
	inc	note_a+NOTE_AMPLITUDE_SLIDING,X	; a->amplitude_sliding++;
	jmp	done_amp_sliding

amp_slide_down:
	; if (a->amplitude_sliding > -15) {
	; a pain to do signed compares
	lda	note_a+NOTE_AMPLITUDE_SLIDING,X
	sec
	sbc	#$f1		; -15
	bvc	asd_signed
	eor	#$80
asd_signed:
	bmi	done_amp_sliding	; if A < -15, skip subtract

	dec	note_a+NOTE_AMPLITUDE_SLIDING,X	; a->amplitude_sliding--;

done_amp_sliding:

	; a->amplitude+=a->amplitude_sliding;
	clc
	lda	note_a+NOTE_AMPLITUDE,X
	adc	note_a+NOTE_AMPLITUDE_SLIDING,X
	sta	note_a+NOTE_AMPLITUDE,X

	; clamp amplitude to 0 - 15

	lda	note_a+NOTE_AMPLITUDE,X
check_amp_lo:
	bpl	check_amp_hi
	lda	#0
	jmp	write_clamp_amplitude

check_amp_hi:
	cmp	#16
	bcc	done_clamp_amplitude	; blt
	lda	#15
write_clamp_amplitude:
	sta	note_a+NOTE_AMPLITUDE,X

done_clamp_amplitude:

	; We generate the proper table at runtime now
	; so always in Volume Table
	; a->amplitude = PT3VolumeTable_33_34[a->volume][a->amplitude];
	; a->amplitude = PT3VolumeTable_35[a->volume][a->amplitude];

	lda	note_a+NOTE_VOLUME,X					; 4+
	asl								; 2
	asl								; 2
	asl								; 2
	asl								; 2
	ora	note_a+NOTE_AMPLITUDE,X					; 4+

	tay								; 2
	lda	VolumeTable,Y						; 4+
	sta	note_a+NOTE_AMPLITUDE,X					; 5

done_table:


check_envelope_enable:
	; Bottom bit of b0 indicates our sample has envelope
	; Also make sure envelopes are enabled


	;  if (((b0 & 0x1) == 0) && ( a->envelope_enabled)) {
	lda	sample_b0
	and	#$1
	bne	envelope_slide

	lda	note_a+NOTE_ENVELOPE_ENABLED,X
	beq	envelope_slide


	; Bit 4 of the per-channel AY-3-8910 amplitude specifies
	; envelope enabled

	lda	note_a+NOTE_AMPLITUDE,X	; a->amplitude |= 16;
	ora	#$10
	sta	note_a+NOTE_AMPLITUDE,X


envelope_slide:
	; Envelope slide
	; If b1 top bits are 10 or 11

	lda	#$80
	bit	sample_b1
	beq	else_noise_slide	; if ((b1 & 0x80) != 0) {

	lda	#$20
	bit	sample_b0
	beq	envelope_slide_down	;     if ((b0 & 0x20) != 0) {

	; FIXME: this can be optimized

envelope_slide_down:

	; j = ((b0>>1)|0xF0) + a->envelope_sliding
	lda	sample_b0
	lsr
	ora	#$f0
	clc
	adc	note_a+NOTE_ENVELOPE_SLIDING,X
	sta	e_slide_amount				; j

envelope_slide_up:
	; j = ((b0>>1)&0xF) + a->envelope_sliding;
	lda	sample_b0
	lsr
	and	#$0f
	clc
	adc	note_a+NOTE_ENVELOPE_SLIDING,X
	sta	e_slide_amount				; j

envelope_slide_done:

	lda	#$20
	bit	sample_b1
	beq	last_envelope	;     if (( b1 & 0x20) != 0) {

	; a->envelope_sliding = j;
	lda	e_slide_amount
	sta	note_a+NOTE_ENVELOPE_SLIDING,X

last_envelope:

	; pt3->envelope_add+=j;

	clc
	lda	e_slide_amount
	adc	pt3_envelope_add
	sta	pt3_envelope_add

	jmp	noise_slide_done	; skip else

else_noise_slide:
	; Noise slide
	;  else {

	; pt3->noise_add = (b0>>1) + a->noise_sliding;
	lda	sample_b0
	lsr
	clc
	adc	note_a+NOTE_NOISE_SLIDING,X
	sta	pt3_noise_add

	lda	#$20
	bit	sample_b1
	beq	noise_slide_done	;     if ((b1 & 0x20) != 0) {

	; noise_sliding = pt3_noise_add
	lda	pt3_noise_add
	sta	note_a+NOTE_NOISE_SLIDING,X

noise_slide_done:
	;======================
	; set mixer

	lda	sample_b1	;  pt3->mixer_value = ((b1 >>1) & 0x48) | pt3->mixer_value;
	lsr
	and	#$48
	ora	pt3_mixer_value
	sta	pt3_mixer_value


	;========================
	; increment sample position

	inc	note_a+NOTE_SAMPLE_POSITION,X	;  a->sample_position++;

	lda	note_a+NOTE_SAMPLE_POSITION,X
	cmp	note_a+NOTE_SAMPLE_LENGTH,X

	bcc	sample_pos_ok			; blt

	lda	note_a+NOTE_SAMPLE_LOOP,X
	sta	note_a+NOTE_SAMPLE_POSITION,X

sample_pos_ok:

	;========================
	; increment ornament position

	inc	note_a+NOTE_ORNAMENT_POSITION,X	;  a->ornament_position++;
	lda	note_a+NOTE_ORNAMENT_POSITION,X
	cmp	note_a+NOTE_ORNAMENT_LENGTH,X

	bcc	ornament_pos_ok			; blt

	lda	note_a+NOTE_ORNAMENT_LOOP,X
	sta	note_a+NOTE_ORNAMENT_POSITION,X
ornament_pos_ok:


done_note:
	; set mixer value
	; this is a bit complex (from original code)
	; after 3 calls it is set up properly
	lda	pt3_mixer_value
	lsr
	sta	pt3_mixer_value

handle_onoff:
	lda	note_a+NOTE_ONOFF,X	;if (a->onoff>0) {
	beq	done_onoff

	dec	note_a+NOTE_ONOFF,X	; a->onoff--;

	bne	done_onoff		;   if (a->onoff==0) {
	lda	note_a+NOTE_ENABLED,X
	eor	#$1			; toggle
	sta	note_a+NOTE_ENABLED,X

	bne	do_offon
do_onoff:
	lda	note_a+NOTE_ONOFF_DELAY,X	; if (a->enabled) a->onoff=a->onoff_delay;
	jmp	put_offon
do_offon:
	lda	note_a+NOTE_OFFON_DELAY,X ;      else a->onoff=a->offon_delay;
put_offon:
	sta	note_a+NOTE_ONOFF,X

done_onoff:

	rts								; 6







spec_command:	.byte	$0

	;=====================================
	; Decode Note
	;=====================================
	; X points to the note offset

	; Timings (from ===>)
	;	00:    14+30
	;	0X:    14+15
	;	10:    14+5 +124
	;	1X:    14+5 +193
	;	2X/3X: 14+5 +17
	;	4X:    14+5+5 + 111
	;	5X:	14+5+5+ 102
	;	

decode_note:

	; Init vars

	lda	#0							; 2
	sta	spec_command						; 4
	sta	decode_done						; 4

	; Skip decode if note still running
	lda	note_a+NOTE_LEN_COUNT,X					; 4+
	cmp	#2							; 2
	bcc	keep_decoding		; blt, assume not negative	; 2/3

	; we are still running, decrement and early return
	dec	note_a+NOTE_LEN_COUNT,X					; 7
	rts								; 6

keep_decoding:

	lda	note_a+NOTE_NOTE,X		; store prev note	; 4+
	sta	prev_note						; 4

	lda	note_a+NOTE_TONE_SLIDING_H,X	; store prev sliding	; 4+
	sta	prev_sliding_h						; 4
	lda	note_a+NOTE_TONE_SLIDING_L,X				; 4+
	sta	prev_sliding_l						; 4


	ldy	#0							; 2
								;============
								;	 26

note_decode_loop:
	lda	note_a+NOTE_LEN,X		; re-up length count	; 4+
	sta	note_a+NOTE_LEN_COUNT,X					; 5

	lda	note_a+NOTE_ADDR_L,X					; 4+
	sta	PATTERN_L						; 3
	lda	note_a+NOTE_ADDR_H,X					; 4+
	sta	PATTERN_H						; 3
;===>
	; get next value
	lda	(PATTERN_L),Y						; 5+
	sta	note_command		; save termporarily		; 4

	; FIXME: use a jump table??
	;  further reflection, that would require 32-bytes of addresses
	;  in addition to needing X or Y to index the jump table.  hmmm

	and	#$f0							; 2

	; cmp	#$00
	bne	decode_case_1X						; 2/3
								;=============
								;	14

decode_case_0X:
	;==============================
	; $0X set special effect
	;==============================
									; -1
	lda	note_command						; 4
	and	#$f							; 2

	; we can always store spec as 0 means no spec

	; FIXME: what if multiple spec commands?
	; Doesn't seem to happen in practice
	; But AY_emul has code to handle it

	sta	spec_command						; 4

	bne	decode_case_0X_not_zero					; 2/3
								;=============
								;	12
	; 00 case
	; means end of pattern
									; -1
	sta	note_a+NOTE_LEN_COUNT,X	; len_count=0;			; 5

	lda	#1							; 2
	sta	decode_done						; 4+

	dec	pt3_pattern_done					; 6

decode_case_0X_not_zero:

	jmp	done_decode						; 3


decode_case_1X:
	;==============================
	; $1X -- Set Envelope Type
	;==============================

	cmp	#$10							; 2
	bne	decode_case_2X						; 2/3
								;============
								;         5

									; -1
	lda	note_command						; 4
	and	#$0f
	bne	decode_case_not_10					; 3

decode_case_10:
	; 10 case - disable						; -1
	sta	note_a+NOTE_ENVELOPE_ENABLED,X	; A is 0		; 5
	beq	decode_case_1x_common		; branch always		; 3

decode_case_not_10:
									; -1
	jsr	set_envelope						; 6+64

decode_case_1x_common:

	iny								; 2
	lda	(PATTERN_L),Y						; 5+
	lsr								; 2
	jsr	load_sample						; 6+86

	lda	#0							; 2
	sta	note_a+NOTE_ORNAMENT_POSITION,X	; ornament_position=0	; 5

	jmp	done_decode						; 3

decode_case_2X:
decode_case_3X:
	;==============================
	; $2X/$3X set noise period
	;==============================

	cmp	#$40							; 2
	bcs	decode_case_4X		; branch greater/equal		; 3
									; -1
	lda	note_command						; 3
	sec								; 2
	sbc	#$20							; 2
	sta	pt3_noise_period					; 3

	jmp	done_decode						; 3
								;===========
								;	17

decode_case_4X:
	;==============================
	; $4X -- set ornament
	;==============================
;	cmp	#$40		; already set				;
	bne	decode_case_5X						; 3
									; -1
	lda	note_command						; 4
	and	#$0f		; set ornament to bottom nibble		; 2
	jsr	load_ornament						; 6+93

	jmp	done_decode						; 3
								;============
								;	110

decode_case_5X:
	;==============================
	; $5X-$AX set note
	;==============================
	cmp	#$B0							; 2
	bcs	decode_case_bX		 ; branch greater/equal		; 3

									; -1
	lda	note_command						; 4
	sec								; 2
	sbc	#$50							; 2
	sta	note_a+NOTE_NOTE,X	; note=(current_val-0x50);	; 5

	jsr	reset_note						; 6+69

	lda	#1							; 2
	sta	note_a+NOTE_ENABLED,X		; enabled=1		; 5


	jmp	done_decode						; 3

decode_case_bX:
	;============================================
	; $BX -- note length or envelope manipulation
	;============================================
;	cmp	#$b0		; already set from before
	bne	decode_case_cX

	lda	note_command
	and	#$f
	beq	decode_case_b0
	cmp	#1
	beq	decode_case_b1
	jmp	decode_case_bx_higher

decode_case_b0:
	; Disable envelope
	lda	#0
	sta	note_a+NOTE_ENVELOPE_ENABLED,X
	sta	note_a+NOTE_ORNAMENT_POSITION,X
	jmp	done_decode


decode_case_b1:
	; Set Length

	; get next byte
	iny
	lda	(PATTERN_L),Y

	sta	note_a+NOTE_LEN,X
	sta	note_a+NOTE_LEN_COUNT,X
	jmp	done_decode

decode_case_bx_higher:

	sec
	sbc	#1		; envelope_type=(current_val&0xf)-1;

	jsr	set_envelope						; 6+64

	jmp	done_decode

decode_case_cX:
	;==============================
	; $CX -- set volume
	;==============================
	cmp	#$c0
	bne	decode_case_dX

	lda	note_command
	and	#$0f
	bne	decode_case_cx_not_c0

decode_case_c0:
	; special case $C0 means shut down the note

	lda	#0
	sta	note_a+NOTE_ENABLED,X		; enabled=0

	jsr	reset_note						; 6+69

	jmp	done_decode

decode_case_cx_not_c0:
	sta	note_a+NOTE_VOLUME,X		; volume=current_val&0xf;
	jmp	done_decode

decode_case_dX:
	;==============================
	; $DX -- change sample
	;==============================
	; FIXME: merge with below?

	cmp	#$d0
	bne	decode_case_eX

	lda	note_command
	and	#$0f
	bne	decode_case_dx_not_d0

	;========================
	; d0 case means end note

	lda	#1
	sta	decode_done

	jmp	done_decode
decode_case_dx_not_d0:

	jsr	load_sample	; load sample in bottom nybble

	jmp	done_decode
decode_case_eX:
	;==============================
	; $EX -- change sample
	;==============================
	cmp	#$e0
	bne	decode_case_fX

	lda	note_command
	sec
	sbc	#$d0
	jsr	load_sample

	jmp	done_decode

decode_case_fX:
	;==============================
	; $FX - change ornament/sample
	;==============================

	; disable envelope
	lda	#0
	sta	note_a+NOTE_ENVELOPE_ENABLED,X

	; Set ornament to low byte of command
	lda	note_command
	and	#$f
	jsr	load_ornament		; ornament to load in A

	; Get next byte
	iny				; point to next byte
	lda	(PATTERN_L),Y

	; Set sample to value/2
	lsr				; divide by two
	jsr	load_sample		; sample to load in A

	; fallthrough

done_decode:

	iny		; point to next byte

	lda	decode_done
	bne	handle_effects

	jmp	note_decode_loop


	;=================================
	; handle effects
	;=================================
	; Note, the AYemul code has code to make sure these are applied
	; In the same order they appear.  We don't bother?
handle_effects:

	lda	spec_command						; 4

	;==============================
	; Effect #1 -- Tone Down
	;==============================
effect_1:
	cmp	#$1
	bne	effect_2

	lda	(PATTERN_L),Y	; load byte, set as slide delay
	iny

	sta	note_a+NOTE_TONE_SLIDE_DELAY,X
	sta	note_a+NOTE_TONE_SLIDE_COUNT,X

	lda	(PATTERN_L),Y	; load byte, set as slide step low
	iny
	sta	note_a+NOTE_TONE_SLIDE_STEP_L,X

	lda	(PATTERN_L),Y	; load byte, set as slide step high
	iny
	sta	note_a+NOTE_TONE_SLIDE_STEP_H,X

	lda	#0
	sta	note_a+NOTE_ONOFF,X
	lda	#1
	sta	note_a+NOTE_SIMPLE_GLISS,X

	jmp	no_effect

	;==============================
	; Effect #2 -- Portamento
	;==============================
effect_2:
	cmp	#$2
	beq	effect_2_small
	jmp	effect_3
effect_2_small:			; FIXME: make smaller
	lda	#0
	sta	note_a+NOTE_SIMPLE_GLISS,X
	sta	note_a+NOTE_ONOFF,X

	lda	(PATTERN_L),Y	; load byte, set as delay
	iny

	sta	note_a+NOTE_TONE_SLIDE_DELAY,X
	sta	note_a+NOTE_TONE_SLIDE_COUNT,X

	iny
	iny

	lda	(PATTERN_L),Y	; load byte, set as slide_step low
	iny
	sta	note_a+NOTE_TONE_SLIDE_STEP_L,X

	lda	(PATTERN_L),Y	; load byte, set as slide_step high
	sta	note_a+NOTE_TONE_SLIDE_STEP_H,X

	; 16-bit absolute value
	bpl	slide_step_positive

	eor	#$ff
	sta	note_a+NOTE_TONE_SLIDE_STEP_H,X
	lda	note_a+NOTE_TONE_SLIDE_STEP_L,X
	eor	#$ff
	clc
	adc	#$1
	sta	note_a+NOTE_TONE_SLIDE_STEP_L,X
	lda	note_a+NOTE_TONE_SLIDE_STEP_H,X
	adc	#$0
	sta	note_a+NOTE_TONE_SLIDE_STEP_H,X

slide_step_positive:

	iny	; moved here as it messed with flags


;	a->tone_delta=GetNoteFreq(a->note,pt3)-
;		GetNoteFreq(prev_note,pt3);

	lda	note_a+NOTE_NOTE,X
	jsr	GetNoteFreq
	lda	freq_l
	sta	note_a+NOTE_TONE_DELTA_L,X
	lda	freq_h
	sta	note_a+NOTE_TONE_DELTA_H,X

	lda	prev_note
	jsr	GetNoteFreq

	sec
	lda	note_a+NOTE_TONE_DELTA_L,X
	sbc	freq_l
	sta	note_a+NOTE_TONE_DELTA_L,X
	lda	note_a+NOTE_TONE_DELTA_H,X
	sbc	freq_h
	sta	note_a+NOTE_TONE_DELTA_H,X

	; a->slide_to_note=a->note;
	lda	note_a+NOTE_NOTE,X
	sta	note_a+NOTE_SLIDE_TO_NOTE,X

	; a->note=prev_note;
	lda	prev_note
	sta	note_a+NOTE_NOTE,X

	lda	pt3_version
	cmp	#$6
	bcc	weird_version			; blt

	lda	prev_sliding_l
	sta	note_a+NOTE_TONE_SLIDING_L,X
	lda	prev_sliding_h
	sta	note_a+NOTE_TONE_SLIDING_H,X

weird_version:

	; annoying 16-bit subtract, only care if negative
	;	if ((a->tone_delta - a->tone_sliding) < 0) {
	sec
	lda	note_a+NOTE_TONE_DELTA_L,X
	sbc	note_a+NOTE_TONE_SLIDING_L,X
	lda	note_a+NOTE_TONE_DELTA_H,X
	sbc	note_a+NOTE_TONE_SLIDING_H,X
	bpl	no_need

	; a->tone_slide_step = -a->tone_slide_step;

	lda	note_a+NOTE_TONE_SLIDE_STEP_H,X
	eor	#$ff
	sta	note_a+NOTE_TONE_SLIDE_STEP_H,X
	lda	note_a+NOTE_TONE_SLIDE_STEP_L,X
	eor	#$ff
	clc
	adc	#$1
	sta	note_a+NOTE_TONE_SLIDE_STEP_L,X
	lda	note_a+NOTE_TONE_SLIDE_STEP_H,X
	adc	#$0
	sta	note_a+NOTE_TONE_SLIDE_STEP_H,X

no_need:

	jmp	no_effect

	;==============================
	; Effect #3 -- Sample Position
	;==============================
effect_3:
	cmp	#$3
	bne	effect_4

	lda	(PATTERN_L),Y	; load byte, set as sample position
	iny
	sta	note_a+NOTE_SAMPLE_POSITION,X

	jmp	no_effect

	;==============================
	; Effect #4 -- Ornament Position
	;==============================
effect_4:
	cmp	#$4
	bne	effect_5

	lda	(PATTERN_L),Y	; load byte, set as ornament position
	iny
	sta	note_a+NOTE_ORNAMENT_POSITION,X

	jmp	no_effect

	;==============================
	; Effect #5 -- Vibrato
	;==============================
effect_5:
	cmp	#$5
	bne	effect_8

	lda	(PATTERN_L),Y	; load byte, set as onoff delay
	iny
	sta	note_a+NOTE_ONOFF_DELAY,X
	sta	note_a+NOTE_ONOFF,X

	lda	(PATTERN_L),Y	; load byte, set as offon delay
	iny
	sta	note_a+NOTE_OFFON_DELAY,X

	lda	#0
	sta	note_a+NOTE_TONE_SLIDE_COUNT,X
	sta	note_a+NOTE_TONE_SLIDING_L,X
	sta	note_a+NOTE_TONE_SLIDING_H,X

	jmp	no_effect

	;==============================
	; Effect #8 -- Envelope Down
	;==============================
effect_8:
	cmp	#$8
	bne	effect_9

	; delay
	lda	(PATTERN_L),Y	; load byte, set as speed
	iny
	sta	pt3_envelope_delay
	sta	pt3_envelope_delay_orig

	; low value
	lda	(PATTERN_L),Y	; load byte, set as low
	iny
	sta	pt3_envelope_slide_add_l

	; high value
	lda	(PATTERN_L),Y	; load byte, set as high
	iny
	sta	pt3_envelope_slide_add_h

	jmp	no_effect

	;==============================
	; Effect #9 -- Set Speed
	;==============================
effect_9:
	cmp	#$9
	bne	no_effect

	lda	(PATTERN_L),Y	; load byte, set as speed
	iny
	sta	pt3_speed

no_effect:

	;================================
	; add y into the address pointer

	clc
	tya
	adc	note_a+NOTE_ADDR_L,X
	sta	note_a+NOTE_ADDR_L,X
	lda	#0
	adc	note_a+NOTE_ADDR_H,X
	sta	note_a+NOTE_ADDR_H,X
	sta	PATTERN_H

	rts


	;=======================================
	; Set Envelope
	;=======================================
	; pulls out common code from $1X and $BX
	;	commands

	; A = new envelope type

set_envelope:

	sta	pt3_envelope_type					; 4

;	give fake old to force update?  maybe only needed if printing?
;	pt3->envelope_type_old=0x78;

	lda	#$78							; 2
	sta	pt3_envelope_type_old					; 4

	; get next byte
	iny								; 2
	lda	(PATTERN_L),Y						; 5+
	sta	pt3_envelope_period_h					; 4

	iny								; 2
	lda	(PATTERN_L),Y						; 5+
	sta	pt3_envelope_period_l					; 4

	lda	#0							; 2
	sta	note_a+NOTE_ORNAMENT_POSITION,X	; ornament_position=0	; 5
	sta	pt3_envelope_delay		; envelope_delay=0	; 4
	sta	pt3_envelope_slide_l		; envelope_slide=0	; 4
	sta	pt3_envelope_slide_h					; 4
	lda	#1							; 2
	sta	note_a+NOTE_ENVELOPE_ENABLED,X	; envelope_enabled=1	; 5

	rts								; 6
								;===========
								;	64

	;========================
	; reset note
	;========================
	; common code from the decode note code

reset_note:
	lda	#0							; 2
	sta	note_a+NOTE_SAMPLE_POSITION,X	; sample_position=0	; 5
	sta	note_a+NOTE_AMPLITUDE_SLIDING,X	; amplitude_sliding=0	; 5
	sta	note_a+NOTE_NOISE_SLIDING,X	; noise_sliding=0	; 5
	sta	note_a+NOTE_ENVELOPE_SLIDING,X	; envelope_sliding=0	; 5
	sta	note_a+NOTE_ORNAMENT_POSITION,X	; ornament_position=0	; 5
	sta	note_a+NOTE_TONE_SLIDE_COUNT,X	; tone_slide_count=0	; 5
	sta	note_a+NOTE_TONE_SLIDING_L,X	; tone_sliding=0	; 5
	sta	note_a+NOTE_TONE_SLIDING_H,X				; 5
	sta	note_a+NOTE_TONE_ACCUMULATOR_L,X ; tone_accumulator=0	; 5
	sta	note_a+NOTE_TONE_ACCUMULATOR_H,X			; 5
	sta	note_a+NOTE_ONOFF,X		; onoff=0;		; 5

	lda	#1							; 2
	sta	decode_done			; decode_done=1		; 4

	rts								; 6
								;============
								;	69




	;=====================================
	; Decode Line
	;=====================================

pt3_decode_line:
	; decode_note(&pt3->a,&(pt3->a_addr),pt3);
	ldx	#(NOTE_STRUCT_SIZE*0)
	jsr	decode_note

	; decode_note(&pt3->b,&(pt3->b_addr),pt3);
	ldx	#(NOTE_STRUCT_SIZE*1)
	jsr	decode_note

	; decode_note(&pt3->c,&(pt3->c_addr),pt3);
	ldx	#(NOTE_STRUCT_SIZE*2)
	jsr	decode_note

;	if (pt3->a.all_done && pt3->b.all_done && pt3->c.all_done) {
;		return 1;
;	}

	rts


current_subframe:	.byte	$0
current_line:		.byte	$0
current_pattern:	.byte	$0

	;=====================================
	; Set Pattern
	;=====================================
	; FIXME: inline this?  we do call it from outside
	;	in the player note length code

pt3_set_pattern:

	; Lookup current pattern in pattern table
	ldy	current_pattern						; 4
	lda	PT3_LOC+PT3_PATTERN_TABLE,Y				; 4+

	; if value is $FF we are at the end of the song
	cmp	#$ff							; 2
	bne	not_done						; 2/3

	; done with song, set it to non-zero
	sta	DONE_SONG						; 3
	rts								; 6
								;============
								;   21 if end

not_done:

	; set up the three pattern address pointers

	asl		; mul pattern offset by two, as word sized	; 2
	tay								; 2

	; point PATTERN_H/PATTERN_L to the pattern address table

	clc								; 2
	lda	PT3_LOC+PT3_PATTERN_LOC_L				; 4
	sta	PATTERN_L						; 3
	lda	PT3_LOC+PT3_PATTERN_LOC_H				; 4
	adc	#>PT3_LOC		; assume page boundary		; 2
	sta	PATTERN_H						; 3

	; First 16-bits points to the Channel A address
	lda	(PATTERN_L),Y						; 5+
	sta	note_a+NOTE_ADDR_L					; 4
	iny								; 2
	clc					; needed?		; 2
	lda	(PATTERN_L),Y						; 5+
	adc	#>PT3_LOC		; assume page boundary		; 2
	sta	note_a+NOTE_ADDR_H					; 4
	iny								; 2

	; Next 16-bits points to the Channel B address
	lda	(PATTERN_L),Y						; 5+
	sta	note_b+NOTE_ADDR_L					; 4
	iny								; 2
	lda	(PATTERN_L),Y						; 5+
	adc	#>PT3_LOC		; assume page boundary		; 2
	sta	note_b+NOTE_ADDR_H					; 4
	iny								; 2

	; Next 16-bits points to the Channel C address
	lda	(PATTERN_L),Y						; 5+
	sta	note_c+NOTE_ADDR_L					; 4
	iny								; 2
	lda	(PATTERN_L),Y						; 5+
	adc	#>PT3_LOC		; assume page boundary		; 2
	sta	note_c+NOTE_ADDR_H					; 4

	; clear out the noise channel
	lda	#0							; 2
	sta	pt3_noise_period					; 4

	; Set all three channels as active
	; FIXME: num_channels, may need to be 6 if doing 6-channel pt3?
	lda	#3							; 2
	sta	pt3_pattern_done					; 4

	rts								; 6



	;=====================================
	; pt3 make frame
	;=====================================
	; update pattern or line if necessary
	; then calculate the values for the next frame


pt3_make_frame:

	; see if we need a new pattern
	; we do if line==0 and subframe==0
	lda	current_line						; 4
	bne	pattern_good						; 2/3
	lda	current_subframe					; 4
	bne	pattern_good						; 2/3

	; load a new pattern in
	jsr	pt3_set_pattern						;6+?

	lda	DONE_SONG						; 3
	beq	pattern_good						; 2/3
	rts								; 6

pattern_good:

	; see if we need a new line

	lda	current_subframe					; 4
	bne	line_good						; 2/3

	; decode a new line
	jsr	pt3_decode_line						; 6+?

	; check if pattern done early
	lda	pt3_pattern_done					; 4
	bne	line_good						; 2/3

	;==========================
	; pattern done early!

	inc	current_pattern		; increment pattern		; 6
	lda	#0							; 2
	sta	current_line						; 4
	sta	current_subframe					; 4
	jmp	pt3_make_frame						; 3

line_good:

	; Increment everything

	inc	current_subframe	; subframe++			; 6
	lda	current_subframe					; 4

	; if we hit pt3_speed, move to next
	cmp	pt3_speed						; 4
	bne	do_frame						; 2/3

next_line:
	lda	#0			; reset subframe to 0		; 2
	sta	current_subframe					; 4

	inc	current_line		; and increment line		; 6
	lda	current_line						; 4

	cmp	#64			; always end at 64.		; 2
	bne	do_frame		; is this always needed?	; 2/3

next_pattern:
	lda	#0			; reset line to 0		; 2
	sta	current_line						; 4

	inc	current_pattern		; increment pattern		; 6

do_frame:
	; AY-3-8910 register summary
	;
	; R0/R1 = A period low/high
	; R2/R3 = B period low/high
	; R4/R5 = C period low/high
	; R6 = Noise period
	; R7 = Enable XX Noise=!CBA Tone=!CBA
	; R8/R9/R10 = Channel A/B/C amplitude M3210, M=envelope enable
	; R11/R12 = Envelope Period low/high
	; R13 = Envelope Shape, 0xff means don't write
	; R14/R15 = I/O (ignored)

	lda	#0							; 2
	sta	pt3_mixer_value						; 4
	sta	pt3_envelope_add					; 4

	ldx	#(NOTE_STRUCT_SIZE*0)	; Note A			; 2
	jsr	calculate_note						; 6+?
	ldx	#(NOTE_STRUCT_SIZE*1)	; Note B			; 2
	jsr	calculate_note						; 6+?
	ldx	#(NOTE_STRUCT_SIZE*2)	; Note C			; 2
	jsr	calculate_note						; 6+?

	; Load up the Frequency Registers

	lda	note_a+NOTE_TONE_L	; Note A Period L		; 4
	sta	AY_REGISTERS+0		; into R0			; 3
	lda	note_a+NOTE_TONE_H	; Note A Period H		; 4
	sta	AY_REGISTERS+1		; into R1			; 3

	; FIXME: make this self-modifying?

	lda	convert_177						; 4
	beq	no_scale_a						; 2/3

	; Convert from 1.77MHz to 1MHz by multiplying by 9/16

	; conversion costs 100 cycles!

	; first multiply by 8
	asl	AY_REGISTERS+0						; 5
	rol	AY_REGISTERS+1						; 5
	asl	AY_REGISTERS+0						; 5
	rol	AY_REGISTERS+1						; 5
	asl	AY_REGISTERS+0						; 5
	rol	AY_REGISTERS+1						; 5

	; add in original to get 9
	clc								; 2
	lda	note_a+NOTE_TONE_L					; 4
	adc	AY_REGISTERS+0						; 3
	sta	AY_REGISTERS+0						; 3
	lda	note_a+NOTE_TONE_H					; 4
	adc	AY_REGISTERS+1						; 3
	sta	AY_REGISTERS+1						; 3

	; divide by 16 to get proper value
	ror	AY_REGISTERS+1						; 5
	ror	AY_REGISTERS+0						; 5
	ror	AY_REGISTERS+1						; 5
	ror	AY_REGISTERS+0						; 5
	ror	AY_REGISTERS+1						; 5
	ror	AY_REGISTERS+0						; 5
	ror	AY_REGISTERS+1						; 5
	ror	AY_REGISTERS+0						; 5
	lda	AY_REGISTERS+1						; 3
	and	#$0f							; 2
	sta	AY_REGISTERS+1						; 3

no_scale_a:

	lda	note_b+NOTE_TONE_L	; Note B Period L		; 4
	sta	AY_REGISTERS+2		; into R2			; 3
	lda	note_b+NOTE_TONE_H	; Note B Period H		; 4
	sta	AY_REGISTERS+3		; into R3			; 3

	lda	convert_177						; 4
	beq	no_scale_b						; 2/3

	; Convert from 1.77MHz to 1MHz by multiplying by 9/16

	; first multiply by 8
	asl	AY_REGISTERS+2						; 5
	rol	AY_REGISTERS+3						; 5
	asl	AY_REGISTERS+2						; 5
	rol	AY_REGISTERS+3						; 5
	asl	AY_REGISTERS+2						; 5
	rol	AY_REGISTERS+3						; 5

	; add in original to get 9
	clc								; 2
	lda	note_b+NOTE_TONE_L					; 4
	adc	AY_REGISTERS+2						; 3
	sta	AY_REGISTERS+2						; 3
	lda	note_b+NOTE_TONE_H					; 4
	adc	AY_REGISTERS+3						; 3
	sta	AY_REGISTERS+3						; 3

	; divide by 16 to get proper value
	ror	AY_REGISTERS+3						; 5
	ror	AY_REGISTERS+2						; 5
	ror	AY_REGISTERS+3						; 5
	ror	AY_REGISTERS+2						; 5
	ror	AY_REGISTERS+3						; 5
	ror	AY_REGISTERS+2						; 5
	ror	AY_REGISTERS+3						; 5
	ror	AY_REGISTERS+2						; 5
	lda	AY_REGISTERS+3						; 3
	and	#$0f							; 2
	sta	AY_REGISTERS+3						; 3

no_scale_b:

	lda	note_c+NOTE_TONE_L	; Note C Period L		; 4
	sta	AY_REGISTERS+4		; into R4			; 3
	lda	note_c+NOTE_TONE_H	; Note C Period H		; 4
	sta	AY_REGISTERS+5		; into R5			; 3

	lda	convert_177						; 4
	beq	no_scale_c						; 2/3

	; Convert from 1.77MHz to 1MHz by multiplying by 9/16

	; first multiply by 8
	asl	AY_REGISTERS+4						; 5
	rol	AY_REGISTERS+5						; 5
	asl	AY_REGISTERS+4						; 5
	rol	AY_REGISTERS+5						; 5
	asl	AY_REGISTERS+4						; 5
	rol	AY_REGISTERS+5						; 5

	; add in original to get 9
	clc								; 2
	lda	note_c+NOTE_TONE_L					; 4
	adc	AY_REGISTERS+4						; 3
	sta	AY_REGISTERS+4						; 3
	lda	note_c+NOTE_TONE_H					; 4
	adc	AY_REGISTERS+5						; 3
	sta	AY_REGISTERS+5						; 3

	; divide by 16 to get proper value
	ror	AY_REGISTERS+5						; 5
	ror	AY_REGISTERS+4						; 5
	ror	AY_REGISTERS+5						; 5
	ror	AY_REGISTERS+4						; 5
	ror	AY_REGISTERS+5						; 5
	ror	AY_REGISTERS+4						; 5
	ror	AY_REGISTERS+5						; 5
	ror	AY_REGISTERS+4						; 5
	lda	AY_REGISTERS+5						; 3
	and	#$0f							; 2
	sta	AY_REGISTERS+5						; 3

no_scale_c:


	; Noise
	; frame[6]= (pt3->noise_period+pt3->noise_add)&0x1f;
	clc								; 2
	lda	pt3_noise_period					; 4
	adc	pt3_noise_add						; 4
	and	#$1f							; 2
	sta	AY_REGISTERS+6						; 3
	sta	temp_word_l						; 4

	lda	convert_177						; 3
	beq	no_scale_n						; 2/3

	; Convert from 1.77MHz to 1MHz by multiplying by 9/16

	; first multiply by 8
	asl	AY_REGISTERS+6						; 5
	asl	AY_REGISTERS+6						; 5
	asl	AY_REGISTERS+6						; 5

	; add in original to get 9
	clc								; 2
	lda	temp_word_l						; 4
	adc	AY_REGISTERS+6						; 3

	; divide by 16 to get proper value
	ror	AY_REGISTERS+6						; 5
	ror	AY_REGISTERS+6						; 5
	ror	AY_REGISTERS+6						; 5
	ror	AY_REGISTERS+6						; 5
	lda	AY_REGISTERS+6						; 3
	and	#$1f							; 2
	sta	AY_REGISTERS+6						; 3

no_scale_n:

	;=======================
	; Mixer

	lda	pt3_mixer_value						; 4
	sta	AY_REGISTERS+7						; 3

	;=======================
	; Amplitudes

	lda	note_a+NOTE_AMPLITUDE					; 4
	sta	AY_REGISTERS+8						; 3
	lda	note_b+NOTE_AMPLITUDE					; 4
	sta	AY_REGISTERS+9						; 3
	lda	note_c+NOTE_AMPLITUDE					; 4
	sta	AY_REGISTERS+10						; 3

	;======================================
	; Envelope period
	; result=period+add+slide (16-bits)
	clc								; 2
	lda	pt3_envelope_period_l					; 4
	adc	pt3_envelope_add					; 4
	sta	temp_word_l						; 4
	lda	pt3_envelope_period_h					; 4
	adc	#0							; 2
	sta	temp_word_h						; 4

	clc								; 2
	lda	pt3_envelope_slide_l					; 4
	adc	temp_word_l						; 4
	sta	temp_word_l						; 4
	sta	AY_REGISTERS+11						; 3
	lda	temp_word_h						; 4
	adc	pt3_envelope_slide_h					; 4
	sta	temp_word_h						; 4
	sta	AY_REGISTERS+12						; 3

	lda	convert_177						; 4
	beq	no_scale_e						; 2/3

	; Convert from 1.77MHz to 1MHz by multiplying by 9/16

	; first multiply by 8
	asl	AY_REGISTERS+11						; 5
	rol	AY_REGISTERS+12						; 5
	asl	AY_REGISTERS+11						; 5
	rol	AY_REGISTERS+12						; 5
	asl	AY_REGISTERS+11						; 5
	rol	AY_REGISTERS+12						; 5

	; add in original to get 9
	clc								; 2
	lda	temp_word_l						; 4
	adc	AY_REGISTERS+11						; 3
	sta	AY_REGISTERS+11						; 3
	lda	temp_word_h						; 4
	adc	AY_REGISTERS+12						; 3
	sta	AY_REGISTERS+12						; 3

	; divide by 16 to get proper value
	ror	AY_REGISTERS+12						; 5
	ror	AY_REGISTERS+11						; 5
	ror	AY_REGISTERS+12						; 5
	ror	AY_REGISTERS+11						; 5
	ror	AY_REGISTERS+12						; 5
	ror	AY_REGISTERS+11						; 5
	ror	AY_REGISTERS+12						; 5
	ror	AY_REGISTERS+11						; 5
	lda	AY_REGISTERS+12						; 3
	and	#$0f							; 2
	sta	AY_REGISTERS+12						; 3

no_scale_e:

	;========================
	; Envelope shape

	lda	pt3_envelope_type					; 4
	cmp	pt3_envelope_type_old					; 4
	bne	envelope_diff						; 2/3
envelope_same:
	lda	#$ff			; if same, store $ff		; 2
envelope_diff:
	sta	AY_REGISTERS+13						; 3

	lda	pt3_envelope_type					; 4
	sta	pt3_envelope_type_old	; copy old to new		; 4



	;==============================
	; end-of-frame envelope update
	;==============================

	lda	pt3_envelope_delay					; 4
	beq	done_do_frame		; assume can't be negative?	; 2/3
					; do this if envelope_delay>0
	dec	pt3_envelope_delay					; 6
	bne	done_do_frame						; 2/3
					; only do if we hit 0
	lda	pt3_envelope_delay_orig	; reset envelope delay		; 4
	sta	pt3_envelope_delay					; 4

	clc				; 16-bit add			; 2
	lda	pt3_envelope_slide_l					; 4
	adc	pt3_envelope_slide_add_l				; 4
	sta	pt3_envelope_slide_l					; 4
	lda	pt3_envelope_slide_h					; 4
	adc	pt3_envelope_slide_add_h				; 4
	sta	pt3_envelope_slide_h					; 4

done_do_frame:

	rts								; 6

	;======================================
	; GetNoteFreq
	;======================================
	; Return frequency from lookup table
	; Which note is in A
	; return in freq_l/freq_h

	; FIXME: self modify code
GetNoteFreq:

	sty	ysave							; 4

	tay								; 2
	lda	PT3_LOC+PT3_HEADER_FREQUENCY				; 4
	cmp	#1							; 2
	bne	freq_table_2						; 2/3

	lda	PT3NoteTable_ST_high,Y					; 4+
	sta	freq_h							; 4
	lda	PT3NoteTable_ST_low,Y					; 4+
	sta	freq_l							; 4

	ldy	ysave							; 4
	rts								; 6
								;===========
								;	40


freq_table_2:
	lda	PT3NoteTable_ASM_34_35_high,Y				; 4+
	sta	freq_h							; 4
	lda	PT3NoteTable_ASM_34_35_low,Y				; 4+
	sta	freq_l							; 4

	ldy	ysave							; 4
        rts								; 6
								;===========
								;	41


; Table #1 of Pro Tracker 3.3x - 3.5x
PT3NoteTable_ST_high:
.byte $0E,$0E,$0D,$0C,$0B,$0B,$0A,$09
.byte $09,$08,$08,$07,$07,$07,$06,$06
.byte $05,$05,$05,$04,$04,$04,$04,$03
.byte $03,$03,$03,$03,$02,$02,$02,$02
.byte $02,$02,$02,$01,$01,$01,$01,$01
.byte $01,$01,$01,$01,$01,$01,$01,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

PT3NoteTable_ST_low:
.byte $F8,$10,$60,$80,$D8,$28,$88,$F0
.byte $60,$E0,$58,$E0,$7C,$08,$B0,$40
.byte $EC,$94,$44,$F8,$B0,$70,$2C,$FD
.byte $BE,$84,$58,$20,$F6,$CA,$A2,$7C
.byte $58,$38,$16,$F8,$DF,$C2,$AC,$90
.byte $7B,$65,$51,$3E,$2C,$1C,$0A,$FC
.byte $EF,$E1,$D6,$C8,$BD,$B2,$A8,$9F
.byte $96,$8E,$85,$7E,$77,$70,$6B,$64
.byte $5E,$59,$54,$4F,$4B,$47,$42,$3F
.byte $3B,$38,$35,$32,$2F,$2C,$2A,$27
.byte $25,$23,$21,$1F,$1D,$1C,$1A,$19
.byte $17,$16,$15,$13,$12,$11,$10,$0F


; Table #2 of Pro Tracker 3.4x - 3.5x
PT3NoteTable_ASM_34_35_high:
.byte $0D,$0C,$0B,$0A,$0A,$09,$09,$08
.byte $08,$07,$07,$06,$06,$06,$05,$05
.byte $05,$04,$04,$04,$04,$03,$03,$03
.byte $03,$03,$02,$02,$02,$02,$02,$02
.byte $02,$01,$01,$01,$01,$01,$01,$01
.byte $01,$01,$01,$01,$01,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

PT3NoteTable_ASM_34_35_low:
.byte $10,$55,$A4,$FC,$5F,$CA,$3D,$B8
.byte $3B,$C5,$55,$EC,$88,$2A,$D2,$7E
.byte $2F,$E5,$9E,$5C,$1D,$E2,$AB,$76
.byte $44,$15,$E9,$BF,$98,$72,$4F,$2E
.byte $0F,$F1,$D5,$BB,$A2,$8B,$74,$60
.byte $4C,$39,$28,$17,$07,$F9,$EB,$DD
.byte $D1,$C5,$BA,$B0,$A6,$9D,$94,$8C
.byte $84,$7C,$75,$6F,$69,$63,$5D,$58
.byte $53,$4E,$4A,$46,$42,$3E,$3B,$37
.byte $34,$31,$2F,$2C,$29,$27,$25,$23
.byte $21,$1F,$1D,$1C,$1A,$19,$17,$16
.byte $15,$14,$12,$11,$10,$0F,$0E,$0D


;PT3VolumeTable_33_34:
;.byte $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
;.byte $0,$0,$0,$0,$0,$0,$0,$0,$1,$1,$1,$1,$1,$1,$1,$1
;.byte $0,$0,$0,$0,$0,$0,$1,$1,$1,$1,$1,$2,$2,$2,$2,$2
;.byte $0,$0,$0,$0,$1,$1,$1,$1,$2,$2,$2,$2,$3,$3,$3,$3
;.byte $0,$0,$0,$0,$1,$1,$1,$2,$2,$2,$3,$3,$3,$4,$4,$4
;.byte $0,$0,$0,$1,$1,$1,$2,$2,$3,$3,$3,$4,$4,$4,$5,$5
;.byte $0,$0,$0,$1,$1,$2,$2,$3,$3,$3,$4,$4,$5,$5,$6,$6
;.byte $0,$0,$1,$1,$2,$2,$3,$3,$4,$4,$5,$5,$6,$6,$7,$7
;.byte $0,$0,$1,$1,$2,$2,$3,$3,$4,$5,$5,$6,$6,$7,$7,$8
;.byte $0,$0,$1,$1,$2,$3,$3,$4,$5,$5,$6,$6,$7,$8,$8,$9
;.byte $0,$0,$1,$2,$2,$3,$4,$4,$5,$6,$6,$7,$8,$8,$9,$A
;.byte $0,$0,$1,$2,$3,$3,$4,$5,$6,$6,$7,$8,$9,$9,$A,$B
;.byte $0,$0,$1,$2,$3,$4,$4,$5,$6,$7,$8,$8,$9,$A,$B,$C
;.byte $0,$0,$1,$2,$3,$4,$5,$6,$7,$7,$8,$9,$A,$B,$C,$D
;.byte $0,$0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$A,$B,$C,$D,$E
;.byte $0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$A,$B,$C,$D,$E,$F

;PT3VolumeTable_35:
;.byte $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
;.byte $0,$0,$0,$0,$0,$0,$0,$0,$1,$1,$1,$1,$1,$1,$1,$1
;.byte $0,$0,$0,$0,$1,$1,$1,$1,$1,$1,$1,$1,$2,$2,$2,$2
;.byte $0,$0,$0,$1,$1,$1,$1,$1,$2,$2,$2,$2,$2,$3,$3,$3
;.byte $0,$0,$1,$1,$1,$1,$2,$2,$2,$2,$3,$3,$3,$3,$4,$4
;.byte $0,$0,$1,$1,$1,$2,$2,$2,$3,$3,$3,$4,$4,$4,$5,$5
;.byte $0,$0,$1,$1,$2,$2,$2,$3,$3,$4,$4,$4,$5,$5,$6,$6
;.byte $0,$0,$1,$1,$2,$2,$3,$3,$4,$4,$5,$5,$6,$6,$7,$7
;.byte $0,$1,$1,$2,$2,$3,$3,$4,$4,$5,$5,$6,$6,$7,$7,$8
;.byte $0,$1,$1,$2,$2,$3,$4,$4,$5,$5,$6,$7,$7,$8,$8,$9
;.byte $0,$1,$1,$2,$3,$3,$4,$5,$5,$6,$7,$7,$8,$9,$9,$A
;.byte $0,$1,$1,$2,$3,$4,$4,$5,$6,$7,$7,$8,$9,$A,$A,$B
;.byte $0,$1,$2,$2,$3,$4,$5,$6,$6,$7,$8,$9,$A,$A,$B,$C
;.byte $0,$1,$2,$3,$3,$4,$5,$6,$7,$8,$9,$A,$A,$B,$C,$D
;.byte $0,$1,$2,$3,$4,$5,$6,$7,$7,$8,$9,$A,$B,$C,$D,$E
;.byte $0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$A,$B,$C,$D,$E,$F



	;==========================
	; VolTableCreator
	;==========================
	; Creates the appropriate volume table
	; based on z80 code by Ivan Roshin ZXAYHOBETA/VTII10bG.asm
	;

	; Called with carry==0 for 3.3/3.4 table
	; Called with carry==1 for 3.5 table

	; 177f-1932 = 435 bytes, not that much better than 512 of lookup


z80_h:	.byte $0
z80_l:	.byte $0
z80_d:	.byte $0
z80_e:	.byte $0

VolTableCreator:

	; Init initial variables
	lda	#$0
	sta	z80_h
	sta	z80_d
	sta	z80_e
	lda	#$11
	sta	z80_l

	; Set up self modify

	lda	#$2A		; ROL for self-modify
	bcs	vol_type_35

vol_type_33:

	; For older table, we set initial conditions a bit
	; different

	lda	#$10
	sta	z80_l		; l=16
	sta	z80_e		; e=16

	lda	#$ea		; NOP for self modify

vol_type_35:
	sta	vol_smc		; set the self-modify code

	ldy	#16		; skip first row, all zeros
	ldx	#16		; c=16
vol_outer:
	lda	z80_h
	pha
	lda	z80_l
	pha			; save HL

	clc			; add HL,DE
	lda	z80_l
	adc	z80_e
	sta	z80_l
	lda	z80_h
	adc	z80_d
	sta	z80_h		; carry is important

	lda	z80_h		; ex de,hl             ; swap
	pha
	lda	z80_l
	pha
	lda	z80_d
	sta	z80_h
	lda	z80_e
	sta	z80_l
	pla
	sta	z80_e
	pla
	sta	z80_d

			; sbc hl,hl
	bcs	vol_ffs
vol_zeros:
	lda	#0
	beq	vol_write

vol_ffs:
	lda	#$ff
vol_write:
	sta	z80_h
	sta	z80_l

vol_inner:
	lda	z80_l

vol_smc:
	nop			; nop or ROL depending

	lda	z80_h

	adc	#$0		; a=a+carry;

	sta	VolumeTable,Y
	iny

	clc			; add HL,DE
	lda	z80_l
	adc	z80_e
	sta	z80_l
	lda	z80_h
	adc	z80_d
	sta	z80_h

	inx		; inc C
	txa		; a=c
	and	#$f
	bne	vol_inner


	pla
	sta	z80_l
	pla
	sta	z80_h	; restore HL

	lda	z80_e	; a=e
	cmp	#$77
	bne	vol_m3

	inc	z80_e
	bne	vol_blah
	inc	z80_d
vol_blah:

vol_m3:
	txa			; a=c
	;bne	vol_outer
	beq	vol_done
	jmp	vol_outer

vol_done:
	rts



VolumeTable:
	.res 256,0


pt3_lib_end:
