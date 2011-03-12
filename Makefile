default: all

include Makefile.config

DYNALOADER = DynaLoader$o
CONFIGPM_FROM_CONFIG_SH = lib/Config.pm lib/Config_heavy.pl
CONFIGPM = $(CONFIGPM_FROM_CONFIG_SH) lib/Config_git.pl
CONFIGPOD = lib/Config.pod
XCONFIGPM = xlib/Config.pm xlib/Config_heavy.pl
STATIC = static
MINIPERL = ./miniperl$X -Ilib
MINIPERL_EXE = miniperl$X
RUNPERL = ./miniperl$X -Ilib

CPS = cp
RMS = rm -f

POD1 = $(wildcard pod/*.pod)
MAN1 = $(patsubst pod/%.pod,man/man1/%$(man1ext),$(POD1))

obj += $(madlyobj) $(mallocobj) gv$o toke$o perly$o pad$o regcomp$o dump$o util$o mg$o reentr$o mro$o
obj += hv$o av$o run$o pp_hot$o sv$o pp$o scope$o pp_ctl$o pp_sys$o
obj += doop$o doio$o regexec$o utf8$o taint$o deb$o universal$o globals$o perlio$o perlapi$o numeric$o
obj += mathoms$o locale$o pp_pack$o pp_sort$o

plextract = pod/pod2html pod/pod2latex pod/pod2man pod/pod2text \
	pod/pod2usage pod/podchecker pod/podselect

static_tgt = $(patsubst %,%/pm_to_blib,$(static_ext))
dynamic_tgt = $(patsubst %,%/pm_to_blib,$(dynamic_ext))
nonxs_tgt = $(patsubst %,%/pm_to_blib,$(nonxs_ext))

ext = $(dynamic_ext) $(static_ext) $(nonxs_ext)
tgt = $(dynamic_tgt) $(static_tgt) $(nonxs_tgt)

# ---[ common ]-----------------------------------------------------------------

# Do NOT delete any intermediate files
# (mostly Makefile.PLs, but others can be annoying too)
.SECONDARY:

# Force early building of miniperl -- not really necessary, but makes
# build process more logical (don't try CC if HOSTCC fails)
all: miniperl$X perl$x utilities translators extensions

clean:
	rm -f *$o *$O uudmap.h opmini.c generate_uudmap bitcount.h $(CONFIGPM)
	rm -f perlmini.c
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

miniperl$X: miniperlmain$O $(obj:$o=$O) opmini$O perlmini$O
	$(HOSTCC) -o $@ $(filter %$O,$^) $(HOSTLIBS)

miniperlmain$O: miniperlmain.c patchlevel.h

generate_uudmap$X: generate_uudmap.c
	$(HOSTCC) $(HOSTCFLAGS) -o $@ $^

ifneq ($O,$o)
%$O: %.c xconfig.h
	$(HOSTCC) $(HOSTCFLAGS) -c -o $@ $<
endif

globals$O: uudmap.h bitcount.h

uudmap.h bitcount.h: generate_uudmap$X
	./generate_uudmap uudmap.h bitcount.h

opmini.c: op.c
	cp -f $^ $@

opmini$O: opmini.c
	$(HOSTCC) $(HOSTCFLAGS) -DPERL_EXTERNAL_GLOB -c -o $@ $<

perlmini.c: perl.c
	cp -f $^ $@

perlmini$O: perlmini.c
	$(HOSTCC) $(HOSTCFLAGS) -DPERL_IS_MINIPERL -c -o $@ $<
	

# ---[ site/perl ]--------------------------------------------------------------

perl$x: perlmain$o $(obj) libperl$a
	$(CC) -o $@ -Wl,-E $(filter %$o,$^) $(filter %$a,$^) $(LIBS)

%$o: %.c config.h
	$(CC) $(CFLAGS) -c -o $@ $<

globals.o: uudmap.h

perlmain.c: miniperlmain.c writemain
	sh writemain $(DYNALOADER) > perlmain.c

# ---[ site/library ]-----------------------------------------------------------

libperl$a: op$o perl$o $(obj) $(DYNALOADER)
	$(AR) cru $@ $(filter %.o,$^)
	$(RANLIB) $@

perl.o: git_version.h

#.PHONY: preplibrary
preplibrary: miniperl$X $(CONFIGPM) lib/re.pm

$(CONFIGPM_FROM_CONFIG_SH): $(CONFIGPOD)

configpod: $(CONFIGPOD)
$(CONFIGPOD): config.sh miniperl$X configpm Porting/Glossary lib/Config_git.pl
	$(MINIPERL) configpm

# Both git_version.h and lib/Config_git.pl are built
# by make_patchnum.pl.
git_version.h: lib/Config_git.pl make_patchnum.pl miniperl$X
	$(MINIPERL) make_patchnum.pl

lib/Config_git.pl: make_patchnum.pl miniperl$X
	$(MINIPERL) make_patchnum.pl

#.PHONY: preplibrary
#preplibrary: miniperl$x lib/lib.pm
#	@mkdir -p lib/auto
#	./miniperl -Ilib -e 'use AutoSplit; \
#		autosplit_lib_modules(@ARGV)' lib/*.pm
#	./miniperl -Ilib -e 'use AutoSplit; \
#		autosplit_lib_modules(@ARGV)' lib/*/*.pm
#	$(MAKE) lib/re.pm

#lib/lib.pm: miniperl$X $(CONFIGPM)
#	./miniperl -Ilib lib/lib_pm.PL

#lib/Config.pod $(CONFIGPM): miniperl$X configpm config.sh
#	./miniperl -Ilib configpm

#$(XCONFIGPM): miniperl$X tconfig.sh
#	@mkdir -p xlib
#	./miniperl -Ilib configpm --config-sh=tconfig.sh --config-pm=xlib/Config.pm --config-pod=xlib/Config.pod

lib/re.pm: ext/re/re.pm
	cp -f ext/re/re.pm lib/re.pm

# ---[ Modules ]----------------------------------------------------------------

# The rules below replace make_ext script used in the original
# perl build chain. Some host-specific functionality is lost.
# Check miniperl_top to see how it works.
$(nonxs_tgt): %/pm_to_blib: %/Makefile
	$(MAKE) -C $(dir $@) all PERL_CORE=1 LIBPERL=libperl.a

DynaLoader.o: ext/DynaLoader/pm_to_blib

$(static_tgt) ext/DynaLoader/pm_to_blib: %/pm_to_blib: %/Makefile
	$(MAKE) -C $(dir $@) all PERL_CORE=1 LIBPERL=libperl.a LINKTYPE=static $(STATIC_LDFLAGS)

$(dynamic_tgt): %/pm_to_blib: %/Makefile
	$(MAKE) -C $(dir $@) all PERL_CORE=1 LIBPERL=libperl.a LINKTYPE=dynamic

%/Makefile: %/Makefile.PL miniperl$X miniperl_top preplibrary cflags
	$(eval top=$(shell echo $(dir $@) | sed -e 's![^/]\+!..!g'))
	cd $(dir $@) && $(top)miniperl_top Makefile.PL PERL_CORE=1 PERL=$(top)miniperl_top

# do NOT add miniperl here!!
%/Makefile.PL:
	$(MINIPERL) make_ext_Makefile.pl $@

cflags: cflags.SH
	sh $<

makeppport: miniperl$X $(CONFIGPM)
	./miniperl_top mkppport

makefiles: $(ext:pm_to_blib=Makefile)

nonxs_ext: $(nonxs_tgt)
dynamic_ext: $(dynamic_tgt)
static_ext: $(static_tgt)
extensions: uni.data cflags $(dynamic_tgt) $(static_tgt) $(nonxs_tgt)

dynaloader: $(DYNALOADER)

cpan/Devel-PPPort/PPPort.pm:
	cd cpan/Devel-PPPort && ../../miniperl_top PPPort_pm.PL

cpan/Devel-PPPort/ppport.h:
	cd cpan/Devel-PPPort && ../../miniperl_top ppport_h.PL

# THree following rules ensure that modules listed in mkppport.lst get
# their ppport.h installed
mkppport_lst = $(shell cat mkppport.lst | grep '^[a-z]')

mkppport_lst:
	@echo $(mkppport_lst)
	@echo $(patsubst %,%/ppport.h,$(mkppport_lst))

$(patsubst %,%/pm_to_blib,$(mkppport_lst)): %/pm_to_blib: %/ppport.h
# Having %/ppport.h here isn't a very good idea since the initial ppport.h matches
# the pattern too
$(patsubst %,%/ppport.h,$(mkppport_lst)): cpan/Devel-PPPort/ppport.h
	cp -f $< $@

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

#include Makefile_clean
