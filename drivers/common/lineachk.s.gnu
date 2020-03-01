






	.equiv	doaline,0	
	.equiv	mul,1	
	.equiv	shift,1

	.include		"vdi.inc.gnu"
  .ifne	doaline
	.include		"linea.inc.gnu"
  .endif

	.global	_check_linea
  .ifeq		shift
	.global	dot
	.global	line
	.global	rline
  .endif
  .ifeq		mul
	.global	row
  .endif
	.global	_font_table


	.text


	


















  .ifeq	shift
dot:	.long		0x80008000,$40004000,$20002000,$10001000
	.long		0x08000800,$04000400,$02000200,$01000100
	.long		0x00800080,$00400040,$00200020,$00100010
	.long		0x00080008,$00040004,$00020002,$00010001

lline:	.long		0xffffffff,$7fff7fff,$3fff3fff,$1fff1fff
	.long		0x0fff0fff,$07ff07ff,$03ff03ff,$01ff01ff
	.long		0x00ff00ff,$007f007f,$003f003f,$001f001f
	.long		0x000f000f,$00070007,$00030003,$00010001

rline:	.long		0x80008000,$c000c000,$e000e000,$f000f000
	.long		0xf800f800,$fc00fc00,$fe00fe00,$ff00ff00
	.long		0xff80ff80,$ffc0ffc0,$ffe0ffe0,$fff0fff0
	.long		0xfff8fff8,$fffcfffc,$fffefffe,$ffffffff
  .endif

  .ifeq	mul
row:	ds.l		1024
  .endif






_check_linea:
	movem.l		d0-d3/a0-a4,-(a7)
	move.l		4+9*4(a7),a4

	.word		0xa000
	move.l		a1,_font_table
	move.l		a0,wk_screen_linea(a4)	
	move.w		2(a0),d0
	move.w		d0,wk_screen_wrap(a4)
	move.w		-12(a0),d1
	move.w		d1,wk_screen_mfdb_width(a4)
	move.w		-4(a0),d1
	move.w		d1,wk_screen_mfdb_height(a4)
	move.w		(a0),wk_screen_mfdb_bitplanes(a4)

  .ifne	doaline
	move.w		#0xffff,lnmask(a0)	
	move.w		#0,wmode(a0)	
	move.w		#0,lst_lin(a0)	
  .endif

  .ifeq	mul
	move.l		wk_screen_mfdb_address(a4),d0
	moveq		#0,d1
	move.w		wk_screen_wrap(a4),d1
	move.w		#1024-1,d7
	lea		row(pc),a0

.row_l:
	move.l		d0,(a0)+
	add.l		d1,d0
	dbra		d7,.row_l
  .endif

	movem.l	(a7)+,d0-d3/a0-a4
	rts


	.data

_font_table:
	.long		0	
	
	.end
