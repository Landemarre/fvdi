













	.include		"vdi.inc.gnu"
	.include		"macros.inc.gnu"

	.global	_c_line
	.global	_c_set_pixel
	.global	_c_get_pixel
	.global	_c_expand
	.global	_c_fill
	.global	_c_fillpoly
	.global	_c_blit
	.global	_c_text
	.global	_c_mouse
	.global	_c_set_palette
	.global	_c_colour
	.global	_c_initialize_palette

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


	.text

	.ascii	"set_pixel"
	.byte	0








_c_set_pixel:
c_set_pixel:
	movem.l		d0-d2/a0-a2,-(a7)

	ext.l		d1
	ext.l		d2
	move.l		d0,-(a7)
	move.l		d2,-(a7)
	move.l		d1,-(a7)
	move.l		4(a0),-(a7)
	move.l		(a0),-(a7)
	ijsr		_write_pixel_r
	tst.l		d0
	bgt		.write_done

	tst.w		d2
	bne		.write_done		
	move.l		20+3*4(a7),d3		
	bclr		#0,d3
	move.l		d3,0(a7)
.write_loop:
	move.l		20+5*4(a7),a2
	moveq		#0,d0
	move.w		(a2)+,d0
	move.l		d0,8(a7)
	move.w		(a2)+,d0
	move.l		d0,12(a7)
	move.l		a2,20+5*4(a7)
	ijsr		_write_pixel_r
	subq.w		#1,2*4(a7)
	bne		.write_loop

.write_done:
	add.w		#20,a7
	movem.l		(a7)+,d0-d2/a0-a2
	rts


	.ascii	"get_pixel"
	.byte	0








_c_get_pixel:
c_get_pixel:
	movem.l		d1-d2/a0-a2,-(a7)

	ext.l		d1
	ext.l		d2
	move.l		d2,-(a7)
	move.l		d1,-(a7)
	move.l		4(a0),-(a7)
	move.l		(a0),-(a7)
	ijsr		_read_pixel_r
	add.w		#16,a7

	movem.l		(a7)+,d1-d2/a0-a2
	rts


	.ascii	"line"












_c_line:
c_line:
	cmp.w		#0xc0de,d0
	beq		new_api_line
old_api_line:
	movem.l		d0-d2/a0-a2,-(a7)

	move.l		d6,-(a7)
	move.l		d0,-(a7)
	move.l		d5,-(a7)
	move.l		d4,-(a7)
	move.l		d3,-(a7)
	move.l		d2,-(a7)
	move.l		d1,-(a7)
	move.l		a0,-(a7)
	ijsr		_line_draw_r
	add.w		#32,a7

	tst.l		d0
	bgt	.l1___old_api_line
	bmi	.l2___old_api_line
	move.l		_fallback_line,d0
	bra		give_up

.l1___old_api_line:
	movem.l		(a7)+,d0-d2/a0-a2
	rts

.l2___old_api_line:
	movem.l		d3-d4/d7/a6,-(a7)
	move.w		16+2*4+2(a7),d0
	move.w		d3,d7
	cmp.w		#1,d0
	bhi		.line_done		
	beq		.use_marks
	moveq		#0,d7			
.use_marks:
	swap		d7
	move.w		#1,d7			
	swap		d7

	move.l		16+3*4(a7),d3		
	bclr		#0,d3


	sub.w		#32,a7
	move.l		d3,0(a7)
	move.l		d5,20(a7)

	move.l		d6,28(a7)

	move.l		d4,a6
	tst.w		d7
	beq		.no_start_move
	add.w		d7,a6
	add.w		d7,a6
	subq.l		#2,a6
	cmp.w		#-4,(a6)
	bne		.no_start_movex
	subq.l		#2,a6
	sub.w		#1,d7
.no_start_movex:
	cmp.w		#-2,(a6)
	bne		.no_start_move
	subq.l		#2,a6
	sub.w		#1,d7
.no_start_move:
	bra		.loop_end
.line_loop:
	move.l		32+16+4(a7),a2
	movem.w		(a2),d1-d4
	move.l		0(a7),a0
	bsr		clip_line
	bvs		.no_draw
	move.l		d1,4(a7)
	move.l		d2,8(a7)
	move.l		d3,12(a7)
	move.l		d4,16(a7)
	move.l		32+16+0(a7),24(a7)
	ijsr		_line_draw_r
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
	addq.l		#4,32+16+4(a7)
	subq.w		#1,32+16+2*4(a7)
.no_move:
	swap		d7
.no_marks:
	addq.l		#4,32+16+4(a7)
.loop_end:
	subq.w		#1,32+16+2*4(a7)
	bgt		.line_loop
	add.w		#32,a7
