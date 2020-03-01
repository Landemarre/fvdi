/*
 * A  32 bit graphics mono-expand routine, by Olivier Landemarre.
 * adaptation from 16 bit routine Johan Klockars 
 *
 * This file is an example of how to write an
 * fVDI device driver routine in C.
 *
 * You are encouraged to use this file as a starting point
 * for other accelerated features, or even for supporting
 * other graphics modes. This file is therefore put in the
 * public domain. It's not copyrighted or under any sort
 * of license.
 */

#if 1
#define FAST		/* Write in FastRAM buffer */
#define BOTH		/* Write in both FastRAM and on screen */
#else
#undef FAST
#undef BOTH
#endif

#ifdef WITHOUT_BOTH
#undef BOTH
#undef FAST
#endif

#include "fvdi.h"

#include <os.h>
#define PIXEL		unsigned long
#define PIXEL_SIZE	sizeof(PIXEL)

extern void CDECL c_get_colour(Virtual *vwk, long colour, PIXEL *foreground, PIXEL *background);

/*
 * Make it as easy as possible for the C compiler.
 * The current code is written to produce reasonable results with Lattice C.
 * (long integers, optimize: [x xx] time)
 * - One function for each operation -> more free registers
 * - 'int' is the default type
 * - some compilers aren't very smart when it comes to *, / and %
 * - some compilers can't deal well with *var++ constructs
 */

#ifdef BOTH
static void s_replace(short *src_addr, int src_line_add, PIXEL *dst_addr, PIXEL *dst_addr_fast, int dst_line_add, int x, int w, int h, PIXEL foreground, PIXEL background)
{
	int i, j;
	unsigned int expand_word, mask;

	x = 1 << (15 - (x & 0x000f));

	for(i = h - 1; i >= 0; i--) {
		expand_word = *src_addr++;
		mask = x;
		for(j = w - 1; j >= 0; j--) {
			if (expand_word & mask) 
				*dst_addr_fast++ = foreground;
				*dst_addr++ = foreground;
			} else {
				*dst_addr_fast++ = background;
				*dst_addr++ = background;
			}
			if (!(mask >>= 1)) {
				mask = 0x8000;
				expand_word = *src_addr++;
			}
		}
		src_addr += src_line_add;
		dst_addr += dst_line_add;
		dst_addr_fast += dst_line_add;
	}
}

static void s_transparent(short *src_addr, int src_line_add, PIXEL *dst_addr, PIXEL *dst_addr_fast, int dst_line_add, int x, int w, int h, PIXEL foreground, PIXEL background)
{
	int i, j;
	unsigned int expand_word, mask;

	x = 1 << (15 - (x & 0x000f));

	for(i = h - 1; i >= 0; i--) {
		expand_word = *src_addr++;
		mask = x;
		for(j = w - 1; j >= 0; j--) {
			if (expand_word & mask) {
				*dst_addr_fast++ = foreground;
				*dst_addr++ = foreground;
			} else {
				dst_addr_fast++;
				dst_addr++;
			}
			if (!(mask >>= 1)) {
				mask = 0x8000;
				expand_word = *src_addr++;
			}
		}
		src_addr += src_line_add;
		dst_addr += dst_line_add;
		dst_addr_fast += dst_line_add;
	}
}

static void s_xor(short *src_addr, int src_line_add, PIXEL *dst_addr, PIXEL *dst_addr_fast, int dst_line_add, int x, int w, int h, PIXEL foreground, PIXEL background)
{
	int i, j;
	PIXEL v;
	unsigned int expand_word, mask;

	x = 1 << (15 - (x & 0x000f));

	for(i = h - 1; i >= 0; i--) {
		expand_word = *src_addr++;
		mask = x;
		for(j = w - 1; j >= 0; j--) {
			if (expand_word & mask) {
				v = ~*dst_addr_fast;
				*dst_addr++ = v;
				*dst_addr++ = v;
			} else {
				dst_addr_fast++;
				dst_addr++;
			}
			if (!(mask >>= 1)) {
				mask = 0x8000;
				expand_word = *src_addr++;
			}
		}
		src_addr += src_line_add;
		dst_addr += dst_line_add;
		dst_addr_fast += dst_line_add;
	}
}

