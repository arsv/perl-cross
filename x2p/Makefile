TOP = ..
include $(TOP)/Makefile.config
PERL = $(TOP)/miniperl_top -I$(TOP)/lib

all: a2p$x find2perl s2p

.c$o:
	$(CC) $(CFLAGS) -DPERL_FOR_X2P -c -o $@ $<

a2p$x: a2p$o hash$o str$o util$o walk$o
	$(CC) -o $@ $(filter %$o,$^) $(LDFLAGS)

# Do not rebuild a2p.c just because a2p.y is newer.
# It is very unlikely for perl-cross to be used for perl development,
# but it may happen that perl source has a2p.c not-older than a2p.y.
a2p.c: a2p.y
	test -f $@ && touch $@ || yacc $<

%: %.PL
	$(PERL) $<

clean:
	rm -f *$o find2perl s2p

#install:
#	install -D -m 0755 a2p$x $(bindir)/a2p$x
#	install -D -m 0755 s2p $(scriptdir)/s2p
