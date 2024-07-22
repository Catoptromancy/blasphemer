# SPDX-License-Identifier: BSD-3-Clause

# Blasphemer build script

VERSION=$(shell git describe --abbrev=8 --dirty 2>/dev/null || echo unknown)
WADS=wads
SNDCURVE=scripts/blasphemer_sndcurve.py
CPP=scripts/simplecpp
DEUTEX=deutex
DEUTEX_BASIC_ARGS=-v0 -rate accept
DEUTEX_ARGS=$(DEUTEX_BASIC_ARGS) -heretic bootstrap/

BLASPHEM=$(WADS)/blasphem.wad
BLASPHDM=$(WADS)/blasphdm.wad

OBJS=$(BLASPHEM) $(BLASPHDM)

all: deutex-check $(OBJS)

subdirs:
	#$(MAKE) VERSION=$(VERSION) -C graphics/text
	#$(MAKE) -C lumps/textures
	# WIP

#---------------------------------------------------------
# Build checks

# Make sure deutex supports PNG
deutex-check:
	@$(DEUTEX) -h | grep -qw PNG || { \
	echo "$(DEUTEX) does not support PNG. Try building deutex with the PNG"; \
	echo "libraries (libpng and libpng-devel or similar packages) installed."; \
	echo "deutex can be downloaded from https://github.com/Doom-Utils/deutex."; \
	echo "The full path to duetex can be specified by passing"; \
	echo "DEUTEX=/the/path/to/deutex to make when building Blasphemer."; \
	exit 1; }

# Make sure that no PNG files are modified if scripts are to modify them.
pngs-modified-check:
	@{ ! git status -s | grep -q \\.png$ ; }  || { \
	echo "PNG fix targets can not be run if there are modified PNGs." ; \
	exit 1; }

#---------------------------------------------------------
# BlasphDM iwad

wadinfo_blasphdm.txt : buildcfg.txt subdirs lumps/blasphem.lmp lumps/blasphdm.lmp
	$(CPP) -P -DBLASPHDM < $< > $@

$(BLASPHDM): wadinfo_blasphdm.txt subdirs
	@mkdir -p $(WADS)
	$(RM) $@
	$(DEUTEX) $(DEUTEX_ARGS) -iwad -build wadinfo_blasphdm.txt $@

#---------------------------------------------------------
# blasphemer (SOTHR) iwad

wadinfo_blasphem.txt: buildcfg.txt subdirs lumps/blasphem.lmp
	$(CPP) -P -DBLASPHEM < $< > $@

$(BLASPHEM): wadinfo_blasphem.txt subdirs
	@mkdir -p $(WADS)
	$(RM) $@
	$(DEUTEX) $(DEUTEX_ARGS) -iwad -build wadinfo_blasphem.txt $@

lumps/sndcurve.lmp: scripts/blasphemer_sndcurve.py
	python scripts/blasphemer_sndcurve.py

clean: 
	rm $(BLASPHEM)
	rm $(BLASPHDM)
	rmdir $(WADS)
	rm wadinfo_blasphem.txt
	rm wadinfo_blasphdm.txt

prefix?=/usr/local
docdir?=/share/doc
mandir?=/share/man
waddir?=/share/games/doom
target=$(DESTDIR)$(prefix)

install:
	install -Dm 644 $(BLASPHEM) -t "$(target)$(waddir)"

uninstall:
	rm "$(target)$(waddir)/blasphem.wad" 

