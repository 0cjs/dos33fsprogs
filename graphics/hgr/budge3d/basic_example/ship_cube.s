;============================================================================
; Disassembly of a module generated by Bill Budge's 3-D Graphics System and
; Game Tool.
;
; The tool itself is copyright 1980 California Pacific Computer Co.  Modules
; may be marketed and sold so long as they provide a credit notice.
;
; The HRCG (code and font) is credited to Christopher Espinosa.
;===========================================================================
; Disassembly by Andy McFadden, using 6502bench SourceGen v1.6.
; Last updated 2020/03/11
;
; The manual refers to "points" and "lines" rather than "vertices" and
; "edges".  For consistency the same nomenclature is used here.
;
; Two shapes are defined: the space shuttle model from the manual, and a
; simple cube 11 units on a side.  The module is configured for XOR drawing,
; Applesoft BASIC interface, and includes the hi-res character generator.
;
; This makes extensive use of self-modifying code.  Labels that begin with an
; underscore indicate self-modification targets.
;===========================================================================
; Code interacts with the module by setting values in arrays and calling known
; entry points.  The basic setup for Applesoft BASIC is:
;
;  1  DIM CODE%(15), X%(15), Y%(15), SCALE%(15), XROT%(15), YROT%(15),
; ZROT%(15), SX%(15), SY%(15)
;  2 RESET% = 7932:CLR% = 7951:HIRES% = 7983:CRNCH% = 7737:TXTGEN% = 768
;
; You can define up to 16 shapes.  Their parameters are stored in the various
; arrays:
;
; CODE%(n): 0 (do nothing), 1 (transform & draw), 2 (erase previous,
; transform, draw new), 3 (erase).
;   X%(n): X coordinate of center (0-255).
;   Y%(n): Y coordinate of center (0-191).
;   SCALE%(n): scale factor, 0-15.  15 is full size, 0 is 1/16th.
;   XROT%(n): rotation about X axis, 0-27.  0 is no rotation, 27 is just shy
; of 360 degrees.
;   YROT%(n): rotation about Y axis.
;   ZROT%(n): rotation about Z axis.
;   SX%(n): (output) X coordinate of last point drawn.
;   SY%(n): (output) Y coordinate of last point drawn.
;
; The code entry points are:
;   RESET%: initializes graphics module, clears the screen, switches display
; to primary hi-res page.
;   CLR%: clears both hi-res screens and switches to primary hi-res page.
;   HIRES%: turns on primary hi-res page.
;   CRNCH%: primary animation function.
;
; The "CRUNCH" function:
;  - erases objects whose CODE value is 2 or 3
;  - computes new transformations for objects whose CODE value is 1 or 2
;  - draws objects whose CODE value is 1 or 2
;  - flips the display to the other page
;
; When configured for Integer BASIC, some of the array management is simpler,
; and an additional "missile" facility is available.
;
; When configured for use with assembly language, the various arrays live at
; fixed offsets starting around $6000.
;============================================================================

.include "zp.inc"

.include "hardware.inc"

; org  $0300

.include "hgr_textgen.s"

;===========================================================
; If configured without the HRCG, the module starts here.  *
;===========================================================

;===========================================================
; Note that all tables are page-aligned for performance.   *
;===========================================================

.include "shapes.s"

;
; These four buffers hold transformed points in screen coordinates.  The points
; are in the same order as they are in the mesh definition.
;
; One pair of tables holds the X/Y screen coordinates from the previous frame,
; the other pair of tables holds the coordinates being transformed for the
; current frame.  We need two sets because we're display set 0 while generating
; set 1, and after we flip we need to use set 0 again to erase the display.
;
; ----------
;
; Computed X coordinate, set 0.
XCoord0_0E:		; 0e00
	.byte $00
	.align $100

; Computed Y coordinate, set 0.
YCoord0_0F:		; 0f00
	.byte $00
	.align $100

; Computed X coordinate, set 1.
XCoord1_10:		; 1000
	.byte $00
	.align $100

; Computed Y coordinate, set 1.
YCoord1_11:		; 1100
	.byte $00
	.align $100

.include "math_constants.s"

.include "hgr_tables.s"

.include "scale_constants.s"

;
; Draw a list of lines using exclusive-or, which inverts the pixels.  Drawing
; the same thing twice erases it.
;
; On entry:
;  $45 - index of first line
;  $46 - index of last line
;  XCoord_0E/YCoord_0F or XCoord_10/YCoord_11 have transformed points in screen
; coordinates
;
; When the module is configured for OR-mode drawing, this code is replaced with
; a dedicated erase function.  The erase code is nearly identical to the draw
; code, but saves a little time by simply zeroing out whole bytes instead of
; doing a read-modify-write.
;

; Clear variables

DrawLineListEOR:
	ldx	FIRST_LINE	; 3  start with the first line in this object
DrawLoop:
	lda	LineStartPoint,X; 4+ get X0,Y0
	tay			; 2