static void s_revtransp(short *src_addr, int src_line_add, PIXEL *dst_addr, PIXEL *dst_addr_fast, int dst_line_add, int x, int w, int h, PIXEL foreground, PIXEL background)
{
	int i, j;
	unsigned int expand_word, mask;

	x = 1 << (15 - (x & 0x000f));

	for(i = h - 1; i >= 0; i--) {
		expand_word = *src_addr++;
		mask = x;
		for(j = w - 1; j >= 0; j--) {
			if (!(expand_word & mask)) {
				*dst_addr_fast++ = foreground;
				*dst_addr++ = foreground;
			} else {
				dst_addr_fast++;
				dst_addr++;
			}
			if (!(mask >>= 1)) {
				mask = 0x8000;
				expand_word = *src_addr++;
			}
		}
		src_addr += src_line_add;
		dst_addr += dst_line_add;
		dst_addr_fast += dst_line_add;
	}
}

#define BOTH_WAS_ON
#endif
#undef BOTH

/*
 * The functions below are exact copies of those above.
 * The '#undef BOTH' makes sure that this works as it should
 * when no shadow buffer is available
 */

static void replace(short *src_addr, int src_line_add, PIXEL *dst_addr, PIXEL *dst_addr_fast, int dst_line_add, int x, int w, int h, PIXEL foreground, PIXEL background)
{
	int i, j;
	unsigned int expand_word, mask;

	x = 1 << (15 - (x & 0x000f));

	for(i = h - 1; i >= 0; i--) {
		expand_word = *src_addr++;
		mask = x;
		for(j = w - 1; j >= 0; j--) {
			if (expand_word & mask) {
				*dst_addr++ = foreground;
			} else {

				*dst_addr++ = background;
			}
			if (!(mask >>= 1)) {
				mask = 0x8000;
				expand_word = *src_addr++;
			}
		}
		src_addr += src_line_add;
		dst_addr += dst_line_add;
	}
}


static void transparent(short *src_addr, int src_line_add, PIXEL *dst_addr, PIXEL *dst_addr_fast, int dst_line_add, int x, int w, int h, PIXEL foreground, PIXEL background)
{
	int i, j;
	unsigned int expand_word, mask;

	x = 1 << (15 - (x & 0x000f));

	for(i = h - 1; i >= 0; i--) {
		expand_word = *src_addr++;
		mask = x;
		for(j = w - 1; j >= 0; j--) {
			if (expand_word & mask) {
				*dst_addr++ = foreground;
			} else {
				dst_addr++;
			}
			if (!(mask >>= 1)) {
				mask = 0x8000;
				expand_word = *src_addr++;
			}
		}
		src_addr += src_line_add;
		dst_addr += dst_line_add;
	}
}

