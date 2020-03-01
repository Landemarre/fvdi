









	.set	both,1	
	.equiv	longs,1
	.equiv	get,1
	.equiv	mul,1	
	.equiv	shift,1
	.equiv	smartdraw,1

	.include		"pixelmac.inc.gnu"
	.include		"vdi.inc.gnu"

	.global	line_draw
	.global	_line_draw

	.ifeq		shift
*	.external	dot
*	.external	lline
*	.external	rline
	.endif
	.ifeq		mul
*	.external	row
	.endif

*	.external	clip_line
*	.external	get_colour
*	.external	get_colour_masks













_line_draw:
line_draw:
	exg		a1,d5
	bclr		#0,d5
	bne		unknown_line
	exg		d5,a1

	bsr		clip_line
	bvc		.draw
	moveq		#1,d0
	rts
.draw:

	move.w		d0,-(a7)		
	move.l		d6,d0
	bsr		get_colour
	bsr		get_colour_masks

	move.l		vwk_real_address(a1),a1	
	.ifne	mul
	move.l		wk_screen_mfdb_address(a1),a0
	.endif
	move.w		wk_screen_wrap(a1),d0	

	move.w		d4,d6			
	sub.w		d2,d6
	beq		h_line
	move.w		d3,d5
	sub.w		d1,d5			
	beq		v_line
	bmi.s		line1			
	move.w		d1,d4
	bra.w		n_line

line1:
	neg.w		d5			
	neg.w		d6
	move.w		d4,d2
	move.w		d3,d4
n_line:
	addq.l		#2,a7			
	tst.w		d6
	bpl.s		.n_line0
	neg.w		d6
	neg.w		d0
.n_line0:
	move.l		#0x80008000,d1
	move.w		d4,d7
	and.w		#0x0f,d7
	lsr.l		d7,d1
	lsr.w		#4,d4
	lsl.w		#1,d4

	.ifne	mul
	mulu.w		wk_screen_wrap(a1),d2
	add.w		d4,a0
	add.l		d2,a0			
	.endif
	.ifeq	mul
	lea		row(pc),a0
	move.l		(a0,d2.w*4),a0
	add.w		d4,a0
	.endif

	.ifne	both
	move.l		wk_screen_shadow_address(a1),d7
	beq		no_shadow
	move.l		d7,a4
	add.w		d4,a4
	add.l		d2,a4
	.endif

	cmp.w		d6,d5
	bmi		.n_line2
.n_line1:					
	add.w		d6,d6
	move.w		d6,d3
	sub.w		d5,d6
	move.w		d6,d4
	sub.w		d5,d4

	move.w		d0,a1
	moveq		#0,d2
	.ifne	get
	swap		d3
	move.w		d4,d3
	swap		d3
	.endif

.lin1_lp2
	or.l		d1,d2
	tst.w		d6
	bpl.s		.lin1_no_y
	add.w		d3,d6
	ror.l		#1,d1
	dbcs		d5,.lin1_lp2


	move.l		a2,d0
	and.l		d2,d0
	move.l		d2,d7
	not.l		d7

	.ifeq	both
	 .ifeq	get
	and.w		d7,(a0)
	or.w		d0,(a0)+
	 .endif
	 .ifne	get
	move.w		(a0),d4
	and.w		d7,d4
	or.w		d0,d4
	move.w		d4,(a0)+
	 .endif
	.endif

	.ifne	both
	 .ifeq	get
	and.w		d7,(a4)
	or.w		d0,(a4)
	move.w		(a4)+,(a0)+
	 .endif
	 .ifne	get
	move.w		(a4),d4
	and.w		d7,d4
	or.w		d0,d4
	move.w		d4,(a4)+
	move.w		d4,(a0)+
	 .endif
	.endif

	moveq		#0,d2

	subq.w		#1,d5
	bpl		.lin1_lp2

	moveq		#1,d0			
	rts