_0E_or_10_1:
	lda	XCoord0_0E,Y	; 4+ the instructions here are modified to load from
	sta	XSTART		; 3   the appropriate set of X/Y coordinate tables
_0F_or_11_1:
	lda	YCoord0_0F,Y	; 4+
	sta	YSTART		; 3
	lda	LineEndPoint,X	; 4+ get X1,Y1
	tay			; 2
_0E_or_10_2:
	lda	XCoord0_0E,Y	; 4+
	sta	XEND		; 3
_0F_or_11_2:
	lda	YCoord0_0F,Y	; 4+
	sta	YEND		; 3
	stx	LINE_INDEX	; 3  save this off

; Prep the line draw code.  We need to compute deltaX/deltaY, and set a register
; increment / decrement / no-op instruction depending on which way the line is
; going.

	lda	XSTART		; 3  compute delta X
	sec			; 2
	sbc	XEND		; 3
	bcs	L1A2F		; 2+ left to right
	eor	#$ff		; 2  right to left; invert value
	adc	#$01		; 2
	ldy	#OpINX		; 2
	bne	GotDeltaX	; 3

L1A2F:
	beq	IsVertical	; 2+ branch if deltaX=0
	ldy	#OpDEX		; 2
	bne	GotDeltaX	; 3

IsVertical:
	ldy	#OpNOP		; 2  fully vertical, use no-op
GotDeltaX:
	sta	DELTA_X		; 3
	sty	_InxDexNop1	; 4
	sty	_InxDexNop2	; 4
	lda	YSTART		; 3  compute delta Y
	sec			; 2
	sbc	YEND		; 3
	bcs	L1A4E		; 2+ end < start, we're good
	eor	#$ff		; 2  invert value
	adc	#$01		; 2
	ldy	#OpINY		; 2
	bne	GotDeltaY	; 3

L1A4E:
	beq	IsHorizontal	; 2+ branch if deltaY=0
	ldy	#OpDEY		; 2
	bne	GotDeltaY	; 3

IsHorizontal:
	ldy	#OpNOP		; 2  fully horizontal, use no-op
GotDeltaY:
	sta	DELTA_Y		; 3
	sty	_InyDeyNop1	; 4
	sty	_InyDeyNop2	; 4
	ldx	XSTART		; 3
	ldy	YSTART		; 3
	lda	#$00		; 2
	sta	LINE_ADJ	; 3
	lda	DELTA_X		; 3
	cmp	DELTA_Y		; 3
	bcs	HorizDomLine	; 2+

; Line draw: vertically dominant (move vertically every step)
;
; On entry: X=xpos, Y=ypos

VertDomLine:
	cpy	YEND		; 3
	beq	LineDone	; 2+
_InyDeyNop1:
	nop			; 2  self-mod INY/DEY/NOP
	lda	YTableLo,Y	; 4+ new line, update Y position
	sta	HPTR		; 3
	lda	YTableHi,Y	; 4+
	ora	HPAGE		; 3
	sta	HPTR+1		; 3
	lda	LINE_ADJ	; 3  Bresenham update
	clc			; 2
	adc	DELTA_X		; 3
	cmp	DELTA_Y		; 3
	bcs	NewColumn	; 2+
	sta	LINE_ADJ	; 3
	bcc	SameColumn	; 3

NewColumn:
	sbc	DELTA_Y		; 3
	sta	LINE_ADJ	; 3
_InxDexNop1:
	nop			;2  self-mod INX/DEX/NOP
SameColumn:
	sty	YSAVE		; 3
	ldy	Div7Tab,X	; 4+ XOR-draw the point
	lda	(HPTR),Y	; 5+
	eor	HiResBitTab,X	; 4+
	sta	(HPTR),Y	; 6
	ldy	YSAVE		; 3
	jmp	VertDomLine	; 3

LineDone:
	ldx	LINE_INDEX	; 3
	inx			; 2
	cpx	LAST_LINE	; 3  reached end?
	beq	DrawDone	; 2+
	jmp	DrawLoop	; 3

DrawDone:
	rts			; 6

; Line draw: horizontally dominant (move horizontally every step)
;
; On entry: X=xpos, Y=ypos

HorizDomLine:
	lda	YTableLo,Y	; 4+ set up hi-res pointer
	sta	HPTR		; 3
	lda	YTableHi,Y	; 4+
	ora	HPAGE		; 3
	sta	HPTR+1		; 3
HorzLoop:
	cpx	XEND		; 3  X at end?
	beq	LineDone	; 2+ yes, finish
_InxDexNop2:
	nop			; 2
	lda	LINE_ADJ	; 3  Bresenham update
	clc			; 2
	adc	DELTA_Y		; 3
	cmp	DELTA_X		; 3
	bcs	NewRow		; 2+
	sta	LINE_ADJ	; 3
	bcc	SameRow		; 3

NewRow:
	sbc	DELTA_X		; 3
	sta	LINE_ADJ	; 3