/*
static void transparent(short *src_addr, int src_line_add, PIXEL *dst_addr, PIXEL *dst_addr_fast, int dst_line_add, int x, int w, int h, PIXEL foreground, PIXEL background)
{
	int i, j;
	unsigned short expand_word, mask;

	if((x==0)&&(((w%16)==0)))
	{
		for(i = h - 1; i >= 0; i--) {
			
			for(j = w - 1; j >= 0; j-=16) {	
				expand_word = (unsigned short)*src_addr++;
				if(expand_word == 0)
				{
					dst_addr+=16;
				}
				else
				{
					if((expand_word&0xFF00) == 0)
					{
						dst_addr+=8;
					}
					else
					{
						if((expand_word&0xF000) == 0)
						{
							dst_addr+=4;
						}
						else
						{	unsigned short val;
							val=(expand_word&0xF000)>>12;
							switch (val) {
								case 1:
									dst_addr+=3;
									*dst_addr++=foreground;
								break;
								case 2:
									dst_addr+=2;
									*dst_addr++=foreground;
									dst_addr++;
								break;
								case 3:
									dst_addr+=2;
									*dst_addr++=foreground;
									*dst_addr++=foreground;
								break;
								case 4:
									dst_addr++;
									*dst_addr++=foreground;
									dst_addr+=2;
								break;
								case 5:
									dst_addr++;
									*dst_addr++=foreground;
									dst_addr++;
									*dst_addr++=foreground;
								break;
								case 6:
									dst_addr++;
									*dst_addr++=foreground;
									*dst_addr++=foreground;
									dst_addr++;	
								break;
								case 7:
									dst_addr++;
									*dst_addr++=foreground;
									*dst_addr++=foreground;
									*dst_addr++=foreground;	
								break;
								case 8:
									*dst_addr=foreground;
									dst_addr+=4;
								break;
								case 9:
									*dst_addr=foreground;
									dst_addr+=3;
									*dst_addr++=foreground;
								break;
								case 10:
									*dst_addr=foreground;
									dst_addr+=2;
									*dst_addr++=foreground;
									dst_addr++;
								break;
								case 11:
									*dst_addr=foreground;
									dst_addr+=2;
									*dst_addr++=foreground;
									*dst_addr++=foreground;
								break;
								case 12:
									*dst_addr++=foreground;
									*dst_addr++=foreground;
									dst_addr+=2;
								break;
								case 13:
									*dst_addr++=foreground;
									*dst_addr++=foreground;
									dst_addr++;
									*dst_addr++=foreground;
								break;
								case 14:
									*dst_addr++=foreground;
									*dst_addr++=foreground;
									*dst_addr++=foreground;
									dst_addr++;
								break;
								case 15:
									*dst_addr++=foreground;
									*dst_addr++=foreground;
									*dst_addr++=foreground;
									*dst_addr++=foreground;
								break;
							} 
						}
						if((expand_word&0x0F00) == 0)
						{
							dst_addr+=4;
						}
						else
						{	unsigned short val;
							val=(expand_word&0x0F00)>>8;
							switch (val) {
								case 1:
									dst_addr+=3;
									*dst_addr++=foreground;
								break;
								case 2:
									dst_addr+=2;
									*dst_addr++=foreground;
									dst_addr++;
								break;
								case 3:
									dst_addr+=2;
									*dst_addr++=foreground;
									*dst_addr++=foreground;
								break;
								case 4:
									dst_addr++;
									*dst_addr++=foreground;
									dst_addr+=2;
								break;
								case 5:
									dst_addr++;
									*dst_addr++=foreground;
									dst_addr++;
									*dst_addr++=foreground;
								break;
								case 6:
									dst_addr++;
									*dst_addr++=foreground;
									*dst_addr++=foreground;
									dst_addr++;	
								break;
								case 7:
									dst_addr++;
									*dst_addr++=foreground;
									*dst_addr++=foreground;
									*dst_addr++=foreground;	
								break;
								case 8:
									*dst_addr=foreground;
									dst_addr+=4;
								break;
								case 9:
									*dst_addr=foreground;
									dst_addr+=3;
									*dst_addr++=foreground;
								break;
								case 10:
									*dst_addr=foreground;
									dst_addr+=2;
									*dst_addr++=foreground;
									dst_addr++;
								break;
								case 11:
									*dst_addr=foreground;
									dst_addr+=2;
									*dst_addr++=foreground;
									*dst_addr++=foreground;
								break;
								case 12:
									*dst_addr++=foreground;
									*dst_addr++=foreground;
									dst_addr+=2;
								break;
								case 13:
									*dst_addr++=foreground;
									*dst_addr++=foreground;
									dst_addr++;
									*dst_addr++=foreground;
								break;
								case 14:
									*dst_addr++=foreground;
									*dst_addr++=foreground;
									*dst_addr++=foreground;
									dst_addr++;
								break;
								case 15:
									*dst_addr++=foreground;
									*dst_addr++=foreground;
									*dst_addr++=foreground;
									*dst_addr++=foreground;
								break;
							} 
						}
					}
					if((expand_word&0x00FF) == 0)
					{
						dst_addr+=8;
					}
					else
					{
						if((expand_word&0x00F0) == 0)
						{
							dst_addr+=4;
						}
						else
						{	unsigned short val;
							val=(expand_word&0x00F0)>>4;
							switch (val) {
								case 1:
									dst_addr+=3;
									*dst_addr++=foreground;
								break;
								case 2:
									dst_addr+=2;
									*dst_addr++=foreground;
									dst_addr++;
								break;
								case 3:
									dst_addr+=2;
									*dst_addr++=foreground;
									*dst_addr++=foreground;
								break;
								case 4:
									dst_addr++;
									*dst_addr++=foreground;
									dst_addr+=2;
								break;
								case 5:
									dst_addr++;
									*dst_addr++=foreground;
									dst_addr++;
									*dst_addr++=foreground;
								break;
								case 6:
									dst_addr++;
									*dst_addr++=foreground;
									*dst_addr++=foreground;
									dst_addr++;	
								break;
								case 7:
									dst_addr++;
									*dst_addr++=foreground;
									*dst_addr++=foreground;
									*dst_addr++=foreground;	
								break;
								case 8:
									*dst_addr=foreground;
									dst_addr+=4;
								break;
								case 9:
									*dst_addr=foreground;
									dst_addr+=3;
									*dst_addr++=foreground;
								break;
								case 10:
									*dst_addr=foreground;
									dst_addr+=2;
									*dst_addr++=foreground;
									dst_addr++;
								break;
								case 11:
									*dst_addr=foreground;
									dst_addr+=2;
									*dst_addr++=foreground;
									*dst_addr++=foreground;
								break;
								case 12:
									*dst_addr++=foreground;
									*dst_addr++=foreground;
									dst_addr+=2;
								break;
								case 13:
									*dst_addr++=foreground;
									*dst_addr++=foreground;
									dst_addr++;
									*dst_addr++=foreground;
								break;
								case 14:
									*dst_addr++=foreground;
									*dst_addr++=foreground;
									*dst_addr++=foreground;
									dst_addr++;
								break;
								case 15:
									*dst_addr++=foreground;
									*dst_addr++=foreground;
									*dst_addr++=foreground;
									*dst_addr++=foreground;
								break;
							} 
						}
						if((expand_word&0x000F) == 0)
						{
							dst_addr+=4;
						}
						else
						{	unsigned short val;
							val=(expand_word&0x000F);
							switch (val) {
								case 1:
									dst_addr+=3;
									*dst_addr++=foreground;
								break;
								case 2:
									dst_addr+=2;
									*dst_addr++=foreground;
									dst_addr++;
								break;
								case 3:
									dst_addr+=2;
									*dst_addr++=foreground;
									*dst_addr++=foreground;
								break;
								case 4:
									dst_addr++;
									*dst_addr++=foreground;
									dst_addr+=2;
								break;
								case 5:
									dst_addr++;
									*dst_addr++=foreground;
									dst_addr++;
									*dst_addr++=foreground;
								break;
								case 6:
									dst_addr++;
									*dst_addr++=foreground;
									*dst_addr++=foreground;
									dst_addr++;	
								break;
								case 7:
									dst_addr++;
									*dst_addr++=foreground;
									*dst_addr++=foreground;
									*dst_addr++=foreground;	
								break;
								case 8:
									*dst_addr=foreground;
									dst_addr+=4;
								break;
								case 9:
									*dst_addr=foreground;
									dst_addr+=3;
									*dst_addr++=foreground;
								break;
								case 10:
									*dst_addr=foreground;
									dst_addr+=2;
									*dst_addr++=foreground;
									dst_addr++;
								break;
								case 11:
									*dst_addr=foreground;
									dst_addr+=2;
									*dst_addr++=foreground;
									*dst_addr++=foreground;
								break;
								case 12:
									*dst_addr++=foreground;
									*dst_addr++=foreground;
									dst_addr+=2;
								break;
								case 13:
									*dst_addr++=foreground;
									*dst_addr++=foreground;
									dst_addr++;
									*dst_addr++=foreground;
								break;
								case 14:
									*dst_addr++=foreground;
									*dst_addr++=foreground;
									*dst_addr++=foreground;
									dst_addr++;
								break;
								case 15:
									*dst_addr++=foreground;
									*dst_addr++=foreground;
									*dst_addr++=foreground;
									*dst_addr++=foreground;
								break;
							} 
						}
					}
				}
			}
			src_addr += src_line_add;
			dst_addr += dst_line_add;
		}
	}
	else
	{
	x = 1 << (15 - (x & 0x000f));

	for(i = h - 1; i >= 0; i--) {
		expand_word = *src_addr++;
		mask = x;
		for(j = w - 1; j >= 0; j--) {
			if (expand_word & mask) {
				*dst_addr++ = foreground;
			} else {
				dst_addr++;
			}
			if (!(mask >>= 1)) {
				mask = 0x8000;
				expand_word = *src_addr++;
			}
		}
		src_addr += src_line_add;
		dst_addr += dst_line_add;
	}
	}
}*/