.lin1_no_y
	.ifeq	get
	add.w		d4,d6
	.endif
	.ifne	get
	swap		d3
	add.w		d3,d6
	swap		d3
	.endif


	move.l		a2,d0
	and.l		d2,d0
	move.l		d2,d7
	not.l		d7

	.ifeq	both
	 .ifeq	get
	and.w		d7,(a0)
	or.w		d0,(a0)+
	 .endif
	 .ifne	get
	move.w		(a0),d4
	and.w		d7,d4
	or.w		d0,d4
	move.w		d4,(a0)+
	 .endif
	.endif

	.ifne	both
	 .ifeq	get
	and.w		d7,(a4)
	or.w		d0,(a4)
	move.w		(a4)+,(a0)+
	 .endif
	 .ifne	get
	move.w		(a4),d4
	and.w		d7,d4
	or.w		d0,d4
	move.w		d4,(a4)+
	move.w		d4,(a0)+
	 .endif
	.endif

	moveq		#0,d2

	.ifne	both
	add.l		a1,a4
	subq.l		#2,a4
	.endif
	add.l		a1,a0
	subq.l		#2,a0

	ror.l		#1,d1
	dbcs		d5,.lin1_lp2

	addq.l		#2,a0
	.ifne	both
	addq.l		#2,a4
	.endif

	subq.w		#1,d5
	bpl		.lin1_lp2

	moveq		#1,d0			
	rts

.n_line2:					
	exg		d6,d5
	add.w		d6,d6
	move.w		d6,d3
	sub.w		d5,d6
	move.w		d6,d4
	sub.w		d5,d4

	move.w		d0,a1
	subq.l		#2,a1
	.ifne	get
	swap		d3
	move.w		d4,d3
	swap		d3
	.endif

.lin2_lp
	tst.w		d6
	bpl.s		.lin2_no_x
	add.w		d3,d6


	move.l		a2,d0
	and.l		d1,d0
	move.l		d1,d7
	not.l		d7

	.ifeq	both
	 .ifeq	get
	and.w		d7,(a0)
	or.w		d0,(a0)+
	 .endif
	 .ifne	get
	move.w		(a0),d4
	and.w		d7,d4
	or.w		d0,d4
	move.w		d4,(a0)+
	 .endif
	.endif

	.ifne	both
	 .ifeq	get
	and.w		d7,(a4)
	or.w		d0,(a4)
	move.w		(a4)+,(a0)+
	 .endif
	 .ifne	get
	move.w		(a4),d4
	and.w		d7,d4
	or.w		d0,d4
	move.w		d4,(a4)+
	move.w		d4,(a0)+
	 .endif
	.endif

	.ifne	both
	add.l		a1,a4
	.endif

	add.l		a1,a0

	dbra		d5,.lin2_lp

	moveq		#1,d0			
	rts

.lin2_no_x
	.ifeq	get
	add.w		d4,d6
	.endif
	.ifne	get
	swap		d3
	add.w		d3,d6
	swap		d3
	.endif


	move.l		a2,d0
	and.l		d1,d0
	move.l		d1,d7
	not.l		d7

	.ifeq	both
	 .ifeq	get
	and.w		d7,(a0)
	or.w		d0,(a0)+
	 .endif
	 .ifne	get
	move.w		(a0),d4
	and.w		d7,d4
	or.w		d0,d4
	move.w		d4,(a0)+
	 .endif
	.endif

	.ifne	both
	 .ifeq	get
	and.w		d7,(a4)
	or.w		d0,(a4)
	move.w		(a4)+,(a0)+
	 .endif
	 .ifne	get
	move.w		(a4),d4
	and.w		d7,d4
	or.w		d0,d4
	move.w		d4,(a4)+
	move.w		d4,(a0)+
	 .endif
	.endif

	.ifne	both
	add.l		a1,a4
	.endif

	add.l		a1,a0

	ror.l		#1,d1
	dbcs		d5,.lin2_lp

	addq.l		#2,a0
	.ifne	both
	addq.l		#2,a4
	.endif

	subq.w		#1,d5
	bpl		.lin2_lp

	moveq		#1,d0			
	rts


.error:
	moveq		#1,d0			
	rts

unknown_line:
	moveq		#-1,d0
	rts


	.ifne	both
	.set	both,0

no_shadow:
	cmp.w		d6,d5
	bmi		.n_line2
.n_line1:					
	add.w		d6,d6
	move.w		d6,d3
	sub.w		d5,d6
	move.w		d6,d4
	sub.w		d5,d4

	move.w		d0,a1
	moveq		#0,d2
	.ifne	get
	swap		d3
	move.w		d4,d3
	swap		d3
	.endif

