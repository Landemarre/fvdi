













	.equiv	both,1	
	.equiv	upto8,0	

	.include		"vdi.inc.gnu"
	.include		"macros.inc.gnu"

	.global	_line
	.global	_set_pixel
	.global	_get_pixel
	.global	_expand
	.global	_fill
	.global	_fillpoly
	.global	_blit
	.global	_text
	.global	_mouse
	.global	_set_palette
	.global	_colour
	.global	_initialize_palette
	.global	get_colour_masks

*	.external	_line_draw_r
*	.external	_write_pixel_r
*	.external	_read_pixel_r
*	.external	_expand_area_r
*	.external	_fill_area_r
*	.external	_fill_poly_r
*	.external	_blit_area_r
*	.external	_text_area_r
*	.external	_mouse_draw_r
*	.external	_set_colours_r
*	.external	_get_colour_r
*	.external	_fallback_line
*	.external	_fallback_text
*	.external	_fallback_fill
*	.external	_fallback_fillpoly
*	.external	_fallback_expand
*	.external	_fallback_blit
*	.external	clip_line
*	.external	_mask


	.text

	.ascii	"set_pixel"
	.byte	0











_set_pixel:
set_pixel:
	movem.l		d0-d7/a0-a6,-(a7)	

	move.l		a0,a1

	ijsr		_write_pixel_r
	tst.l		d0
	bgt		.write_done

	tst.w		d2
	bne		.write_done		
	move.l		8*4(a7),d3		
	bclr		#0,d3
	move.l		d3,-(a7)
	move.l		4+4(a7),-(a7)		
	move.w		8+8(a7),-(a7)		
.write_loop:
	move.l		2(a7),a2
	move.w		(a2)+,d1
	move.w		(a2)+,d2
	move.l		a2,2(a7)
	move.l		6(a7),a1
	move.l		10+0(a7),d0		
	ijsr		_write_pixel_r
	subq.w		#1,(a7)
	bne		.write_loop
	add.w		#10,a7
.write_done:

	movem.l		(a7)+,d0-d7/a0-a6
	rts


	.ascii	"get_pixel"
	.byte	0










_get_pixel:
get_pixel:
	movem.l		d1-d7/a0-a6,-(a7)	

	move.l		a0,a1
	
	ijsr		_read_pixel_r

	movem.l		(a7)+,d1-d7/a0-a6
	rts


	.ascii	"line"



















_line:
line:
	movem.l		d0-d7/a0-a6,-(a7)	

	move.l		a0,a1
	exg		d0,d6

	ijsr		_line_draw_r
	tst.l		d0
	bgt	.l1___line
	bmi	.l2___line
	move.l		_fallback_line,d0
	bra		give_up

.l1___line:
	movem.l		(a7)+,d0-d7/a0-a6
	rts

.l2___line:
	move.w		8+2(a7),d0
	move.w		d3,d7
	cmp.w		#1,d0
	bhi		.line_done		
	beq		.use_marks
	moveq		#0,d7			
.use_marks:
	swap		d7
	move.w		#1,d7			
	swap		d7

	move.l		8*4(a7),d3		
	bclr		#0,d3
	move.l		d3,a1
	move.l		1*4(a7),a2		

	move.l		d4,a6
	tst.w		d7
	beq		.no_start_move
	add.w		d7,a6
	add.w		d7,a6
	subq.l		#2,a6
	cmp.w		#-4,(a6)
	bne		.no_start_movex
	subq.l		#2,a6
	subq.w		#1,d7
.no_start_movex:
	cmp.w		#-2,(a6)
	bne		.no_start_move
	subq.l		#2,a6
	subq.w		#1,d7
.no_start_move:
	bra		.loop_end
.line_loop:
	movem.w		(a2),d1-d4
	move.l		a1,a0
	bsr		clip_line
	bvs		.no_draw
	move.l		0(a7),d6		
	move.l		5*4(a7),d5		
	move.l		6*4(a7),d0		
	movem.l		d7/a1-a2/a6,-(a7)
	ijsr		_line_draw_r
	movem.l		(a7)+,d7/a1-a2/a6