_InyDeyNop2:
	nop			; 2
	lda	YTableLo,Y	; 4+ update Y position
	sta	HPTR		; 3
	lda	YTableHi,Y	; 4+
	ora	HPAGE		; 3
	sta	HPTR+1		; 3
SameRow:
	sty	YSAVE		; 3
	ldy	Div7Tab,X	; 4+ XOR-draw the point
	lda	(HPTR),Y	; 5+
	eor	HiResBitTab,X	; 4+
	sta	(HPTR),Y	; 6
	ldy	YSAVE		; 3
	jmp	HorzLoop	; 3

	; Draw code calls here.  Since we're configured for XOR mode, this just jumps to
	; the exclusive-or version.  If we were configured for OR mode, this would be
	; LDX $45 / LDA $0B00,X instead of a JMP.
DrawLineList:
	jmp	DrawLineListEOR		; 3

	;
	; Unused OR-mode implementation follows.
	;
	; The code is substantially similar to the exclusive-or version, so it has not
	; been annotated.
	;
.byte	$00,$0b		; ?

	tay			; 2
	lda	XCoord0_0E,Y	; 4+
	sta	XSTART		; 3
	lda	YCoord0_0F,Y	; 4+
	sta	YSTART		; 3
	lda	LineEndPoint,X	; 4+
	tay			; 2
	lda	XCoord0_0E,Y	; 4+
	sta	XEND   		; 3
	lda	YCoord0_0F,Y	; 4+
	sta	YEND		; 3
	stx	LINE_INDEX	; 3
	lda	XSTART		; 3
	sec			; 2
	sbc	XEND		; 3
	bcs	L1B1A		; 2+
	eor	#$ff		; 2
	adc	#$01		; 2
	ldy	#$e8		; 2
	bne	L1B22		; 3

L1B1A:
	beq	L1B20		; 2+
	ldy	#$ca		; 2
	bne	L1B22		; 3

L1B20:
	ldy	#$ea		; 2
L1B22:
	sta	DELTA_X		; 3
	sty	L1B79		; 4
	sty	L1BA6		; 4
	lda	YSTART		; 3
	sec			; 2
	sbc	YEND		; 3
	bcs	L1B39		; 2+
	eor	#$ff		; 2
	adc	#$01		; 2
	ldy	#$c8		; 2
	bne	L1B41		; 3

L1B39:
	beq	L1B3F		; 2+
	ldy	#$88		; 2
	bne	L1B41		; 3

L1B3F:
	ldy	#$ea		; 2
L1B41:
	sta	DELTA_Y		; 3
	sty	L1B5B		; 4
	sty	L1BB8		; 4
	ldx	XSTART		; 3
	ldy	YSTART		; 3
	lda	#$00		; 2
	sta	LINE_ADJ	; 3
	lda	DELTA_X		; 3
	cmp	DELTA_Y		; 3
	bcs	L1B96		; 2+
L1B57:
	cpy	YEND		; 3
	beq	L1B8B		; 2+
L1B5B:
	nop			; 2
	lda	YTableLo,Y	; 4+
	sta	HPTR		; 3
	lda	YTableHi,Y	; 4+
	ora	HPAGE		; 3
	sta	HPTR+1		; 3
	lda	LINE_ADJ	; 3
	clc			; 2
	adc	DELTA_X		; 3
	cmp	DELTA_Y		; 3
	bcs	L1B75		; 2+
	sta	LINE_ADJ	; 3
	bcc	L1B7A		; 3

L1B75:
	sbc	DELTA_Y		; 3
	sta	LINE_ADJ	; 3
L1B79:
	nop			; 2
L1B7A:
	sty	YSAVE		; 3
	ldy	Div7Tab,X	; 4+
	lda	(HPTR),Y	; 5+
	ora	HiResBitTab,X	; 4+
	sta	(HPTR),Y	; 6
	ldy	YSAVE		; 3
	jmp	L1B57		; 3

L1B8B:
	ldx	LINE_INDEX	; 3
	inx			; 2
	cpx	LAST_LINE	; 3
	beq	L1B95		; 2+
	jmp	DrawLineList+2	; 3

L1B95:
	rts			; 6

L1B96:
	lda	YTableLo,Y	; 4+
	sta	HPTR		; 3
	lda	YTableHi,Y	; 4+
	ora	HPAGE		; 3
	sta	HPTR+1		; 3
L1BA2:
	cpx	XEND		; 3
	beq	L1B8B		; 2+
L1BA6:
	nop			; 2
	lda	LINE_ADJ	; 3
	clc			; 2
	adc	DELTA_Y		; 3
	cmp	DELTA_X		; 3
	bcs	L1BB4		; 2+
	sta	LINE_ADJ	; 3
	bcc	L1BC5		; 3

L1BB4:
	sbc	DELTA_X		; 3
	sta	LINE_ADJ	; 3
L1BB8:
	nop			; 2
	lda	YTableLo,Y	; 4+
	sta	HPTR		; 3
	lda	YTableHi,Y	; 4+
	ora	HPAGE		; 3
	sta	HPTR+1		; 3