.lin1_lp2
	or.l		d1,d2
	tst.w		d6
	bpl.s		.lin1_no_y
	add.w		d3,d6
	ror.l		#1,d1
	dbcs		d5,.lin1_lp2


	move.l		a2,d0
	and.l		d2,d0
	move.l		d2,d7
	not.l		d7

	.ifeq	both
	 .ifeq	get
	and.w		d7,(a0)
	or.w		d0,(a0)+
	 .endif
	 .ifne	get
	move.w		(a0),d4
	and.w		d7,d4
	or.w		d0,d4
	move.w		d4,(a0)+
	 .endif
	.endif

	.ifne	both
	 .ifeq	get
	and.w		d7,(a4)
	or.w		d0,(a4)
	move.w		(a4)+,(a0)+
	 .endif
	 .ifne	get
	move.w		(a4),d4
	and.w		d7,d4
	or.w		d0,d4
	move.w		d4,(a4)+
	move.w		d4,(a0)+
	 .endif
	.endif

	moveq		#0,d2

	subq.w		#1,d5
	bpl		.lin1_lp2

	moveq		#1,d0			
	rts

.lin1_no_y
	.ifeq	get
	add.w		d4,d6
	.endif
	.ifne	get
	swap		d3
	add.w		d3,d6
	swap		d3
	.endif


	move.l		a2,d0
	and.l		d2,d0
	move.l		d2,d7
	not.l		d7

	.ifeq	both
	 .ifeq	get
	and.w		d7,(a0)
	or.w		d0,(a0)+
	 .endif
	 .ifne	get
	move.w		(a0),d4
	and.w		d7,d4
	or.w		d0,d4
	move.w		d4,(a0)+
	 .endif
	.endif

	.ifne	both
	 .ifeq	get
	and.w		d7,(a4)
	or.w		d0,(a4)
	move.w		(a4)+,(a0)+
	 .endif
	 .ifne	get
	move.w		(a4),d4
	and.w		d7,d4
	or.w		d0,d4
	move.w		d4,(a4)+
	move.w		d4,(a0)+
	 .endif
	.endif

	moveq		#0,d2

	.ifne	both
	add.l		a1,a4
	subq.l		#2,a4
	.endif
	add.l		a1,a0
	subq.l		#2,a0

	ror.l		#1,d1
	dbcs		d5,.lin1_lp2

	addq.l		#2,a0
	.ifne	both
	addq.l		#2,a4
	.endif

	subq.w		#1,d5
	bpl		.lin1_lp2

	moveq		#1,d0			
	rts

.n_line2:					
	exg		d6,d5
	add.w		d6,d6
	move.w		d6,d3
	sub.w		d5,d6
	move.w		d6,d4
	sub.w		d5,d4

	move.w		d0,a1
	subq.l		#2,a1
	.ifne	get
	swap		d3
	move.w		d4,d3
	swap		d3
	.endif

.lin2_lp
	tst.w		d6
	bpl.s		.lin2_no_x
	add.w		d3,d6


	move.l		a2,d0
	and.l		d1,d0
	move.l		d1,d7
	not.l		d7

	.ifeq	both
	 .ifeq	get
	and.w		d7,(a0)
	or.w		d0,(a0)+
	 .endif
	 .ifne	get
	move.w		(a0),d4
	and.w		d7,d4
	or.w		d0,d4
	move.w		d4,(a0)+
	 .endif
	.endif

	.ifne	both
	 .ifeq	get
	and.w		d7,(a4)
	or.w		d0,(a4)
	move.w		(a4)+,(a0)+
	 .endif
	 .ifne	get
	move.w		(a4),d4
	and.w		d7,d4
	or.w		d0,d4
	move.w		d4,(a4)+
	move.w		d4,(a0)+
	 .endif
	.endif

	.ifne	both
	add.l		a1,a4
	.endif

	add.l		a1,a0

	dbra		d5,.lin2_lp

	moveq		#1,d0			
	rts