.no_draw:
	tst.w		d7
	beq		.no_marks
	swap		d7
	addq.w		#1,d7
	move.w		d7,d4
	add.w		d4,d4
	subq.w		#4,d4
	cmp.w		(a6),d4
	bne		.no_move
	subq.l		#2,a6
	addq.w		#1,d7
	swap		d7
	subq.w		#1,d7
	swap		d7
	addq.l		#4,a2
	subq.w		#1,2*4(a7)
.no_move:
	swap		d7
.no_marks:
	addq.l		#4,a2
.loop_end:
	subq.w		#1,2*4(a7)
	bgt		.line_loop
.line_done:
	movem.l		(a7)+,d0-d7/a0-a6
	rts


	.ascii	"expand"













_expand:
expand:
	movem.l		d0-d7/a0-a6,-(a7)	

	move.l		a0,a1

	exg		d0,d6
	sub.w		d4,d0
	addq.w		#1,d0
	swap		d0
	move.w		d5,d0
	sub.w		d3,d0
	addq.w		#1,d0

	ijsr		_expand_area_r
	tst.l		d0
	bgt	.l1___expand
	move.l		_fallback_expand,d0
	bra		give_up

.l1___expand:
	movem.l		(a7)+,d0-d7/a0-a6
	rts


	.ascii	"fill"




















_fill:
fill:
	movem.l		d0-d7/a0-a6,-(a7)	

	move.l		a0,a1






  .ifne 0

	lea		_colour,a3
    .ifne	upto8





	move.l		d0,d5
	lsr.l		#1,d5			
	and.l		#0x00780078,d5
	swap		d5
	pea		(a3,d5.w)
	swap		d5
	move.l		(a3,d5.w),a5
	move.l		4(a3,d5.w),a6
    .endif




	and.l		#0x000f000f,d0
	lsl.l		#3,d0
	swap		d0
	pea		0(a3,d0.w)
	swap		d0
	move.l		0(a3,d0.w),a2
	move.l		4(a3,d0.w),a3
  .endif

	exg		d4,d0

	sub.w		d2,d0
	addq.w		#1,d0
	swap		d0
	move.w		d3,d0
	sub.w		d1,d0
	addq.w		#1,d0

	move.l		d5,d3

	ijsr		_fill_area_r
	tst.l		d0
	bgt	.l1___fill
	bmi	.l2___fill
  .ifne 0
    .ifeq	upto8
	addq.l		#4,a7
    .endif
    .ifne	upto8
	addq.l		#8,a7
    .endif
  .endif
	move.l		_fallback_fill,d0
	bra		give_up

.l1___fill:
  .ifne 0
    .ifeq	upto8
	addq.l		#4,a7
    .endif
    .ifne	upto8
	addq.l		#8,a7
    .endif
  .endif
	movem.l		(a7)+,d0-d7/a0-a6
	rts

.l2___fill:
	move.w		8+2(a7),d0
	tst.w		d0
	bne		.fill_done		
	move.l		8*4(a7),d3		
	bclr		#0,d3
	move.l		d3,a1
	move.l		4(a7),a2		
.fill_loop:
	moveq		#0,d2
	move.w		(a2)+,d2
	moveq		#0,d1
	move.w		(a2)+,d1
	moveq		#1,d0
	swap		d0
	move.w		(a2)+,d0
	sub.w		d1,d0
	addq.w		#1,d0
	move.l		5*4(a7),d3
	move.l		0(a7),d4
	movem.l		a1-a2,-(a7)
	ijsr		_fill_area_r
	movem.l		(a7)+,a1-a2
	subq.w		#1,2*4(a7)
	bne		.fill_loop
.fill_done:
	movem.l		(a7)+,d0-d7/a0-a6
	rts


	.ascii	"fillpoly"





















