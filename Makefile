default: all

include Makefile.config

DYNALOADER = DynaLoader$o
CONFIGPM = lib/Config.pm lib/Config_heavy.pl
XCONFIGPM = xlib/Config.pm xlib/Config_heavy.pl
STATIC = static
MINIPERL = miniperl$X
RUNPERL = ./miniperl$X -Ilib

POD1 = $(wildcard pod/*.pod)
MAN1 = $(patsubst pod/%.pod,man/man1/%$(man1ext),$(POD1))

obj += gv$o toke$o perly$o pad$o regcomp$o dump$o util$o mg$o reentr$o mro$o
obj += hv$o av$o perl$o run$o pp_hot$o sv$o pp$o scope$o pp_ctl$o pp_sys$o
obj += doop$o doio$o regexec$o utf8$o taint$o deb$o universal$o xsutils$o
obj += globals$o perlio$o perlapi$o numeric$o mathoms$o locale$o pp_pack$o pp_sort$o 
plextract = pod/pod2html pod/pod2latex pod/pod2man pod/pod2text \
	pod/pod2usage pod/podchecker pod/podselect

ext = $(dynamic_ext) $(static_ext) $(nonxs_ext)

# ---[ common ]-----------------------------------------------------------------

# Force early building of miniperl -- not really necessary, but makes
# build process more logical (don't try CC if HOSTCC fails)
all: miniperl$X perl$x utilities translators extensions

clean:
	rm -f *$o *$O uudmap.h opmini.c generate_uudmap $(CONFIGPM)
	@for i in utils; do make -C $$i clean; done

config.h: config.sh config_h.SH
	CONFIG_H=$@ CONFIG_SH=$< ./config_h.SH

xconfig.h: xconfig.sh config_h.SH
	CONFIG_H=$@ CONFIG_SH=$< ./config_h.SH

config-pm: $(CONFIGPM)

xconfig-pm: $(XCONFIGPM)

# Tprevent the following rule from overwriting Makefile
Makefile:
	touch $@

%: %.SH config.sh
	./$*.SH

# ---[ host/miniperl ]----------------------------------------------------------

miniperl$X: $& miniperlmain$O $(obj:$o=$O) opmini$O
	$(HOSTCC) -o $@ $(filter %$O,$^) $(HOSTLIBS)

generate_uudmap$X: generate_uudmap.c
	$(HOSTCC) $(HOSTCFLAGS) -o $@ $^

ifneq ($O,$o)
%$O: %.c xconfig.h
	$(HOSTCC) $(HOSTCFLAGS) -c -o $@ $<
endif

opmini$O: opmini.c
	$(HOSTCC) $(HOSTCFMINI) -c -o $@ $<

globals$O: uudmap.h

uudmap.h: generate_uudmap$X
	./generate_uudmap > $@

opmini.c: op.c
	cp -f $^ $@

# ---[ site/perl ]--------------------------------------------------------------

perl$x: $& perlmain$o $(obj) libperl$a op$o
	$(CC) -o $@ -Wl,-E $(filter %$o,$^) $(filter %$a,$^) $(LIBS)

%$o: %.c config.h
	$(CC) $(CFLAGS) -c -o $@ $<

globals.o: uudmap.h

perlmain.c: miniperlmain.c writemain
	sh writemain $(DYNALOADER) $(static_ext) > perlmain.c

# ---[ site/library ]-----------------------------------------------------------

libperl$a: $(obj) $(DYNALOADER)
	$(AR) cru $@ $(filter %.o,$^)
	$(RANLIB) $@

#$(DYNALOADER): miniperl$e preplibrary
#	$(MAKE) -C ext/DynaLoader DynaLoader.o
#	cp ext/DynaLoader/DynaLoader.o .

.PHONY: preplibrary
preplibrary: miniperl$x lib/lib.pm
	@mkdir -p lib/auto
	./miniperl -Ilib -e 'use AutoSplit; \
		autosplit_lib_modules(@ARGV)' lib/*.pm
	./miniperl -Ilib -e 'use AutoSplit; \
		autosplit_lib_modules(@ARGV)' lib/*/*.pm
	$(MAKE) lib/re.pm

lib/lib.pm: miniperl$X $(CONFIGPM)
	./miniperl -Ilib lib/lib_pm.PL

lib/Config.pod $(CONFIGPM): miniperl$X configpm config.sh
	./miniperl -Ilib configpm

$(XCONFIGPM): miniperl$X tconfig.sh
	@mkdir -p xlib
	./miniperl -Ilib configpm --config-sh=tconfig.sh --config-pm=xlib/Config.pm --config-pod=xlib/Config.pod

lib/re.pm: ext/re/re.pm
	cp -f ext/re/re.pm lib/re.pm

# ---[ Modules ]----------------------------------------------------------------

extensions: uni.data cflags $(dynamic_ext) $(static_ext) $(nonxs_ext)

cflags: cflags.SH
	sh $<

$(DYNALOADER): miniperl$x preplibrary
	sh ext/util/make_ext $(STATIC) $@ MAKE=$(MAKE) LIBPERL_A=$(LIBPERL)

d_dummy $(dynamic_ext): miniperl$x makeppport
	sh ext/util/make_ext dynamic $@ MAKE=$(MAKE) LIBPERL_A=$(LIBPERL)

s_dummy $(static_ext): miniperl$x makeppport
	sh ext/util/make_ext $(STATIC) $@ MAKE=$(MAKE) LIBPERL_A=$(LIBPERL)

n_dummy $(nonxs_ext): miniperl$x makeppport
	sh ext/util/make_ext nonxs $@ MAKE=$(MAKE) LIBPERL_A=$(LIBPERL)

.PHONY: makeppport
makeppport: miniperl$X $(CONFIGPM)
	./miniperl$X -Ilib mkppport

# ---[ Misc ]-------------------------------------------------------------------

utilities: miniperl$x $(CONFIGPM) $(plextract) lib/lib.pm
	$(MAKE) -C utils all

translators: miniperl$x $(CONFIGPM)
	$(MAKE) -C x2p all

uni.data: miniperl$X $(CONFIGPM) lib/unicore/mktables
	cd lib/unicore && ../../miniperl -I../../lib mktables -w
	touch uni.data

pod/%: miniperl$X lib/Config.pod pod/%.PL config.sh
	cd pod && ../miniperl$X -I../lib $*.PL

# ---[ modules ]----------------------------------------------------------------
modules modules.done: modules.list uni.data
	echo -n > modules.done
	-cat $< | (while read i; do $(MAKE) -C $$i && echo $$i >> modules.done; done)

modules.pm.list: modules.done
	-cat $< | (while read i; do find $$i -name '*.pm'; done) > $@

modules.list: $(CONFIGPM) $(MODLISTS) cflags
	./modconfig_all

# ---[ install ]----------------------------------------------------------------
.PHONY: install install.perl install.pod

META.yml: Porting/makemeta Porting/Maintainers.pl Porting/Maintainers.pm miniperl$X
	$(RUNPERL) $<

install: install.perl install.man

install.perl: installperl miniperl$X
	$(RUNPERL) installperl --destdir=$(DESTDIR) $(INSTALLFLAGS) $(STRIPFLAGS)
	-@test ! -s extras.lst || $(MAKE) extras.install

install.man: installman miniperl$X
	$(RUNPERL) installman --destdir=$(DESTDIR) $(INSTALLFLAGS)

install.miniperl: miniperl$X xlib/Config.pm xlib/Config_heavy.pl
	install -D -m 0755 miniperl $(hostbin)/$(target_name)-miniperl$X
	-ln -s $(target_name)-miniperl$X $(hostbin)/$(target_arch)-miniperl$X 
	install -D -m 0644 xlib/Config.pm $(hostprefix)/$(target_arch)/lib/perl/Config.pm
	install -D -m 0644 xlib/Config_heavy.pl $(hostprefix)/$(target_arch)/lib/perl/Config_heavy.pl