.lin2_no_x
	.ifeq	get
	add.w		d4,d6
	.endif
	.ifne	get
	swap		d3
	add.w		d3,d6
	swap		d3
	.endif


	move.l		a2,d0
	and.l		d1,d0
	move.l		d1,d7
	not.l		d7

	.ifeq	both
	 .ifeq	get
	and.w		d7,(a0)
	or.w		d0,(a0)+
	 .endif
	 .ifne	get
	move.w		(a0),d4
	and.w		d7,d4
	or.w		d0,d4
	move.w		d4,(a0)+
	 .endif
	.endif

	.ifne	both
	 .ifeq	get
	and.w		d7,(a4)
	or.w		d0,(a4)
	move.w		(a4)+,(a0)+
	 .endif
	 .ifne	get
	move.w		(a4),d4
	and.w		d7,d4
	or.w		d0,d4
	move.w		d4,(a4)+
	move.w		d4,(a0)+
	 .endif
	.endif

	.ifne	both
	add.l		a1,a4
	.endif

	add.l		a1,a0

	ror.l		#1,d1
	dbcs		d5,.lin2_lp

	addq.l		#2,a0
	.ifne	both
	addq.l		#2,a4
	.endif

	subq.w		#1,d5
	bpl		.lin2_lp

	moveq		#1,d0			
	rts


.error:
	moveq		#1,d0			
	rts


	.set	both,1
	.endif
	
h_line:						
	cmp.w		d1,d3
	bge.s		.hline1
	exg		d1,d3
.hline1:
	.ifne	mul
	mulu.w		wk_screen_wrap(a1),d2
	add.l		d2,a0			
	.endif
	.ifeq	mul
	lea		row(pc),a0
	move.l		(a0,d2.w*4),a0
	.endif

	cmp.w		#3,(a7)+		
	beq		h_line_xor

	.ifne	both
	move.l		wk_screen_shadow_address(a1),d7
	move.l		a0,a1			
	beq		hno_shadow
	move.l		d7,a4
	add.l		d2,a4
	.endif

	move.l		#0xffff0000,d0
	move.w		d1,d2
	and.w		#0x0f,d2
	lsr.l		d2,d0
	move.w		d0,d7
	swap		d0
	move.w		d7,d0
	not.l		d0
	lsr.w		#4,d1
	lsl.w		#1,d1
	add.w		d1,a0
	.ifne	both
	add.w		d1,a4
	.endif

	move.l		#0xffff8000,d1
	move.w		d3,d2
	and.w		#0x0f,d2
	lsr.l		d2,d1
	move.w		d1,d7
	swap		d1
	move.w		d7,d1
	lsr.w		#4,d3
	lsl.w		#1,d3
	add.w		d3,a1

	cmp.l		a0,a1
	beq		hl_single

	move.l		a2,d2
	and.l		d0,d2
	move.l		a3,d3
	and.l		d0,d3
	not.l		d0

	.ifeq	both
	move.w		(a0),d5
	.endif
	.ifne	both
	move.w		(a4),d5
	.endif
	and.w		d0,d5
	or.w		d2,d5
	.ifeq	both
	move.w		d5,(a0)+
	.endif
	.ifne	both
	 .ifne	smartdraw
	cmp.w		(a4),d5
	bne		.write1
	addq.l		#2,a4
	addq.l		#2,a0
	bra		.done1
.write1:
	 .endif
	move.w		d5,(a4)+
	move.w		d5,(a0)+
.done1:
	.endif

	move.l		a1,d7
	sub.l		a0,d7
	lsr.w		#1,d7
	bra		.shl

.for_h:
	.ifeq	both
	move.w		a2,(a0)+
	.endif
	.ifne	both
	 .ifne	smartdraw
	cmp.w		(a4),d5
	bne		.write2
	addq.l		#2,a0
	addq.l		#2,a4
	bra		.done2
.write2:
	 .endif
	move.w		a2,(a0)+
	move.w		a2,(a4)+
.done2:
	.endif
.shl:
	dbf		d7,.for_h

	move.l		a2,d2
	and.l		d1,d2
	move.l		a3,d3
	and.l		d1,d3
	not.l		d1

	.ifeq	both
	move.w		(a0),d5
	.endif
	.ifne	both
	move.w		(a4),d5
	.endif
	and.w		d1,d5
	or.w		d2,d5
	.ifeq	both
	move.w		d5,(a0)+
	.endif
	.ifne	both
	 .ifne	smartdraw
	cmp.w		(a4),d5
	bne		.write3
	addq.l		#2,a4
	addq.l		#2,a0
	bra		.done3
.write3:
	 .endif
	move.w		d5,(a4)+
	move.w		d5,(a0)+
.done3:
	.endif

.end_h:
	moveq		#1,d0			
	rts

