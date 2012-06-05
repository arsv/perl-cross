TOP = ..
include $(TOP)/Makefile.config
PERL = $(TOP)/miniperl_top

plextract = c2ph config_data corelist cpan h2ph h2xs instmodsh json_pp perlbug perldoc\
	perlivp pl2pm prove ptar ptardiff ptargrep cpanp-run-perl cpanp cpan2dist shasum\
	splain libnetcfg piconv enc2xs xsubpp pod2html zipdetails

all: $(plextract) 

%: %.PL ../config.sh
	$(PERL) $<

perlbug: ../patchlevel.h

splain:	../lib/diagnostics.pm

zipdetails:	zipdetails.PL ../config.sh

pod2html:	pod2html.PL ../config.sh ../ext/Pod-Html/bin/pod2html

clean:
	rm -f $(plextract)

#install:
#	for i in $(plextract); do install -m 0755 -D $$i $(scriptdir)/$$i; done