L1BC5:
	sty	YSAVE		; 3
	ldy	Div7Tab,X	; 4+
	lda	(HPTR),Y	; 5+
	ora	HiResBitTab,X	; 4+
	sta	(HPTR),Y	; 6
	ldy	YSAVE		; 3
	jmp	L1BA2		; 3

;
; Unreferenced function that copies untransformed mesh X/Y values into the
; screen-coordinate buffers.  Could be used for a static 2D effect, like a
; background that doesn't move.
;
	ldx	FIRST_LINE		; 3
UnusedCopyLoop:
	lda	ShapeXCoords,X		; 4+
	clc				; 2
	adc	YSTART			; 3
_unused_mod0:
	sta  XCoord0_0E,X		; 5
	lda	XEND			; 3
	sec				; 2
	sbc	ShapeYCoords,X		; 4+
_unused_mod1:
	sta	YCoord0_0F,X		; 5
	inx				; 2
	cpx	LAST_LINE		; 3
	bne	UnusedCopyLoop		; 2+
	rts				; 6

	; Current hi-res page.
	;
	; $00 = draw page 1, show page 2
	; $FF = draw page 2, show page 1
CurPage:	.byte $ff

	;
	; Switch to the other hi-res page.
	;
SwapPage:
	lda	CurPage		; 4
	eor	#$ff		; 2  flip to other page
	sta	CurPage		; 4
	beq	DrawOnPage1	; 3+
	sta	TXTPAGE1	; 4  draw on page 2, show page 1
	lda	#$40		; 2
	ldx	#>XCoord1_10	; 2
	ldy	#>YCoord1_11	; 2
	bne	L1C0F		; 3

DrawOnPage1:
	sta	TXTPAGE2	; 4  draw on page 1, show page 2
	lda	#$20		; 2
	ldx	#>XCoord0_0E	; 2
	ldy	#>YCoord0_0F	; 2

	; Save the hi-res page, and modify the instructions that read from or write data
	; to the transformed point arrays.
L1C0F:
	sta	HPAGE		; 3
	stx	_0E_or_10_1+2	; 4
	stx	_0E_or_10_2+2	; 4
	stx	_0E_or_10_3+2	; 4
	stx	_unused_mod0+2	; 4
	sty	_0F_or_11_1+2	; 4
	sty	_0F_or_11_2+2	; 4
	sty	_0F_or_11_3+2	; 4
	sty	_unused_mod1+2	; 4
	rts			; 6

; Unreferenced junk (12 bytes)
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00

; Coordinate transformation function.  Transforms all points in a single object.
;
; On entry:
;  1c = scale (00-0f)
;  1d = xc (00-ff)
;  1e = yc (00-bf)
;  1f = zrot (00-1b)
;  3c = yrot (00-1b)
;  3d = xrot (00-1b)
;  45 = index of first point to transform
;  46 = index of last point to transform
;
; Rotation values greater than $1B, and scale factors greater than $0F, disable
; the calculation.  This has the same effect as a rotation value of 0 or a scale
; of 15, but is more efficient, because this uses self-modifying code to skip
; the computation entirely.
;

; Clear variables
xc		= $19	; transformed X coordinate
yc		= $1a	; transformed Y coordinate
zc		= $1b	; transformed Z coordinate
scale		= $1c	; $00-0F, where $0F is full size
xposn		= $1d	; X coordinate (0-255)
yposn		= $1e	; Y coordinate (0-191)
zrot		= $1f	; Z rotation ($00-1B)
yrot		= $3c	; Y rotation ($00-1B)
xrot		= $3d	; X rotation ($00-1B)
rot_tmp		= $3f
out_index	= $43
first_point	= $45
last_point	= $46

CompTransform:
	ldx	first_point	; 3  get first point index; this stays in X for a while

	; Configure Z rotation.

	ldy	zrot		; 3
	cpy	#$1c		; 2  valid rotation value?
	bcc	ConfigZrot	; 2+ yes, configure
	lda	#<DoYrot	; 2  no, modify code to skip Z-rot
	sta	_BeforeZrot+1	; 4
	bne	NoZrot		; 3

ConfigZrot:
	lda	#<DoZrot		; 2
	sta	_BeforeZrot+1		; 4
	lda	RotIndexLo_sin,Y	; 4+
	sta	_zrotLS1+1		; 4
	sta	_zrotLS2+1		; 4
	lda	RotIndexHi_sin,Y	; 4+
	sta	_zrotHS1+1		; 4
	sta	_zrotHS2+1		; 4
	lda	RotIndexLo_cos,Y	; 4+
	sta	_zrotLC1+1		; 4
	sta	_zrotLC2+1		; 4
	lda	RotIndexHi_cos,Y	; 4+
	sta	_zrotHC1+1		; 4
	sta	_zrotHC2+1		; 4

; Configure Y rotation.