_fillpoly:
fillpoly:
	movem.l		d0-d7/a0-a6,-(a7)	

	move.l		a0,a1






  .ifne 0

	lea		_colour,a3
    .ifne	upto8





	move.l		d0,d5
	lsr.l		#1,d5			
	and.l		#0x00780078,d5
	swap		d5
	pea		(a3,d5.w)
	swap		d5
	move.l		(a3,d5.w),a5
	move.l		4(a3,d5.w),a6
    .endif




	and.l		#0x000f000f,d0
	lsl.l		#3,d0
	swap		d0
	pea		0(a3,d0.w)
	swap		d0
	move.l		0(a3,d0.w),a2
	move.l		4(a3,d0.w),a3
	.endif

	swap	d2
	move.w	d4,d2
	move.l	d0,d4
	move.l	d2,d0
	move.l	d3,d2
	move.l	d5,d3

	ijsr		_fill_poly_r
	tst.l		d0
	bgt	.l1___fillpoly
	bmi	.l2___fillpoly

.l2___fillpoly:
  .ifne 0
    .ifeq	upto8
	addq.l		#4,a7
    .endif
    .ifne	upto8
	addq.l		#8,a7
    .endif
  .endif
	move.l		_fallback_fillpoly,d0
	bra		give_up

.l1___fillpoly:
  .ifne 0
    .ifeq	upto8
	addq.l		#4,a7
    .endif
    .ifne	upto8
	addq.l		#8,a7
    .endif
  .endif
	movem.l		(a7)+,d0-d7/a0-a6
	rts


	.ascii	"blit"












_blit:
blit:
	movem.l		d0-d7/a0-a6,-(a7)	

	move.l		a0,a1

	move.l		d0,d7

	move.w		d6,d0
	sub.w		d4,d0
	addq.w		#1,d0
	swap		d0
	move.w		d5,d0
	sub.w		d3,d0
	addq.w		#1,d0

	ijsr		_blit_area_r
	tst.l		d0
	bgt	.l1___blit
	move.l		_fallback_blit,d0
	bra		give_up

.l1___blit:
	movem.l		(a7)+,d0-d7/a0-a6
	rts


	.ascii	"text"













_text:
text:
	movem.l		d0-d7/a0-a6,-(a7)	

	move.l		a1,a4
	move.l		a0,a1

	move.w		d1,d4
	swap		d1
	move.w		d1,d3

	ijsr		_text_area_r
	tst.l		d0
	bgt	.l1___text
	move.l		_fallback_text,d0
	bra		give_up

.l1___text:
	movem.l		(a7)+,d0-d7/a0-a6
	rts


	.ascii	"mouse"
	.byte	0












_mouse:
mouse:
	ijsr		_mouse_draw_r
	rts


	.ascii	"set_palette"
	.byte	0







_set_palette:
set_palette:
	movem.l		d0-d7/a0-a6,-(a7)	

	ijsr		_set_colours_r

	movem.l		(a7)+,d0-d7/a0-a6
	rts


	.ascii	"colour"






_colour:
colour:
	movem.l		d1-d7/a0-a6,-(a7)

	ijsr		_get_colour_r

	movem.l		(a7)+,d1-d7/a0-a6
	rts


  .ifne	1
	.ascii	"initialize_palette"





_initialize_palette:
	movem.l		d0-d7/a0-a6,-(a7)	

	move.l		15*4+4(a7),a0
	move.l		15*4+8(a7),d1
	move.l		15*4+12(a7),d0
	swap		d0
	move.w		d1,d0
	move.l		15*4+16(a7),a1
	move.l		15*4+20(a7),a2

	ijsr		_set_colours_r

	movem.l		(a7)+,d0-d7/a0-a6
	rts
  .endif











get_colour_masks:
	lea		_mask,a3
  .ifne	upto8
	move.w		d0,a2
	lsr.l		#1,d0			
	and.l		#0x00780078,d0
	move.l		(a3,d0.w),a5
	move.l		4(a3,d0.w),a6
	move.w		a2,d0
  .endif
	and.l		#0x000f000f,d0
	lsl.l		#3,d0
	swap		d0
	pea		0(a3,d0.w)
	swap		d0
	move.l		0(a3,d0.w),a2
	move.l		4(a3,d0.w),a3
	move.l		(a7)+,d0
	rts








give_up:
	pea	.return
	move.l	d0,-(a7)
	movem.l	8(a7),d0-d7/a0-a6
	rts
.return:
	movem.l	(a7)+,d0-d7/a0-a6
	rts

	.end