hl_single:
	and.l		d1,d0
	move.l		a2,d2
	and.l		d0,d2
	move.l		a3,d3
	and.l		d0,d3
	not.l		d0

	.ifeq	both
	move.w		(a0),d5
	.endif
	.ifne	both
	move.w		(a4),d5
	.endif
	and.w		d0,d5
	or.w		d2,d5
	.ifeq	both
	move.w		d5,(a0)+
	.endif
	.ifne	both
	 .ifne	smartdraw
	cmp.w		(a4),d5
	bne		.write
	addq.l		#2,a4
	addq.l		#2,a0
	bra		.done
.write:
	 .endif
	move.w		d5,(a4)+
	move.w		d5,(a0)+
.done:
	.endif

	moveq		#1,d0			
	rts


	.ifne	both
	.set	both,0

hno_shadow:
	move.l		#0xffff0000,d0
	move.w		d1,d2
	and.w		#0x0f,d2
	lsr.l		d2,d0
	move.w		d0,d7
	swap		d0
	move.w		d7,d0
	not.l		d0
	lsr.w		#4,d1
	lsl.w		#1,d1
	add.w		d1,a0
	.ifne	both
	add.w		d1,a4
	.endif

	move.l		#0xffff8000,d1
	move.w		d3,d2
	and.w		#0x0f,d2
	lsr.l		d2,d1
	move.w		d1,d7
	swap		d1
	move.w		d7,d1
	lsr.w		#4,d3
	lsl.w		#1,d3
	add.w		d3,a1

	cmp.l		a0,a1
	beq		mhl_single

	move.l		a2,d2
	and.l		d0,d2
	move.l		a3,d3
	and.l		d0,d3
	not.l		d0

	.ifeq	both
	move.w		(a0),d5
	.endif
	.ifne	both
	move.w		(a4),d5
	.endif
	and.w		d0,d5
	or.w		d2,d5
	.ifeq	both
	move.w		d5,(a0)+
	.endif
	.ifne	both
	move.w		d5,(a4)+
	move.w		d5,(a0)+
	.endif

	move.l		a1,d7
	sub.l		a0,d7
	lsr.w		#1,d7
	bra		.shl

.for_h:
	move.w		a2,(a0)+
	.ifne	both
	move.w		a2,(a4)+
	.endif
.shl:
	dbf		d7,.for_h

	move.l		a2,d2
	and.l		d1,d2
	move.l		a3,d3
	and.l		d1,d3
	not.l		d1

	.ifeq	both
	move.w		(a0),d5
	.endif
	.ifne	both
	move.w		(a4),d5
	.endif
	and.w		d1,d5
	or.w		d2,d5
	.ifeq	both
	move.w		d5,(a0)+
	.endif
	.ifne	both
	move.w		d5,(a4)+
	move.w		d5,(a0)+
	.endif

.end_h:
	moveq		#1,d0			
	rts

mhl_single:
	and.l		d1,d0
	move.l		a2,d2
	and.l		d0,d2
	move.l		a3,d3
	and.l		d0,d3
	not.l		d0

	.ifeq	both
	move.w		(a0),d5
	.endif
	.ifne	both
	move.w		(a4),d5
	.endif
	and.w		d0,d5
	or.w		d2,d5
	.ifeq	both
	move.w		d5,(a0)+
	.endif
	.ifne	both
	move.w		d5,(a4)+
	move.w		d5,(a0)+
	.endif

	moveq		#1,d0			
	rts

	.set	both,1
	.endif


v_line:						
	tst.w		d6
	bgt.s		.lvert2
	exg		d2,d4	
	neg.w		d6
.lvert2:
	.ifne	mul
	moveq		#0,d5
	move.w		wk_screen_wrap(a1),d5
	mulu.w		d5,d2
	add.l		d2,a0
	.endif
	.ifeq	mul
	lea		row(pc),a0
	move.l		(a0,d2.w*4),a0
	moveq		#0,d5
	move.w		wk_screen_wrap(a1),d5
	.endif

	cmp.w		#3,(a7)+		
	beq		v_line_xor

	.ifne	both
	move.l		wk_screen_shadow_address(a1),d7
	beq		vno_shadow
	move.l		d7,a4
	add.l		d2,a4
	.endif

	move.l		#0x80008000,d0
	move.w		d1,d7
	and.w		#0x0f,d7
	lsr.l		d7,d0
	lsr.w		#4,d1
	lsl.w		#1,d1
	add.w		d1,a0
	.ifne	both
	add.w		d1,a4
	.endif
	move.l		d0,d2
	move.l		a2,d0
	and.l		d2,d0
	move.l		a3,d1
	and.l		d2,d1
	not.l		d2

	subq.l		#2,d5


