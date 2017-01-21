default: all

TOP = ..
include $(TOP)/Makefile.config
PERL = $(TOP)/miniperl_top

plextract = $(patsubst %.PL,%,\
	        $(filter-out Makefile.PL,$(wildcard *.PL)) )

all: $(plextract)

$(plextract): %: %.PL ../config.sh
	$(PERL) $<

$(perlname)bug: ../patchlevel.h

splain:	../lib/diagnostics.pm

zipdetails:	zipdetails.PL ../config.sh

pod2html:	pod2html.PL ../config.sh ../ext/Pod-Html/bin/pod2html

clean:
	rm -f $(plextract)

#install:
#	for i in $(plextract); do install -m 0755 -D $$i $(scriptdir)/$$i; done