static void xor(short *src_addr, int src_line_add, PIXEL *dst_addr, PIXEL *dst_addr_fast, int dst_line_add, int x, int w, int h, PIXEL foreground, PIXEL background)
{
	int i, j;
	unsigned int expand_word, mask;
	PIXEL v;

	x = 1 << (15 - (x & 0x000f));
	
	for(i = h - 1; i >= 0; i--) {
		expand_word = *src_addr++;
		mask = x;
		for(j = w - 1; j >= 0; j--) {
			if (expand_word & mask) {
				v =  ~*dst_addr;
				*dst_addr++ = v;
			} else {

				dst_addr++;
			}
			if (!(mask >>= 1)) {
				mask = 0x8000;
				expand_word = *src_addr++;
			}
		}
		src_addr += src_line_add;
		dst_addr += dst_line_add;

	}
	
}

static void revtransp(short *src_addr, int src_line_add, PIXEL *dst_addr, PIXEL *dst_addr_fast, int dst_line_add, int x, int w, int h, PIXEL foreground, PIXEL background)
{
	int i, j;
	unsigned int expand_word, mask;

	x = 1 << (15 - (x & 0x000f));

	for(i = h - 1; i >= 0; i--) {
		expand_word = *src_addr++;
		mask = x;
		for(j = w - 1; j >= 0; j--) {
			if (!(expand_word & mask)) {

				*dst_addr++ = foreground;
			} else {

				dst_addr++;
			}
			if (!(mask >>= 1)) {
				mask = 0x8000;
				expand_word = *src_addr++;
			}
		}
		src_addr += src_line_add;
		dst_addr += dst_line_add;

	}
}