NoZrot:
	ldy	yrot		; 3
	cpy	#$1c		; 2  valid rotation value?
	bcc	ConfigYrot	; 2+ yes, configure
	lda	#<DoXrot	; 2  no, modify code to skip Y-rot
	sta	_BeforeYrot+1	; 4
	bne	NoYrot		; 3

ConfigYrot:
	lda	#<DoYrot		; 2
	sta	_BeforeYrot+1		; 4
	lda	RotIndexLo_sin,Y	; 4+
	sta	_yrotLS1+1		; 4
	sta	_yrotLS2+1		; 4
	lda	RotIndexHi_sin,Y	; 4+
	sta	_yrotHS1+1		; 4
	sta	_yrotHS2+1		; 4
	lda	RotIndexLo_cos,Y	; 4+
	sta	_yrotLC1+1		; 4
	sta	_yrotLC2+1		; 4
	lda	RotIndexHi_cos,Y	; 4+
	sta	_yrotHC1+1		; 4
	sta	_yrotHC2+1		; 4

; Configure X rotation.

NoYrot:
	ldy	xrot		; 3
	cpy	#$1c		; 2  valid rotation value?
	bcc	ConfigXrot	; 2+ yes, configure
	lda	#<DoScale	; 2  no, modify code to skip X-rot
	sta	_BeforeXrot+1	; 4
	bne	ConfigScale	; 3

ConfigXrot:
	lda	#<DoXrot		; 2
	sta	_BeforeXrot+1		; 4
	lda	RotIndexLo_sin,Y	; 4+
	sta	_xrotLS1+1		; 4
	sta	_xrotLS2+1		; 4
	lda	RotIndexHi_sin,Y	; 4+
	sta	_xrotHS1+1		; 4
	sta	_xrotHS2+1		; 4
	lda	RotIndexLo_cos,Y	; 4+
	sta	_xrotLC1+1		; 4
	sta	_xrotLC2+1		; 4
	lda	RotIndexHi_cos,Y	; 4+
	sta	_xrotHC1+1		; 4
	sta	_xrotHC2+1		; 4

; Configure scaling.

ConfigScale:
	ldy	scale		; 3
	cpy	#$10		; 2  valid scale value?
	bcc	SetScale	; 2+ yes, configure it
	lda	#<DoTranslate	; 2  no, skip it
	sta	_BeforeScale+1	; 4
	lda	#>DoTranslate	; 2
	sta	_BeforeScale+2	; 4
	bne	TransformLoop	; 4

SetScale:
	lda	#<DoScale	; 2
	sta	_BeforeScale+1	; 4
	lda	#>DoScale	; 2
	sta	_BeforeScale+2	; 4
	lda	ScaleIndexLo,Y	; 4+ $00, $10, $20, ... $F0
	sta	_scaleLX+1	; 4
	sta	_scaleLY+1	; 4
	lda	ScaleIndexHi,Y	; 4+ $00, $01, $02, ... $0F
	sta	_scaleHX+1	; 4
	sta	_scaleHY+1	; 4


	;
	; Now that we've got the code modified, perform the computation for all points
	; in the object.
	;
TransformLoop:
	lda	ShapeXCoords,X	; 4+
	sta	xc		; 3
	lda	ShapeYCoords,X	; 4+
	sta	yc		; 3
	lda	ShapeZCoords,X	; 4+
	sta	zc		; 3
	stx	out_index	; 3  save for later
_BeforeZrot:
	jmp	DoZrot		; 3

DoZrot:
	lda	xc		; 3  rotating about Z, so we need to update X/Y coords
	and	#$0f		; 2  split X/Y into nibbles
	sta	rot_tmp		; 3
	lda	xc		; 3
	and	#$f0		; 2
	sta	rot_tmp+1	; 3
	lda	yc		; 3
	and	#$0f		; 2
	sta	rot_tmp+2	; 3
	lda	yc		; 3
	and	#$f0		; 2
	sta	rot_tmp+3	; 3
	ldy	rot_tmp		; 3  transform X coord
	ldx	rot_tmp+1	; 3  XC = X * cos(theta) - Y * sin(theta)
_zrotLC1:
	lda	RotTabLo,Y	; 4+
	clc			; 2
_zrotHC1:
	adc	RotTabHi,X	; 4+
	ldy	rot_tmp+2	; 3
	ldx	rot_tmp+3	; 3
	sec			; 2
_zrotLS1:
	sbc	RotTabLo,Y	; 4+
	sec			; 2
_zrotHS1:
	sbc	RotTabHi,X	; 4+
	sta	xc		; 3  save updated coord
_zrotLC2:
	lda	RotTabLo,Y	; 4+ transform Y coord
	clc			; 2  YC = Y * cos(theta) + X * sin(theta)
_zrotHC2:
	adc	RotTabHi,X	; 4+
	ldy	rot_tmp		; 3
	ldx	rot_tmp+1	; 3
	clc			; 2
_zrotLS2:
	adc	RotTabLo,Y	; 4+
	clc			; 2
_zrotHS2:
	adc	RotTabHi,X	; 4+
	sta	yc		; 3  save updated coord
