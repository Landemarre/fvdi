#!make -f
#
# This software is licensed under the GNU General Public License.
# Please, see LICENSE.TXT for further information.
#

#
# gcc >= 2.95.3 (sparemint) version
#

TARGET = saga16.sys

all: $(TARGET)

top_srcdir = ../..

include $(top_srcdir)/CONFIGVARS

CPU     = 040

CFLAGS  = -m68$(CPU) -mshort -O2 -fomit-frame-pointer -DWITHOUT_BOTH -I$(top_srcdir)/include -I$(top_srcdir)/drivers/include $(M68K_ATARI_MINT_CFLAGS) -Wall
ASFLAGS = -m68$(CPU) -DWITHOUT_BOTH -I$(top_srcdir)/include -I$(top_srcdir)/drivers/include

LDFLAGS = $(M68K_ATARI_MINT_LDFLAGS) --mprg-flags=7
#-L/usr/local/m68k-atari-mint/usr/lib
#CFLAGS += -I/usr/local/m68k-atari-mint/usr/include
#LIBS    = -L/lib/gcc-lib/m68k-atari-mint/2.95.3/ -lgcc

SINCSRC = \
	$(top_srcdir)/include/compiler.inc \
	$(top_srcdir)/include/macros.inc \
	$(top_srcdir)/include/types.inc \
	$(top_srcdir)/include/vdi.inc \
	$(top_srcdir)/drivers/include/linea.inc \
	$(top_srcdir)/drivers/include/pixelmac.inc \
	$(top_srcdir)/drivers/1_plane/1_expand.inc

SSRC = \
	../common/c_common.s \
	../common/common.s \
	../common/clip.s \
	../common/lineachk.s \
	../16_bitv4/fast.s

CSRC = \
	../common/init.c \
	../common/colours.c \
	sag_spec.c \
	saga.c \
	saga_pll.c \
	../16_bitv4/16b_exp.c \
	../16_bitv4/16b_blit.c \
	../16_bitv4/16b_line.c \
	../16_bitv4/16b_fill.c \
	../16_bitv4/16b_scr.c \
	../16_bitv4/16b_pal.c \
    ../saga/sag_mous.c
#	../uaegfx/uae_mous.c

# handle DevPac -> gas conversions
# defines SSRC_GNU and SINCSRC_GNU variables
include $(top_srcdir)/utility/conv2gas/RULES

# need to convert the .inc file as well
$(SSRC_GNU): $(SINCSRC_GNU)

# engine binary objects
OBJECTS = $(SSRC_GNU:.gnu=.gnu.o) $(CSRC:.c=.o)

$(TARGET): depend $(OBJECTS) $(LIBFILES)
	$(LD) -o $@ $(OBJECTS) $(LDFLAGS) $(LIBS)

depend: $(CSRC)
#	"$(CC) -MM" does not seem able to keep track of the directory of the
#	object file, so dependencies of files outside this directory are
#	never taken into account later. makedepend does this correctly.
#	Unfortunately, makedepend includes system headers in its
#	dependency lists, but you can't get everything...
#	$(CC) -MM $(CFLAGS) $(CSRC) > depend
	makedepend -f- -- $(CFLAGS) $(CSRC) > depend 2> /dev/null
	sed "s#\/usr[^ ]*\.h##g" < depend  > depend2
	sed "s#^.*: *\$$##"      < depend2 > depend
	rm depend2

strip:
	$(STRIP) --strip-all $(TARGET)

clean: clean_gnu
	rm -rf $(OBJECTS)
	rm depend

include depend