#ifdef BOTH_WAS_ON
#define BOTH
#endif

long CDECL c_expand_area(Virtual *vwk, MFDB *src, long src_x, long src_y, MFDB *dst, long dst_x, long dst_y, long w, long h, long operation, long colour)
{
	Workstation *wk;
	short *src_addr;
	PIXEL *dst_addr, *dst_addr_fast;
	PIXEL foreground, background;
	int src_wrap, dst_wrap;
	int src_line_add, dst_line_add;
	unsigned long src_pos, dst_pos;
	int to_screen;

	wk = vwk->real_address;

	c_get_colour(vwk, colour, &foreground, &background);

	src_wrap = (long)src->wdwidth * 2;		/* Always monochrome */
	src_addr = src->address;
	src_pos = (short)src_y * (long)src_wrap + (src_x >> 4) * 2;
	src_line_add = src_wrap - (((src_x + w) >> 4) - (src_x >> 4) + 1) * 2;

	to_screen = 0;
	if (!dst || !dst->address || (dst->address == wk->screen.mfdb.address)) {		/* To screen? */
		dst_wrap = wk->screen.wrap;
		dst_addr = wk->screen.mfdb.address;
		to_screen = 1;
	} else {
		dst_wrap = (long)dst->wdwidth * 2 * dst->bitplanes;
		dst_addr = dst->address;
	}
	dst_pos = (short)dst_y * (long)dst_wrap + dst_x * PIXEL_SIZE;
	dst_line_add = dst_wrap - w * PIXEL_SIZE;

	src_addr += src_pos / 2;
	dst_addr += dst_pos / PIXEL_SIZE;
	src_line_add /= 2;
	dst_line_add /= PIXEL_SIZE;			/* Change into pixel count */

	dst_addr_fast = wk->screen.shadow.address;	/* May not really be to screen at all, but... */

#ifdef BOTH
	if (!to_screen || !dst_addr_fast) {
#endif
		switch (operation) {
		case 1:				/* Replace */
			replace(src_addr, src_line_add, dst_addr, 0, dst_line_add, src_x, w, h, foreground, background);
			break;
		case 2:				/* Transparent */
			transparent(src_addr, src_line_add, dst_addr, 0, dst_line_add, src_x, w, h, foreground, background);
			break;
		case 3:				/* XOR */
			xor(src_addr, src_line_add, dst_addr, 0, dst_line_add, src_x, w, h, foreground, background);
			break;
		case 4:				/* Reverse transparent */
			revtransp(src_addr, src_line_add, dst_addr, 0, dst_line_add, src_x, w, h, foreground, background);
			break;
		}
#ifdef BOTH
	} else {
		dst_addr_fast += dst_pos / PIXEL_SIZE;
		switch (operation) {
		case 1:				/* Replace */
			s_replace(src_addr, src_line_add, dst_addr, dst_addr_fast, dst_line_add, src_x, w, h, foreground, background);
			break;
		case 2:				/* Transparent */
			s_transparent(src_addr, src_line_add, dst_addr, dst_addr_fast, dst_line_add, src_x, w, h, foreground, background);
			break;
		case 3:				/* XOR */
			s_xor(src_addr, src_line_add, dst_addr, dst_addr_fast, dst_line_add, src_x, w, h, foreground, background);
			break;
		case 4:				/* Reverse transparent */
			s_revtransp(src_addr, src_line_add, dst_addr, dst_addr_fast, dst_line_add, src_x, w, h, foreground, background);
			break;
		}
	}
#endif
	return 1;		/* Return as completed */
}