.line_done:
	movem.l		(a7)+,d3-d4/d7/a6
	movem.l		(a7)+,d0-d2/a0-a2
	rts

	
new_api_line:
	movem.l		d2-d7/a2-a6,-(a7)

	move.l		11*4+4(a7),a0
	move.l		11*4+8(a7),a1
	move.l		drvline_x1(a1),d1
	move.l		drvline_y1(a1),d2
	move.l		drvline_x2(a1),d3
	move.l		drvline_y2(a1),d4
	move.l		drvline_pattern(a1),d5
	move.l		drvline_colour(a1),d0
	move.l		drvline_mode(a1),d6
  .ifne 0
	bsr		old_api_line
  .else
	move.l		d6,-(a7)
	move.l		d0,-(a7)
	move.l		d5,-(a7)
	move.l		d4,-(a7)
	move.l		d3,-(a7)
	move.l		d2,-(a7)
	move.l		d1,-(a7)
	move.l		a0,-(a7)
	ijsr		_line_draw_r
	add.w		#32,a7
  .endif
	movem.l		(a7)+,d2-d7/a2-a6
	rts


	.ascii	"expand"









_c_expand:
c_expand:
	movem.l		d0-d2/a0-a2,-(a7)

	ext.l		d1
	ext.l		d2
	move.l		d0,-(a7)
	ext.l		d7
	move.l		d7,-(a7)

	move.w		d6,d0
	sub.w		d4,d0
	addq.w		#1,d0
	ext.l		d0
	move.l		d0,-(a7)
	move.w		d5,d0
	sub.w		d3,d0
	addq.w		#1,d0
	ext.l		d0
	move.l		d0,-(a7)

	move.w		d4,d0
	ext.l		d0
	move.l		d0,-(a7)
	move.w		d3,d0
	ext.l		d0
	move.l		d0,-(a7)
	move.l		4(a0),-(a7)
	move.l		d2,-(a7)
	move.l		d1,-(a7)
	move.l		12(a0),-(a7)
	move.l		(a0),-(a7)

	ijsr		_expand_area_r
	add.w		#44,a7

	tst.l		d0
	bgt	.l1___c_expand
	move.l		_fallback_expand,d0
	bra		give_up

.l1___c_expand:
	movem.l		(a7)+,d0-d2/a0-a2
	rts


	.ascii	"fill"












_c_fill:
c_fill:
	movem.l		d0-d2/a0-a2,-(a7)




	move.l		d7,-(a7)
	move.l		d6,-(a7)

	move.l		d0,-(a7)
	move.l		d5,-(a7)

	move.w		d4,d0
	sub.w		d2,d0
	addq.w		#1,d0
	ext.l		d0
	move.l		d0,-(a7)
	move.w		d3,d0
	sub.w		d1,d0
	addq.w		#1,d0
	ext.l		d0
	move.l		d0,-(a7)

	move.l		d2,-(a7)
	move.l		d1,-(a7)
	move.l		a0,-(a7)

	ijsr		_fill_area_r
	tst.l		d0
	bgt	.l1___c_fill
	bmi	.l2___c_fill
	add.w		#36,a7
	move.l		_fallback_fill,d0
	bra		give_up

.l1___c_fill:
	add.w		#36,a7
	movem.l		(a7)+,d0-d2/a0-a2
	rts

.l2___c_fill:
	move.w		36+8+2(a7),d0
	tst.w		d0
	bne		.fill_done		
	move.l		36+3*4(a7),d3		
	bclr		#0,d3
	move.l		d3,0(a7)
	move.l		#1,16(a7)		
.fill_loop:
	move.l		36+4(a7),a2
	moveq		#0,d0
	move.w		(a2)+,d0
	move.l		d0,8(a7)
	move.w		(a2)+,d0
	move.l		d0,4(a7)
	sub.w		(a2)+,d0
	neg.w		d0
	addq.w		#1,d0
	move.l		d0,12(a7)
	move.l		a2,36+4(a7)
	ijsr		_fill_area_r
	subq.w		#1,36+8(a7)
	bne		.fill_loop
.fill_done:
	add.w		#36,a7
	movem.l		(a7)+,d0-d2/a0-a2
	rts


	.ascii	"fillpoly"













_c_fillpoly:
c_fillpoly:
	movem.l		d0-d2/a0-a2,-(a7)

	move.l		d7,-(a7)
	move.l		d6,-(a7)
	
	move.l		d0,-(a7)
	move.l		d5,-(a7)

	move.w		d4,d0
	ext.l		d0
	move.l		d0,-(a7)

	move.l		d3,-(a7)

	move.w		d2,d0
	ext.l		d0
	move.l		d0,-(a7)

	move.l		d1,-(a7)
	move.l		a0,-(a7)

	ijsr		_fill_poly_r
	tst.l		d0
	bgt	.l1___c_fillpoly
	bmi	.l2___c_fillpoly