.for_v:
	.ifeq	both
	move.w		(a0),d3
	.endif
	.ifne	both
	move.w		(a4),d3
	.endif
	and.w		d2,d3
	or.w		d0,d3
	.ifeq	both
	move.w		d3,(a0)+
	.endif
	.ifne	both
	move.w		d3,(a4)+
	move.w		d3,(a0)+
	.endif
	.ifne	both
	add.l		d5,a4
	.endif

	add.l		d5,a0
.svl:
	dbf		d6,.for_v
.end_v:
	moveq		#1,d0			
	rts


	.ifne	both
	.set	both,0

vno_shadow:
	move.l		#0x80008000,d0
	move.w		d1,d7
	and.w		#0x0f,d7
	lsr.l		d7,d0
	lsr.w		#4,d1
	lsl.w		#1,d1
	add.w		d1,a0
	.ifne	both
	add.w		d1,a4
	.endif
	move.l		d0,d2
	move.l		a2,d0
	and.l		d2,d0
	move.l		a3,d1
	and.l		d2,d1
	not.l		d2

	subq.l		#2,d5


.for_v:
	.ifeq	both
	move.w		(a0),d3
	.endif
	.ifne	both
	move.w		(a4),d3
	.endif
	and.w		d2,d3
	or.w		d0,d3
	.ifeq	both
	move.w		d3,(a0)+
	.endif
	.ifne	both
	move.w		d3,(a4)+
	move.w		d3,(a0)+
	.endif
	.ifne	both
	add.l		d5,a4
	.endif

	add.l		d5,a0
.svl:
	dbf		d6,.for_v
.end_v:
	moveq		#1,d0			
	rts

	.set	both,1
	.endif


h_line_xor:						
	.ifne	both
	move.l		wk_screen_shadow_address(a1),d7
	move.l		a0,a1			
	beq		hno_shadow_xor
	move.l		d7,a4
	add.l		d2,a4
	.endif

	move.l		#0xffff0000,d0
	move.w		d1,d2
	and.w		#0x0f,d2
	lsr.l		d2,d0
	move.w		d0,d7
	swap		d0
	move.w		d7,d0
	not.l		d0
	lsr.w		#4,d1
	lsl.w		#1,d1
	add.w		d1,a0
	.ifne	both
	add.w		d1,a4
	.endif

	move.l		#0xffff8000,d1
	move.w		d3,d2
	and.w		#0x0f,d2
	lsr.l		d2,d1
	move.w		d1,d7
	swap		d1
	move.w		d7,d1
	lsr.w		#4,d3
	lsl.w		#1,d3
	add.w		d3,a1

	cmp.l		a0,a1
	beq		hl_single_xor







	.ifeq	both
	move.w		(a0),d5
	.endif
	.ifne	both
	move.w		(a4),d5
	.endif


	eor.w		d0,d5		
	.ifeq	both
	move.w		d5,(a0)+
	.endif
	.ifne	both
	move.w		d5,(a4)+
	move.w		d5,(a0)+
	.endif

	move.l		a1,d7
	sub.l		a0,d7
	lsr.w		#1,d7
	bra		.shl

.for_h:
	.ifeq	both

	not.w		(a0)+
	.endif
	.ifne	both
	move.w		(a4),d5
	not.w		d5
	move.w		d5,(a0)+
	move.w		d5,(a4)+
	.endif
.shl:
	dbf		d7,.for_h







	.ifeq	both
	move.w		(a0),d5
	.endif
	.ifne	both
	move.w		(a4),d5
	.endif


	eor.w		d1,d5		
	.ifeq	both
	move.w		d5,(a0)+
	.endif
	.ifne	both
	move.w		d5,(a4)+
	move.w		d5,(a0)+
	.endif

.end_h:
	moveq		#1,d0			
	rts

hl_single_xor:
	and.l		d1,d0






	.ifeq	both
	move.w		(a0),d5
	.endif
	.ifne	both
	move.w		(a4),d5
	.endif


	eor.w		d0,d5		
	.ifeq	both
	move.w		d5,(a0)+
	.endif
	.ifne	both
	move.w		d5,(a4)+
	move.w		d5,(a0)+
	.endif

	moveq		#1,d0			
	rts


	.ifne	both
	.set	both,0