_BeforeYrot:
	jmp	DoYrot		; 3

DoYrot:
	lda	xc		; 3  rotating about Y, so update X/Z
	and	#$0f		; 2
	sta	rot_tmp		; 3
	lda	xc		; 3
	and	#$f0		; 2
	sta	rot_tmp+1	; 3
	lda	zc		; 3
	and	#$0f		; 2
	sta	rot_tmp+2	; 3
	lda	zc		; 3
	and	#$f0		; 2
	sta	rot_tmp+3	; 3
	ldy	rot_tmp		; 3
	ldx	rot_tmp+1	; 3
_yrotLC1:
	lda	RotTabLo,Y	; 4+
	clc			; 2
_yrotHC1:
	adc	RotTabHi,X	; 4+
	ldy	rot_tmp+2	; 3
	ldx	rot_tmp+3	; 3
	sec			; 2
_yrotLS1:
	sbc	RotTabLo,Y	; 4+
	sec			; 2
_yrotHS1:
	sbc	RotTabHi,X	; 4+
	sta	xc		; 3
_yrotLC2:
	lda	RotTabLo,Y	; 4+
	clc			; 2
_yrotHC2:
	adc	RotTabHi,X	; 4+
	ldy	rot_tmp		; 3
	ldx	rot_tmp+1	; 3
	clc			; 2
_yrotLS2:
	adc	RotTabLo,Y	; 4+
	clc			; 2
_yrotHS2:
	adc	RotTabHi,X	; 4+
	sta	zc		; 3
_BeforeXrot:
	jmp	DoXrot		; 3

DoXrot:
	lda	zc		; 3  rotating about X, so update Z/Y
	and	#$0f		; 2
	sta	rot_tmp		; 3
	lda	zc		; 3
	and	#$f0		; 2
	sta	rot_tmp+1	; 3
	lda	yc		; 3
	and	#$0f		; 2
	sta	rot_tmp+2	; 3
	lda	yc		; 3
	and	#$f0		; 2
	sta	rot_tmp+3	; 3
	ldy	rot_tmp		; 3
	ldx	rot_tmp+1	; 3
_xrotLC1:
	lda	RotTabLo,Y	; 4+
	clc			; 2
_xrotHC1:
	adc	RotTabHi,X	; 4+
	ldy	rot_tmp+2	; 3
	ldx	rot_tmp+3	; 3
	sec			; 2
_xrotLS1:
	sbc	RotTabLo,Y	; 4+
	sec			; 2
_xrotHS1:
	sbc	RotTabHi,X	; 4+
	sta	zc		; 3
_xrotLC2:
	lda	RotTabLo,Y	; 4+
	clc			; 2
_xrotHC2:
	adc	RotTabHi,X	; 4+
	ldy	rot_tmp		; 3
	ldx	rot_tmp+1	; 3
	clc			; 2
_xrotLS2:
	adc	RotTabLo,Y	; 4+
	clc			; 2
_xrotHS2:
	adc	RotTabHi,X	; 4+
	sta	yc		; 3
_BeforeScale:
	jmp	DoScale		; 3


	; Apply scaling.  Traditionally this is applied before rotation.
DoScale:
	lda	xc		; 3  scale the X coordinate
	and	#$f0		; 2
	tax			; 2
	lda	xc		; 3
	and	#$0f		; 2
	tay			; 2
_scaleLX:
	lda	ScaleTabLo,Y	; 4+
	clc			; 2
_scaleHX:
	adc	ScaleTabHi,X	; 4+
	sta	xc		; 3
	lda	yc		; 3  scale the Y coordinate
	and	#$f0		; 2
	tax			; 2
	lda	yc		; 3
	and	#$0f		; 2
	tay			; 2
_scaleLY:
	lda	ScaleTabLo,Y	; 4+
	clc			; 2
_scaleHY:
	adc	ScaleTabHi,X	; 4+
	sta	yc		; 3

	;
	; Apply translation.
	;
	; This is the final step, so the result is written to the transformed-point
	; arrays.
	;
DoTranslate:
	ldx	out_index	; 3
	lda	xc		; 3
	clc			; 2
	adc	xposn		; 3  object center in screen coordinates
_0E_or_10_3:
	sta	XCoord0_0E,X	; 5
	lda	yposn		; 3
	sec			; 2
	sbc	yc		; 3
_0F_or_11_3:
	sta	YCoord0_0F,X	; 5
	inx			; 2
	cpx	last_point	; 3  done?
	beq	TransformDone	; 2+ yes, bail
	jmp	TransformLoop	; 3

TransformDone:
	rts			; 6

SavedShapeIndex:
	.byte  $ad  ;holds shape index while we work

;*******************************************************************************
; CRUNCH/CRNCH% entry point    *
;      *
; For each object, do what CODE%(n) tells us to:    *
;      *
;  0 - do nothing    *
;  1 - transform and draw   *
;  2 - erase, transform, draw  *
;  3 - erase     *
;*******************************************************************************