.l2___c_fillpoly:
	add.w		#36,a7
	move.l		_fallback_fillpoly,d0
	bra		give_up

.l1___c_fillpoly:
	add.w		#36,a7
	movem.l		(a7)+,d0-d2/a0-a2
	rts


	.ascii	"blit"








_c_blit:
c_blit:
	movem.l		d0-d2/a0-a2,-(a7)

	ext.l		d1
	ext.l		d2
	ext.l		d0
	move.l		d0,-(a7)

	move.w		d6,d0
	sub.w		d4,d0
	addq.w		#1,d0
	ext.l		d0
	move.l		d0,-(a7)
	move.w		d5,d0
	sub.w		d3,d0
	addq.w		#1,d0
	ext.l		d0
	move.l		d0,-(a7)

	move.w		d4,d0
	ext.l		d0
	move.l		d0,-(a7)
	move.w		d3,d0
	ext.l		d0
	move.l		d0,-(a7)
	move.l		4(a0),-(a7)
	move.l		d2,-(a7)
	move.l		d1,-(a7)
	move.l		12(a0),-(a7)
	move.l		(a0),-(a7)

	ijsr		_blit_area_r
	add.w		#40,a7

	tst.l		d0
	bgt	.l1___c_blit
	move.l		_fallback_blit,d0
	bra		give_up

.l1___c_blit:
	movem.l		(a7)+,d0-d2/a0-a2
	rts


	.ascii	"text"









_c_text:
c_text:
	movem.l		d0-d2/a0-a2,-(a7)	

	ext.l		d0
	move.w		d1,d2
	swap		d1
	ext.l		d1
	ext.l		d2

	move.l		a2,-(a7)
	move.l		d2,-(a7)
	move.l		d1,-(a7)
	move.l		d0,-(a7)
	move.l		a1,-(a7)
	move.l		a0,-(a7)

	ijsr		_text_area_r
	add.w		#24,a7

	tst.l		d0
	bgt	.l1___c_text
	move.l		_fallback_text,d0
	bra		give_up

.l1___c_text:
	movem.l		(a7)+,d0-d2/a0-a2
	rts


	.ascii	"mouse"
	.byte	0









_c_mouse:
c_mouse:
	move.l		d2,-(a7)
	ext.l		d1
	move.l		d1,-(a7)

	move.l		d0,-(a7)
	move.l		a1,-(a7)
	ijsr		_mouse_draw_r
	add.w		#16,a7

	rts


	.ascii	"set_palette"
	.byte	0








_c_set_palette:
c_set_palette:
	cmp.w		#0xc0de,d0
	beq		new_api_set_palette

	movem.l		d0-d2/a0-a2,-(a7)

	move.l		a2,-(a7)
	move.l		a1,-(a7)
	move.l		d0,d1
	swap		d1
	ext.l		d1
	move.l		d1,-(a7)
	ext.l		d0
	move.l		d0,-(a7)
	move.l		a0,-(a7)

	ijsr		_set_colours_r
	add.w		#20,a7

	movem.l		(a7)+,d0-d2/a0-a2
	rts

new_api_set_palette:
	movem.l		d0-d2/a0-a2,-(a7)

	move.l		6*4+4(a7),a0
	move.l		6*4+8(a7),a1
	move.l		drvpalette_palette(a1),-(a7)
	move.l		drvpalette_requested(a1),-(a7)
	move.l		drvpalette_count(a1),-(a7)
	move.l		drvpalette_first_pen(a1),-(a7)
	move.l		a0,-(a7)
	ijsr		_set_colours_r
	add.w		#20,a7
	movem.l		(a7)+,d0-d2/a0-a2
	rts


	.ascii	"colour"







_c_colour:
c_colour:
	movem.l		d1-d2/a0-a2,-(a7)

	move.l		d0,-(a7)
	move.l		a0,-(a7)

	ijsr		_get_colour_r
	addq.l		#8,a7

	movem.l		(a7)+,d1-d2/a0-a2
	rts


  .ifne	1
	.ascii	"initialize_palette"





_c_initialize_palette:
	ijmp		_set_colours_r		
  .endif







give_up:
	pea	.return
	move.l	d0,-(a7)
	movem.l	8(a7),d0-d2/a0-a2
	rts
.return:
	movem.l	(a7)+,d0-d2/a0-a2
	rts

	.end
