







	.include	"vdi.inc.gnu"

	.global	clip_line
	.global	_clip_line

	.text



	.ascii	"clip_line"
	.byte	0
_clip_line:
	movem.l	d2-d4,-(a7)
	move.l	3*4+4(a7),a0
	move.l	3*4+8(a7),a1
	move.l	(a1),d1
	move.l	3*4+12(a7),a1
	move.l	(a1),d2
	move.l	3*4+16(a7),a1
	move.l	(a1),d3
	move.l	3*4+20(a7),a1
	move.l	(a1),d4
	bsr	clip_line
	svc	d0
	ext.w	d0
	ext.l	d0
	move.l	3*4+8(a7),a1
	ext.l	d1
	move.l	d1,(a1)
	move.l	3*4+12(a7),a1
	ext.l	d2
	move.l	d2,(a1)
	move.l	3*4+16(a7),a1
	ext.l	d3
	move.l	d3,(a1)
	move.l	3*4+20(a7),a1
	ext.l	d4
	move.l	d4,(a1)
	movem.l	(a7)+,d2-d4
	rts










clip_line:
	movem.l		d0/d5-d7,-(a7)
	tst.w		vwk_clip_on(a0)
	beq		.end_clip

	moveq		#0,d0		
	move.w		vwk_clip_rectangle_x1(a0),d6
	move.w		vwk_clip_rectangle_y1(a0),d7
	sub.w		d6,d1		
	sub.w		d7,d2		
	sub.w		d6,d3
	sub.w		d7,d4


	move.w		vwk_clip_rectangle_y2(a0),d7
	sub.w		vwk_clip_rectangle_y1(a0),d7	

	cmp.w		d2,d4
	bge.s		.sort_y1y2	
	exg		d1,d3
	exg		d2,d4
	not.w		d0		

.sort_y1y2:
	cmp.w		d7,d2
	bgt		.error		
	move.w		d4,d6
	blt		.error		
	sub.w		d2,d6		
	move.w		d3,d5
	sub.w		d1,d5		
	bne.s		.no_vertical

	tst.w		d2		
	bge.s		.y1in		
	moveq		#0,d2
.y1in:	cmp.w		d7,d4
	ble.s		.vertical_done	
	move.w		d7,d4
	bra.s		.vertical_done

.no_vertical:
	tst.w		d2
	bge.s		.y1_inside	
	muls.w		d5,d2		
	divs.w		d6,d2		
	sub.w		d2,d1		
	moveq		#0,d2		

.y1_inside:
	sub.w		d4,d7
	bge.s		.y2_inside	

	muls.w		d7,d5		
	divs.w		d6,d5		
	add.w		d5,d3		
	add.w		d7,d4		

.y2_inside:
.vertical_done:

	move.w		vwk_clip_rectangle_x2(a0),d7
	sub.w		vwk_clip_rectangle_x1(a0),d7	

	cmp.w		d1,d3
	bge.s		.sort_x1x2	
	exg		d1,d3
	exg		d2,d4
	not.w		d0		

.sort_x1x2:
	cmp.w		d7,d1
	bgt		.error		
	move.w		d3,d5
	blt		.error		
	sub.w		d1,d5		
	move.w		d4,d6
	sub.w		d2,d6		
	bne.s		.no_horizontal

	tst.w		d1		
	bge.s		.x1in		
	moveq		#0,d1
.x1in:	cmp.w		d7,d3
	ble.s		.horizontal_done	
	move.w		d7,d3
	bra.s		.horizontal_done

.no_horizontal:
	tst.w		d1
	bge.s		.x1_inside	
	muls.w		d6,d1		
	divs.w		d5,d1		
	sub.w		d1,d2		
	moveq		#0,d1		

.x1_inside:
	sub.w		d3,d7
	bge.s		.x2_inside	

	muls.w		d7,d6		
	divs.w		d5,d6		
	add.w		d6,d4		
	add.w		d7,d3		

.x2_inside:
.horizontal_done:
	move.w		vwk_clip_rectangle_x1(a0),d6
	move.w		vwk_clip_rectangle_y1(a0),d7
	add.w		d6,d1		
	add.w		d7,d2
	add.w		d6,d3
	add.w		d7,d4

	tst.w		d0
	beq		.end_clip
	exg		d1,d3		
	exg		d2,d4
.end_clip:
	movem.l		(a7)+,d0/d5-d7
	rts

.error:
	movem.l		(a7)+,d0/d5-d7
	move.w		#2,-(a7)	
	rtr

	.end
