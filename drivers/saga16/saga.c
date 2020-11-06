/*
 * saga.c - SAGA specific functions
 * This is part of the SAGA driver for fVDI
 * Most of the code here come from the SAGA Picasso96 driver.
 * https://github.com/ezrec/saga-drivers/tree/master/saga.card
 * Glued by Vincent Riviere
 */

/*
 * Copyright (C) 2016, Jason S. McMullan <jason.mcmullan@gmail.com>
 * All rights reserved.
 *
 * Licensed under the MIT License:
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

#include "../../include/fvdi.h"
#include "../include/driver.h"
#include "saga.h"
#include "video.h"
#include "board.h"
#include <mint/falcon.h>

/* The delta allows negative positioning */
#define SAGA_MOUSE_DELTAX  16
#define SAGA_MOUSE_DELTAY  8



void saga_set_modeline(struct ModeInfo *mi, UBYTE Format)
{
	mi->setscreenmode |= (UWORD)Format;		
}


 
 
void saga_set_panning(struct ModeInfo *mi,UBYTE *mem)
{
  /*  Write32(SAGA_VIDEO_PLANEPTR, (IPTR)mem);*/
    VsetScreen(mem,mem,3,mi->setscreenmode /*0x4|0x8|0x10*/);
}

void saga_set_mouse_position(short x, short y)
{
	if (x < -16)
	{
		/* put position outside window */
		Write16(SAGA_VIDEO_SPRITEX, SAGA_VIDEO_MAXHV - 1);
		Write16(SAGA_VIDEO_SPRITEY, SAGA_VIDEO_MAXVV - 1);
	} else
	{
		UBYTE boardid = ( *(volatile UWORD*)VREG_BOARD ) >> 8;
		
		if (boardid == VREG_BOARD_V4SA)
		{
			x += SAGA_MOUSE_DELTAX;
			y += SAGA_MOUSE_DELTAY;
		}
		Write16(SAGA_VIDEO_SPRITEX, x);
		Write16(SAGA_VIDEO_SPRITEY, y);
	}
}


static unsigned short rgb16to4(unsigned short color)
{
	/*
	 * Input : 0xRRRRRGGGGGGBBBBB
	 * Output: 0x0000RRRRGGGGBBBB
	 */
	return ((color >> 4) & 0xf00) |
	       ((color >> 3) & 0x0f0) |
	       ((color >> 1) & 0x00f);
}


/*
 * In amiga sprites, each pixel can be one of three colors
 * or transparent. Figure below shows how the color of each pixel in a sprite
 *  is determined.
 * 
 *                                                  high-order word of
 *                                                   sprite data line
 *    _______________________________
 *   |            _|#|_              |    _ _0 0 0 0 0 1 1 1 0 1 1 1 0 0 0 0
 *   |          _|o|#|o|_            |   |
 *   |_ _ _ _ _|o|o|#|o|o|_ _ _ _ _ _|       |
 *   |_|_|_|_|#|#|#|_|#|#|#|_|_|_|_|_|- -|   |
 *   |    |    |o|o|#|o|o|           |       |
 *   |    |      |o|#|o|             |   |_ _|_0 0 0 0 0 1 1 1 0 1 1 1 0 0 0 0
 *   |____|________|#|_______________|       |
 *        |                                  | |      low-order word of
 *        |                                  | |      sprite data line
 *                                           | |
 *   transparent                             | |
 *                  Forms a binary code,
 *                    used as the color  --> 0 0
 *                  choice from a group
 *                   of color registers.
 *
 * For our purposes, we set index 1 to the mask color,
 * and index 2&3 to the data color of the mouse definition
 */

void saga_set_mouse_sprite(Workstation *wk, Mouse *mouse)
{
	unsigned short fg, bg;
	Colour *global_palette;
	unsigned short *realp;
	unsigned short mousedata[2 * 16];
	unsigned long *lp;
	int i;
	
	/* c_get_colour(wk, *pp, &foreground, &background); */
	global_palette = wk->screen.palette.colours;
	realp = (unsigned short *)&global_palette[wk->mouse.colour.foreground].real;
	fg = *realp;
	realp = (unsigned short *)&global_palette[wk->mouse.colour.background].real;
	bg = *realp;

	fg = rgb16to4(fg);
	bg = rgb16to4(bg);

	/* SAGA HW MOUSE => COLORS */
	Write16(SAGA_VIDEO_SPRITECLUT + 0, bg);  /* COLOR1 */
	Write16(SAGA_VIDEO_SPRITECLUT + 2, fg);  /* COLOR2 */
	Write16(SAGA_VIDEO_SPRITECLUT + 4, fg);  /* COLOR3 */
	
	/* SAGA HW MOUSE => BITPLANES DATA */
	for (i = 0; i < 16; i++)
	{
		mousedata[i * 2 + 0] = mouse->mask[i];
		mousedata[i * 2 + 1] = mouse->data[i];
	}
	lp = (unsigned long *)mousedata;
	for (i = 0; i < 16; i++)
		Write32(SAGA_VIDEO_SPRITEBPL + i * 4, lp[i]);
}

