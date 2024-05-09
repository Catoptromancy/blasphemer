# SPDX-License-Identifier: BSD-3-Clause

WADS=wads
SNDCURVE=scripts/blasphemer_sndcurve.py
DEUTEX=deutex
DEUTEX_BASIC_ARGS=-v0 -rate accept
DEUTEX_ARGS=$(DEUTEX_BASIC_ARGS) -heretic bootstrap/

BLASPHEM=$(WADS)/blasphem.wad
BLASPHDM=$(WADS)/blasphdm.wad

blasphem.wad: lumps/sndcurve.lmp
	mkdir -p $(WADS)
	$(DEUTEX) $(DEUTEX_ARGS) -iwad -make $(BLASPHEM)
	$(DEUTEX) $(DEUTEX_ARGS) -iwad -make BlasphDM.txt $(BLASPHDM)
	zip blasphem.zip $(BLASPHEM)
	zip blasphdm.zip $(BLASPHDM)

lumps/sndcurve.lmp: scripts/blasphemer_sndcurve.py
	python scripts/blasphemer_sndcurve.py

clean: 
	rm $(BLASPHEM)
	rm $(BLASPHDM)
	rmdir $(WADS)
	rm blasphem.zip
	rm blasphdm.zip

prefix?=/usr/local
docdir?=/share/doc
mandir?=/share/man
waddir?=/share/games/doom
target=$(DESTDIR)$(prefix)

install:
	install -Dm 644 $(BLASPHEM) -t "$(target)$(waddir)"

uninstall:
	rm "$(target)$(waddir)/blasphem.wad" 