hno_shadow_xor:
	move.l		#0xffff0000,d0
	move.w		d1,d2
	and.w		#0x0f,d2
	lsr.l		d2,d0
	move.w		d0,d7
	swap		d0
	move.w		d7,d0
	not.l		d0
	lsr.w		#4,d1
	lsl.w		#1,d1
	add.w		d1,a0
	.ifne	both
	add.w		d1,a4
	.endif

	move.l		#0xffff8000,d1
	move.w		d3,d2
	and.w		#0x0f,d2
	lsr.l		d2,d1
	move.w		d1,d7
	swap		d1
	move.w		d7,d1
	lsr.w		#4,d3
	lsl.w		#1,d3
	add.w		d3,a1

	cmp.l		a0,a1
	beq		mhl_single_xor







	.ifeq	both
	move.w		(a0),d5
	.endif
	.ifne	both
	move.w		(a4),d5
	.endif


	eor.w		d0,d5		
	.ifeq	both
	move.w		d5,(a0)+
	.endif
	.ifne	both
	move.w		d5,(a4)+
	move.w		d5,(a0)+
	.endif

	move.l		a1,d7
	sub.l		a0,d7
	lsr.w		#1,d7
	bra		.shl

.for_h:
	.ifeq	both

	not.w		(a0)+
	.endif
	.ifne	both
	move.w		(a4),d5
	not.w		d5
	move.w		d5,(a0)+
	move.w		d5,(a4)+
	.endif
.shl:
	dbf		d7,.for_h







	.ifeq	both
	move.w		(a0),d5
	.endif
	.ifne	both
	move.w		(a4),d5
	.endif


	eor.w		d1,d5		
	.ifeq	both
	move.w		d5,(a0)+
	.endif
	.ifne	both
	move.w		d5,(a4)+
	move.w		d5,(a0)+
	.endif

.end_h:
	moveq		#1,d0			
	rts

mhl_single_xor:
	and.l		d1,d0






	.ifeq	both
	move.w		(a0),d5
	.endif
	.ifne	both
	move.w		(a4),d5
	.endif


	eor.w		d1,d5		
	.ifeq	both
	move.w		d5,(a0)+
	.endif
	.ifne	both
	move.w		d5,(a4)+
	move.w		d5,(a0)+
	.endif

	moveq		#1,d0			
	rts


	.set	both,1
	.endif


v_line_xor:						
	.ifne	both
	move.l		wk_screen_shadow_address(a1),d7
	beq		vno_shadow_xor
	move.l		d7,a4
	add.l		d2,a4
	.endif

	move.l		#0x80008000,d0
	move.w		d1,d7
	and.w		#0x0f,d7
	lsr.l		d7,d0
	lsr.w		#4,d1
	lsl.w		#1,d1
	add.w		d1,a0
	.ifne	both
	add.w		d1,a4
	.endif







	subq.l		#2,d5


.for_v:
	.ifeq	both
	move.w		(a0),d3
	.endif
	.ifne	both
	move.w		(a4),d3
	.endif


	eor.w		d0,d3		
	.ifeq	both
	move.w		d3,(a0)+
	.endif
	.ifne	both
	move.w		d3,(a4)+
	move.w		d3,(a0)+
	.endif
	.ifne	both
	add.l		d5,a4
	.endif

	add.l		d5,a0
.svl:
	dbf		d6,.for_v
.end_v:
	moveq		#1,d0			
	rts


	.ifne	both
	.set	both,0

vno_shadow_xor:
	move.l		#0x80008000,d0
	move.w		d1,d7
	and.w		#0x0f,d7
	lsr.l		d7,d0
	lsr.w		#4,d1
	lsl.w		#1,d1
	add.w		d1,a0
	.ifne	both
	add.w		d1,a4
	.endif







	subq.l		#2,d5


.for_v:
	.ifeq	both
	move.w		(a0),d3
	.endif
	.ifne	both
	move.w		(a4),d3
	.endif


	eor.w		d0,d3		
	.ifeq	both
	move.w		d3,(a0)+
	.endif
	.ifne	both
	move.w		d3,(a4)+
	move.w		d3,(a0)+
	.endif
	.ifne	both
	add.l		d5,a4
	.endif

	add.l		d5,a0
.svl:
	dbf		d6,.for_v
.end_v:
	moveq		#1,d0			
	rts

	.set	both,1
	.endif


	.end
