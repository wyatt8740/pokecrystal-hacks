PYTHON := python

.SUFFIXES:
.SUFFIXES: .asm .tx .o .gbc .png .2bpp .1bpp .lz .pal .bin .blk .tilemap
.PHONY: all clean crystal pngs
.SECONDEXPANSION:

poketools := extras/pokemontools
gfx       := $(PYTHON) $(poketools)/gfx.py
includes  := $(PYTHON) $(poketools)/scan_includes.py


crystal_obj := \
wram.o \
main.o \
lib/mobile/main.o \
home.o \
audio.o \
maps_crystal.o \
engine/events_crystal.o \
engine/credits_crystal.o \
data/egg_moves_crystal.o \
data/evos_attacks_crystal.o \
data/pokedex/entries_crystal.o \
misc/crystal_misc.o \
gfx/pics.o

all_obj := $(crystal_obj)

# object dependencies
$(foreach obj, $(all_obj), \
	$(eval $(obj:.o=)_dep := $(shell $(includes) $(obj:.o=.asm))) \
)


roms := pokecrystal.gbc

all: $(roms)
crystal: pokecrystal.gbc

clean:
	rm -f $(roms) $(all_obj)
	find . -iname '*.tx' -exec rm {} +

baserom.gbc: ;
	@echo "Wait! Need baserom.gbc first. Check README and INSTALL for details." && false


%.asm: ;
$(all_obj): $$*.asm $$($$*_dep)
	@$(gfx) 2bpp $(2bppq); $(eval 2bppq :=)
	@$(gfx) 1bpp $(1bppq); $(eval 1bppq :=)
	@$(gfx) lz   $(lzq);   $(eval lzq   :=)
	rgbasm -o $@ $<

pokecrystal.gbc: $(crystal_obj)
	rgblink -n $*.sym -m $*.map -o $@ $^
	rgbfix -Cjv -i BYTE -k 01 -l 0x33 -m 0x10 -p 0 -r 3 -t PM_CRYSTAL $@
	#cmp baserom.gbc $@


pngs:
	find . -iname "*.lz"      -exec $(gfx) unlz {} +
	find . -iname "*.[12]bpp" -exec $(gfx) png  {} +
	find . -iname "*.lz"      -exec touch {} +
	find . -iname "*.[12]bpp" -exec touch {} +

%.2bpp: %.png ; $(eval 2bppq += $<) @rm -f $@
%.1bpp: %.png ; $(eval 1bppq += $<) @rm -f $@
%.lz:   %     ; $(eval lzq   += $<) @rm -f $@


%.pal: ;
%.bin: ;
%.blk: ;
%.tilemap: ;