;FIRST_LINE	= $45
;LAST_LINE	= $46

CRUNCH:
	jsr	Setup		; 6  find Applesoft arrays

	;==============================
	; First pass: erase old shapes
	;==============================

	lda	NumObjects	; 4  number of defined objects
	asl			; 2  * 2
	tax			; 2  use as index
ShapeLoop:
	dex			; 2
	dex			; 2
	bmi	Transform	; 2+ done
_codeAR1:
	lda	CODE_arr,X	; 4+
	cmp	#$02		; 2  2 or 3?
	bcc	ShapeLoop	; 2+ no, move on
	stx	SavedShapeIndex	; 4
	txa			; 2
	lsr			; 2
	tax			; 2
	lda	FirstLineIndex,X; 4+
	sta	FIRST_LINE	; 3
	lda	LastLineIndex,X	; 4+
	sta	LAST_LINE	; 3
	cmp	FIRST_LINE	; 3  is number of lines <= 0?
	bcc	NoLines1	; 2+
	beq	NoLines1	; 2+ yes, skip draw
	jsr	DrawLineListEOR	; 6  erase with EOR version, regardless of config
NoLines1:
	ldx	SavedShapeIndex	; 4
	bpl	ShapeLoop	; 3  ...always

	;===============================
	; Second pass: transform shapes
	;===============================
Transform:
	lda	NumObjects	; 4
	asl			; 2
	tax			; 2
TransLoop:
	dex			; 2
	dex			; 2
	bmi	DrawNew		; 2+
_codeAR2:
	lda	CODE_arr,X	; 4+
	beq	TransLoop	; 2+ is it zero or three?
	cmp	#$03		; 2
	beq	TransLoop	; 2+ yes, we only draw on 1 or 2

	; Extract the scale, X/Y, and rotation values out of the arrays and copy them to
	; zero-page locations.

_scaleAR:
	lda	SCALE_arr,X	; 4+
	sta	scale		; 3
_xAR:
	lda	X_arr,X		; 4+
	sta	xposn		; 3
_yAR:
	lda	Y_arr,X		; 4+
	sta	yposn		; 3
_zrotAR:
	lda	ZROT_arr,X	; 4+
	sta	zrot		; 3
_yrotAR:
	lda	YROT_arr,X	; 4+
	sta	yrot		; 3
_xrotAR:
	lda	XROT_arr,X	; 4+
	sta	xrot		; 3
	stx	SavedShapeIndex	; 4  save this off
	txa			; 2
	lsr			; 2  convert to 1x index
	tax			; 2
	lda	FirstPointIndex,X; 4+
	sta	FIRST_LINE	; 3  (actually first_point)
	lda	LastPointIndex,X; 4+
	sta	LAST_LINE	; 3
	cmp	FIRST_LINE	; 3  is number of points <= 0?
	bcc	NoPoints	; 2+
	beq	NoPoints	; 2+ yes, skip transform
	jsr	CompTransform	; 6  transform all points
NoPoints:
	ldx	SavedShapeIndex	; 4
	lda	xc		; 3
	clc			; 2
	adc	xposn		; 3
_sxAR:
	sta	SX_arr,X	; 5
	lda	yposn		; 3
	sec			; 2
	sbc	yc		; 3
_syAR:
	sta	SY_arr,X	; 5
	jmp	TransLoop	; 3

	;=============================
 ; Third pass: draw shapes
	;=============================

DrawNew:
	lda	NumObjects	; 4
	asl			; 2
	tax			; 2
L1ECE:
	dex			; 2
	dex			; 2
	bmi	L1EF9		; 2+
_codeAR3:
	lda	CODE_arr,X	; 4+ is it 0 or 3?
	beq	L1ECE		; 2+
	cmp	#$03		; 2
	beq	L1ECE		; 2+ yup, no draw
	stx	SavedShapeIndex	; 4  save index
	txa			; 2
	lsr			; 2  convert it back to 1x index
	tax			; 2
	lda	FirstLineIndex,X; 4+ draw all the lines in the shape
	sta	FIRST_LINE	; 3
	lda	LastLineIndex,X	; 4+
	sta	LAST_LINE	; 3
	cmp	FIRST_LINE	; 3  is number of lines <= 0?
	bcc	NoLines2	; 2+
	beq	NoLines2	; 2+ yes, skip draw
	jsr	DrawLineList	; 6  draw all lines
NoLines2:
	ldx	SavedShapeIndex	; 4
	bpl	L1ECE		; 3  ...always

L1EF9:
	jmp	SwapPage	; 3


;*******************************************************************************
; RESET entry point     *
;      *
; Zeroes out the CODE% array, erases both hi-res screens, and enables display  *
; of the primary hi-res page.  *
;*******************************************************************************

RESET:
	jsr	Setup		; 6  sets A=0, Y=$1E
_codeAR4:
	sta	CODE_arr,y	; 5  zero out CODE%
	dey			; 2
	bpl	_codeAR4	; 3+
	jsr	CLEAR		; 6
	jsr	SwapPage	; 6
	jsr	SwapPage	; 6
	rts			; 6

