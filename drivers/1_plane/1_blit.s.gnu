









	.set	both,1	
	.equiv	longs,1
	.equiv	get,1
	.equiv	mul,1	
	.equiv	shift,1

	.include		"pixelmac.inc.gnu"
	.include		"vdi.inc.gnu"

	.global	blit_area
	.global	_blit_area

	.ifeq		shift
*	.external	dot
*	.external	lline
*	.external	rline
	.endif
	.ifeq		mul
*	.external	row
	.endif


	.ascii	"blit"






_blit_area:
blit_area:
	move.w		d7,-(a7)		
	cmp.w		d1,d3
	shi		-(a7)
	cmp.w		d2,d4
	seq		-(a7)			
	sls		-(a7)			

	move.l		12(a1),d6		
	beq		from_screen

	move.l		d6,a0
	move.l		mfdb_address(a0),d6
	beq		from_screen
	move.w		mfdb_wdwidth(a0),d5
	move.w		mfdb_bitplanes(a0),d7
	move.l		(a1),a2
	move.l		vwk_real_address(a2),a2
	move.l		wk_screen_mfdb_address(a2),a0
	cmp.l		a0,d6
	beq		xfrom_screen

	move.l		d6,a0

	add.w		d5,d5
	mulu.w		d5,d7
	mulu.w		d2,d7
	add.l		d7,a0

calculate_to:
	swap		d5			

	move.w		d1,d2
	and.w		#0x0f,d1			

	lsr.w		#4,d2
	lsl.w		#1,d2
	add.w		d2,a0			
	move.l		a0,d2			

	sub.l		#0x10000,d0		

	move.l		4(a1),d6		
	beq		normal

	move.l		d6,a0
	move.l		mfdb_address(a0),d6
	beq		normal
	move.w		mfdb_wdwidth(a0),d5
	move.w		mfdb_bitplanes(a0),d7
	move.l		(a1),a1
	move.l		vwk_real_address(a1),a1
	move.l		wk_screen_mfdb_address(a1),a0
	cmp.l		a0,d6
	beq		xnormal

	move.l		d6,a1
	add.w		d5,d5			
	mulu.w		d5,d7
	mulu.w		d7,d4			
	add.l		d4,a1

no_shadow:
	move.w		d3,d4
	and.w		#0x0f,d3			

	lsr.w		#4,d4
	lsl.w		#1,d4
	add.w		d4,a1			
						
	move.l		d2,a0

	add.w		d3,d0
	subq.w		#1,d0
	move.w		d0,d2
	move.w		d0,d4

	move.l		d5,d7

	lsr.w		#4,d4
	lsl.w		#1,d4
	swap		d5
	sub.w		d4,d5
	move.w		d5,a2
	swap		d5			

	sub.w		d4,d5
	move.w		d5,a3





	tst.b		(a7)+
	bne		.no_wrap_change

	swap		d0
	move.w		d7,d6
	mulu.w		d0,d6
	add.l		d6,a1

	move.l		d7,d6
	swap		d6
	mulu.w		d0,d6
	add.l		d6,a0

	swap		d0
	add.l		d7,d7
	sub.w		d7,d5
	sub.w		d7,a3
	swap		d5
	swap		d7
	sub.w		d7,d5
	sub.w		d7,a2
	swap		d5
.no_wrap_change:	

	and.w		#0x0f,d2
	addq.w		#1,d2			

	lsr.w		#4,d0
	beq		mfdb_single
	subq.w		#1,d0			

	tst.b		(a7)+
	beq		.no_pan
	tst.b		(a7)+
	bne		mfdb_pan_backwards
	subq.l		#2,a7			
.no_pan:
	addq.l		#2,a7


	move.w		(a7)+,d7
	cmp.w		#3,d7
	bne		.operations

	sub.w		d3,d1			
	blt		mfdb_right

	beq		mfdb_none

	bra		mfdb_left

.operations:
	move.l		a6,-(a7)
	lsl.w		#2,d7
	lea		operations,a6
	move.l		(a6,d7.w),a6

	sub.w		d3,d1			
	blt		mfdb_right_op

	beq		mfdb_none_op

	bra		mfdb_left_op

from_screen:
	move.l		(a1),a2
	move.l		vwk_real_address(a2),a2

	.ifne	mul
	move.l		wk_screen_mfdb_address(a2),a0
	.endif

xfrom_screen:
	.ifne	mul
	move.w		wk_screen_wrap(a2),d5	
	mulu.w		d5,d2
	add.l		d2,a0
	.endif
	.ifeq	mul
	lea		row(pc),a0
	move.l		(a0,d2.w*4),a0
	.endif

	.ifne	both
	move.l		wk_screen_shadow_address(a2),d7
	beq		.not_from_shadow
	move.l		d7,a0
	add.l		d2,a0
.not_from_shadow:
	.endif
	bra		calculate_to










normal:
	move.l		(a1),a1
	move.l		vwk_real_address(a1),a1

	.ifne	mul
	move.l		wk_screen_mfdb_address(a1),a0
	.endif

