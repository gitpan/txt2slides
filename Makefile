#
# Generic class slides and materials makefile

# Name of the class
# CLASS=

# Name of slide source file
SLIDES=$(CLASS).slides

AMBLES=./POSTAMBLE ./INAMBLE ./PREAMBLE ./TOC_HEAD ./TOC_TAIL

# Pictures that will be manufactured from source (such as PIC instructions)
PICS +=

# Canned pictures that should be included in distribution
EXTRAPICS += 

# Files with program source code (.pl and .pm files, typically)
# You only need to include the ones that will be included in the distribution.
SOURCEFILES +=

# Result printable source code files (typically .ps)
SOURCELISTINGS +=

# Any extra files that should be built and included in the distribution
EXTRAFILES += $(SOURCEFILES) $(SOURCELISTINGS) 

DISTFILES += $(EXTRAFILES)

.SUFFIXES: .ps .gif .pic .pl .pcl .html .pdf .dvi 

# -nt -nk -a
A2PS= a2ps -l66 -nL -p -nP -1 -Xletter
# -l66: 66 lines per page
# -nt: no translation of special keywords to symbols
# -nL: no 'login ID' ("Printed by Dominus from plover")
# -nk: No 'pretty' printing (idiotic boldfacing of least important words)
# -a: alternative (letter) paper size
# -p: portrait mode
# -nP: deliver PS to stdout instead of to printer
# -1: one-up format
# -Xletter: Letter-sized paper, not A4.

MAKE_SLIDES=./make-slides $(MSFLAGS)

.pl.ps:
	$(A2PS) $*.pl > $*.ps

.pm.ps:
	$(A2PS) $*.pl > $*.ps

.tex.dvi: 
	latex $*.tex

.dvi.ps:
	dvips -o $*.ps $*.dvi

.html.ps: 
	htmltops $*.html

.ps.pcl:
	pstopcl < $*.ps > $*.pcl

.ps.gif: 
	ps2gif < $*.ps > $*.gif

.pic.ps: 
	pic $*.pic | groff > $*.ps

.ps.pdf:
	ps2pdf $*.ps > $*.pdf

default: sourcelistings $(PICS) $(EXTRAFILES) .Slides.done 

warnings: .Slides.done printable
	@perl -nle 'if (/^%%Pages:\s+(\d+)/) { print "$$ARGV: $$1 pages" if $$1 > 1;}' slide*.ps
	@checkslideimages $(PICS) $(EXTRAPICS)

.Slides.done: $(SLIDES) $(MAKE_SLIDES) $(AMBLES) Makefile
	$(MAKE_SLIDES) $(RECENT) < $(CLASS).slides
	touch .Slides.done

tgz tar dist: $(CLASS).tgz

$(AMBLES): 
	touch $@

zip: $(CLASS).zip

$(CLASS).tgz: default $(DISTFILES)
	tar zcf $(CLASS).tgz TABLE*html $(PICS) $(EXTRAPICS) slide*html  $(DISTFILES)

$(CLASS).zip: default $(DISTFILES)
	zip $(CLASS).zip TABLE*html $(PICS) $(EXTRAPICS) slide*html $(DISTFILES)

printable: .ps.done

sourcelistings: .sourcelistings.done

.sourcelistings.done: $(SOURCELISTINGS)
	touch .sourcelistings.done

.ps.done: .Slides.done
	htmltops `grep '[0-9].txt' .slide_names | sed -e 's/txt/html/'`
	touch .ps.done

ALLSLIDES.ps:  .ps.done
#	htmltops slide*[0-9].html
#	mypstrim slide*.ps
	mypsmerge slide*.ps > ALLSLIDES.ps

ALLSLIDES-2up.ps: ALLSLIDES.ps
	mypsup2 < ALLSLIDES.ps > ALLSLIDES-2up.ps

ALLSLIDES-4up.ps: ALLSLIDES.ps
	mypsup4 < ALLSLIDES.ps > ALLSLIDES-4up.ps