;*******************************************************************************
; CLEAR/CLR% entry point    *
;      *
; Clears both hi-res pages.    *
;*******************************************************************************
; Clear variables

ptr1	= $1a
ptr2	= $1c

CLEAR:
	lda	#$20		; 2  hi-res page 1
	sta	ptr1+1		; 3
	lda	#$40		; 2  hi-res page 2
	sta	ptr2+1		; 3
	ldy	#$00		; 2
	sty	ptr1		; 3
	sty	ptr2		; 3
L1F1D:
	tya			; 2
L1F1E:
	sta	(ptr1),Y	; 6  erase both pages
	sta	(ptr2),Y	; 6
	iny			; 2
	bne	L1F1E		; 2+
	inc	ptr1+1		; 5
	inc	ptr2+1		; 5
	lda	ptr1+1		; 3  (could hold counter in X-reg)
	and	#$3f		; 2
	bne	L1F1D		; 2+

;*******************************************************************************
; HIRES entry point     *
;      *
; Displays primary hi-res page.   *
;*******************************************************************************
HI_RES:
	sta	HIRES		; 4
	sta	MIXCLR		; 4
	sta	TXTCLR		; 4
	rts			; 6

; Locate Applesoft arrays.  This assumes the arrays are declared first, and in
; the correct order, so that the start can be found at a fixed offset from the
; BASIC array table pointer.
;
; 1 DIM CODE%(15), X%(15), Y%(15), SCALE%(15), XROT%(15), YROT%(15), ZROT%(15),
; SX%(15), SY%(15)
;
; If you generate the module for Integer BASIC, this is the entry point for
; MISSILE (7993).

Setup:
	lda	BAS_ARYTAB	; 3  CODE% is at +$0008
	clc			; 2
	adc	#$08		; 2
	tax			; 2
	lda	BAS_ARYTAB+1	; 3
	adc	#$00		; 2
	stx	_codeAR1+1	; 4
	sta	_codeAR1+2	; 4
	stx	_codeAR2+1	; 4
	sta	_codeAR2+2	; 4
	stx	_codeAR3+1	; 4
	sta	_codeAR3+2	; 4
	stx	_codeAR4+1	; 4
	sta	_codeAR4+2	; 4
	lda	BAS_ARYTAB	; 3  X% is at +$002F
	clc			; 2
	adc	#$2f		; 2
	tax			; 2
	lda	BAS_ARYTAB+1	; 3
	adc	#$00		; 2
	stx	_xAR+1		; 4
	sta	_xAR+2		; 4
	lda	BAS_ARYTAB	; 3  Y% is at +$0056
	clc			; 2
	adc	#$56		; 2
	tax			; 2
	lda	BAS_ARYTAB+1	; 3
	adc	#$00		; 2
	stx	_yAR+1		; 4
	sta	_yAR+2		; 4
	lda	BAS_ARYTAB	; 3  SCALE% is at + $007D
	clc			; 2
	adc	#$7d		; 2
	tax			; 2
	lda	BAS_ARYTAB+1	; 3
	adc	#$00		; 2
	stx	_scaleAR+1	; 4
	sta	_scaleAR+2	; 4
	lda	BAS_ARYTAB	; 3  XROT% is at +$00A4
	clc			; 2
	adc	#$a4		; 2
	tax			; 2
	lda	BAS_ARYTAB+1	; 3
	adc	#$00		; 2
	stx	_xrotAR+1	; 4
	sta	_xrotAR+2	; 4
	lda	BAS_ARYTAB	; 3  YROT% is at +$00CB
	clc			; 2
	adc	#$cb		; 2
	tax			; 2
	lda	BAS_ARYTAB+1	; 3
	adc  #$00		; 2
	stx	_yrotAR+1	; 4
	sta	_yrotAR+2	; 4
	lda	BAS_ARYTAB	; 3  ZROT% is at +$00F2
	clc			; 2
	adc	#$f2		; 2
	tax			; 2
	lda	BAS_ARYTAB+1	; 3
	adc	#$00		; 2
	stx	_zrotAR+1	; 4
	sta	_zrotAR+2	; 4
	lda	BAS_ARYTAB	; 3  SX% is at +$0119
	clc			; 2
	adc	#$19		; 2
	tax			; 2
	lda	BAS_ARYTAB+1	; 3
	adc	#$01		; 2
	stx	_sxAR+1		; 4
	sta	_sxAR+2		; 4
	lda	BAS_ARYTAB	; 3  SY% is at +$0140
	clc			; 2
	adc	#$40		; 2
	tax			; 2
	lda	BAS_ARYTAB+1	; 3
	adc	#$01		; 2
	stx	_syAR+1		; 4
	sta	_syAR+2		; 4
	ldy	#$1e		; 2  Set A and Y for RESET
	lda	#$00		; 2
	rts			; 6

	; Junk; pads binary to end of page.
.align  $0100