xnormal:
	.ifne	mul
	move.w		wk_screen_wrap(a1),d5	
	mulu.w		d5,d4
	add.l		d4,a0




	.endif
	.ifeq	mul
	lea		row(pc),a0
	move.l		(a0,d4.w*4),a0
	.endif

	exg		a0,a1			

	.ifne	both

	move.l		wk_screen_shadow_address(a0),d7
	beq		no_shadow		
	move.l		d7,a4
	add.l		d4,a4
	.endif

	move.w		d3,d4
	and.w		#0x0f,d3			

	lsr.w		#4,d4
	lsl.w		#1,d4
	add.w		d4,a1			
	.ifne	both
	add.w		d4,a4			
	.endif					

	move.l		d2,a0

	add.w		d3,d0
	subq.w		#1,d0
	move.w		d0,d2
	move.w		d0,d4

	move.l		d5,d7

	lsr.w		#4,d4
	lsl.w		#1,d4
	swap		d5
	sub.w		d4,d5
	move.w		d5,a2
	swap		d5			

	sub.w		d4,d5
	move.w		d5,a3





	tst.b		(a7)+
	bne		.no_wrap_change

	swap		d0
	move.w		d7,d6
	mulu.w		d0,d6
	add.l		d6,a1
	.ifne	both
	add.l		d6,a4
	.endif

	move.l		d7,d6
	swap		d6
	mulu.w		d0,d6
	add.l		d6,a0

	swap		d0
	add.l		d7,d7
	sub.w		d7,d5
	sub.w		d7,a3
	swap		d5
	swap		d7
	sub.w		d7,d5
	sub.w		d7,a2
	swap		d5
.no_wrap_change:

	and.w		#0x0f,d2
	addq.w		#1,d2			

	lsr.w		#4,d0
	beq		shadow_single
	subq.w		#1,d0			

	tst.b		(a7)+
	beq		.no_pan
	tst.b		(a7)+
	bne		shadow_pan_backwards
	subq.l		#2,a7			
.no_pan:
	addq.l		#2,a7


	move.w		(a7)+,d7
	cmp.w		#3,d7
	bne		.operations

	sub.w		d3,d1			
	blt		shadow_right

	beq		shadow_none

	bra		shadow_left

.operations:
	move.l		a6,-(a7)
	lsl.w		#2,d7
	lea		operations,a6
	move.l		(a6,d7.w),a6

	sub.w		d3,d1			
	blt		shadow_right_op

	beq		shadow_none_op

	bra		shadow_left_op









	.set	shadow,0
	.set	oldboth,both
	.set	both,0
	.include		"1_blit.inc.gnu"


	.set	both,oldboth
	.ifne	both
	.set	shadow,1
	.include		"1_blit.inc.gnu"
	.endif


mode_0:
	and.w		d6,d4
	not.w		d6
	rts
	nop
	nop

	moveq		#0,d7
	rts

mode_1:
	or.w		d6,d7
	and.w		d7,d4
	not.w		d6
	rts
	nop

	and.w		d4,d7
	rts

mode_2:
	or.w		d6,d7
	not.w		d6
	eor.w		d6,d4
	and.w		d7,d4
	rts

	not.w		d4
	and.w		d4,d7
	rts

mode_3:
	and.w		d6,d4
	not.w		d6
	and.w		d6,d7
	or.w		d7,d4
	rts

	rts

mode_4:
	not.w		d7
	or.w		d6,d7
	and.w		d7,d4
	not.w		d6
	rts

	not.w		d7
	and.w		d4,d7
	rts

mode_5:
	not.w		d6
	rts
	nop
	nop
	nop

	move.w		d4,d7
	rts

mode_6:
	not.w		d6
	and.w		d6,d7
	eor.w		d7,d4
	rts
	nop

	eor.w		d4,d7
	rts

mode_7:
	not.w		d6
	and.w		d6,d7
	or.w		d7,d4
	rts
	nop

	or.w		d4,d7
	rts

mode_8:
	not.w		d6
	and.w		d6,d7
	or.w		d7,d4
	eor.w		d6,d4
	rts

	or.w		d4,d7
	not.w		d7
	rts

mode_9:
	not.w		d6
	and.w		d6,d7
	eor.w		d7,d4
	eor.w		d6,d4
	rts

	eor.w		d4,d7
	not.w		d7
	rts

mode_a:
	not.w		d6
	eor.w		d6,d4
	rts
	nop
	nop

	not.w		d4
	move.w		d4,d7
	rts

mode_b:
	not.w		d6
	and.w		d6,d7
	eor.w		d6,d4
	or.w		d7,d4
	rts

	not.w		d4
	or.w		d4,d7
	rts

mode_c:
	not.w		d6
	or.w		d6,d4
	and.w		d6,d7
	eor.w		d7,d4
	rts

	not.w		d7
	rts

mode_d:
	not.w		d6
	not.w		d7
	and.w		d6,d7
	or.w		d7,d4
	rts

	not.w		d7
	or.w		d4,d7
	rts

mode_e:
	or.w		d6,d7
	and.w		d7,d4
	not.w		d6
	eor.w		d6,d4
	rts

	and.w		d4,d7
	not.w		d7
	rts

mode_f:
	not.w		d6
	or.w		d6,d4
	rts
	nop
	nop

	moveq		#-1,d7
	rts


	.data

operations:
	.long		mode_0,mode_1,mode_2,mode_3,mode_4,mode_5,mode_6,mode_7
	.long		mode_8,mode_9,mode_a,mode_b,mode_c,mode_d,mode_e,mode_f

	.end
