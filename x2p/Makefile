TOP = ..
include $(TOP)/Makefile.config
PERL = $(TOP)/miniperl -I$(TOP)/lib

all: a2p$x find2perl s2p

.c$o:
	$(CC) $(CFLAGS) -DPERL_FOR_X2P -c -o $@ $<

a2p$x: a2p$o hash$o str$o util$o walk$o
	$(CC) -o $@ $(filter %$o,$^) $(LDFLAGS)

%: %.PL
	$(PERL) $<

clean:
	rm -f *$o find2perl s2p

#install:
#	install -D -m 0755 a2p$x $(bindir)/a2p$x
#	install -D -m 0755 s2p $(scriptdir)/s2p
