default: all

include Makefile.config

CONFIGPM_FROM_CONFIG_SH = lib/Config.pm lib/Config_heavy.pl
CONFIGPM = $(CONFIGPM_FROM_CONFIG_SH) lib/Config_git.pl
CONFIGPOD = lib/Config.pod
XCONFIGPM = xlib/Config.pm xlib/Config_heavy.pl
STATIC = static
# Note: MakeMaker will look for xsubpp only in specific locations
# This is one of them; but dist/ExtUtils-ParseXS isn't.
XSUBPP = lib/ExtUtils/xsubpp
# For autodoc.pl below
MANIFEST_CH = $(shell sed -e 's/\s.*//' MANIFEST | grep '\.[ch]$$')

POD1 = $(wildcard pod/*.pod)
MAN1 = $(patsubst pod/%.pod,man/man1/%$(man1ext),$(POD1))

obj += $(madlyobj) $(mallocobj) gv$o toke$o perly$o pad$o regcomp$o dump$o util$o mg$o reentr$o mro$o
obj += hv$o av$o run$o pp_hot$o sv$o pp$o scope$o pp_ctl$o pp_sys$o
obj += doop$o doio$o regexec$o utf8$o taint$o deb$o universal$o globals$o perlio$o perlapi$o numeric$o
obj += mathoms$o locale$o pp_pack$o pp_sort$o keywords$o

static_tgt = $(patsubst %,%/pm_to_blib,$(static_ext))
dynamic_tgt = $(patsubst %,%/pm_to_blib,$(dynamic_ext))
nonxs_tgt = $(patsubst %,%/pm_to_blib,$(nonxs_ext))
disabled_dynamic_tgt = $(patsubst %,%/pm_to_blib,$(disabled_dynamic_ext))
disabled_nonxs_tgt = $(patsubst %,%/pm_to_blib,$(disabled_nonxs_ext))
# perl module names for static mods
static_pmn = $(shell echo $(static_ext) | sed -e 's!\(cpan\|ext\|dist\)/!!g' -e 's/-/::/g')

ext = $(nonxs_ext) $(dynamic_ext) $(static_ext)
tgt = $(nonxs_tgt) $(dynamic_tgt) $(static_tgt)
disabled_ext = $(disabled_nonxs_ext) $(disabled_dynamic_ext)

ext_makefiles = $(patsubst %,%/Makefile,$(ext))
disabled_ext_makefiles = $(pathsubst %,%/Makefile,$(disabled_ext))

# ---[ common ]-----------------------------------------------------------------

# Do NOT delete any intermediate files
# (mostly Makefile.PLs, but others can be annoying too)
.SECONDARY:

# Force early building of miniperl -- not really necessary, but makes
# build process more logical (no reason to even try CC if HOSTCC fails)
all: miniperl$X dynaloader perl$x nonxs_ext utilities extensions translators

config.h: config.sh config_h.SH
	CONFIG_H=$@ CONFIG_SH=$< ./config_h.SH

xconfig.h: xconfig.sh config_h.SH
	CONFIG_H=$@ CONFIG_SH=$< ./config_h.SH

config-pm: $(CONFIGPM)

xconfig-pm: $(XCONFIGPM)

$(XCONFIGPM): tconfig.sh | xlib miniperl$X
	./miniperl_top configpm --config-sh=tconfig.sh --config-pm=xlib/Config.pm --config-pod=xlib/Config.pod

xlib:
	mkdir -p $@

# prevent the following rule from overwriting Makefile
# by running Makefile.SH (part of original distribution)
Makefile:
	touch $@

%: %.SH config.sh
	./$*.SH

# ---[ host/miniperl ]----------------------------------------------------------

miniperl$X: miniperlmain$O $(obj:$o=$O) opmini$O perlmini$O
	$(HOSTCC) $(HOSTLDFLAGS) -o $@ $(filter %$O,$^) $(HOSTLIBS)

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
	
lib/ExtUtils/Miniperl.pm: miniperlmain.c minimod.pl $(CONFIGPM) | miniperl$X
	./miniperl_top minimod.pl > lib/ExtUtils/Miniperl.pm

# We don't want to regenerate perly.c and perly.h, but they might
# appear out-of-date after a patch is applied or a new distribution is
# made.
perly.c: perly.y
	-@sh -c true

perly.h: perly.y
	-@sh -c true

# this outputs perly.h, perly.act and perly.tab
regen_perly:
	perl regen_perly.pl

# ---[ site/perl ]--------------------------------------------------------------

perl$x: perlmain$o $(obj) libperl$a $(static_tgt) static.list ext.libs
	$(eval extlibs=$(shell cat ext.libs))
	$(eval statars=$(shell cat static.list))
	$(CC) $(LDFLAGS) -o $@ -Wl,-E $(filter %$o,$^) $(filter %$a,$^) $(statars) $(LIBS) $(extlibs)

%$o: %.c config.h
	$(CC) $(CFLAGS) -c -o $@ $<

globals.o: uudmap.h

perlmain.c: lib/ExtUtils/Miniperl.pm | miniperl$X
	./miniperl_top -MExtUtils::Miniperl -e 'writemain(@ARGV)' DynaLoader $(static_pmn) > $@

ext.libs: $(static_ext) | miniperl$X
	./miniperl_top extlibs $(static_ext) > $@

static.list: | $(static_tgt) miniperl$X
	./miniperl_top statars $(static_ext) > $@

# ---[ site/library ]-----------------------------------------------------------

libperl$a: op$o perl$o $(obj) DynaLoader$o
	$(AR) cru $@ $(filter %.o,$^)
	$(RANLIB) $@

perl.o: git_version.h

preplibrary: miniperl$X $(CONFIGPM) lib/re.pm

configpod: $(CONFIGPOD)
$(CONFIGPM_FROM_CONFIG_SH) $(CONFIGPOD): config.sh configpm Porting/Glossary lib/Config_git.pl | miniperl$X
	./miniperl_top configpm

# Both git_version.h and lib/Config_git.pl are built
# by make_patchnum.pl.
git_version.h lib/Config_git.pl: make_patchnum.pl | miniperl$X
	./miniperl_top make_patchnum.pl

lib/re.pm: ext/re/re.pm
	cp -f ext/re/re.pm lib/re.pm

pod/perlmodlib.pod: pod/perlmodlib.PL | miniperl$X
	./miniperl_top -Ilib -Idist/Cwd -Idist/Cwd/lib $< -q

autodoc: pod/perlintern.pod
pod/perlintern.pod pod/perlapi.pod: autodoc.pl embed.fnc $(MANIFEST_CH)
	./miniperl_top $<

# NOT used by this Makefile, replaced by miniperl_top
# Avoid building.
lib/buildcustomize.pl: write_buildcustomize.pl | miniperl$X
	./miniperl$X -Ilib $< > $@

# ---[ Modules ]----------------------------------------------------------------

# The rules below replace make_ext script used in the original
# perl build chain. Some host-specific functionality is lost.
# Check miniperl_top to see how it works.
$(nonxs_tgt) $(disabled_nonxs_tgt): %/pm_to_blib: %/Makefile
	$(MAKE) -C $(dir $@) all PERL_CORE=1 LIBPERL=libperl.a

DynaLoader$o: ext/DynaLoader/pm_to_blib
	@if [ ! -f ext/DynaLoader/DynaLoader$o ]; then rm $<; echo "Stale pm_to_blib, please re-run make"; false; fi
	cp ext/DynaLoader/DynaLoader$o $@

ext/DynaLoader/pm_to_blib: %/pm_to_blib: %/Makefile
	$(MAKE) -C $(dir $@) all PERL_CORE=1 LIBPERL=libperl.a LINKTYPE=static $(STATIC_LDFLAGS)

$(static_tgt): %/pm_to_blib: %/Makefile $(nonxs_tgt)
	$(MAKE) -C $(dir $@) all PERL_CORE=1 LIBPERL=libperl.a LINKTYPE=static $(STATIC_LDFLAGS)

$(dynamic_tgt) $(disabled_dynamic_tgt): %/pm_to_blib: %/Makefile
	$(MAKE) -C $(dir $@) all PERL_CORE=1 LIBPERL=libperl.a LINKTYPE=dynamic

%/Makefile: %/Makefile.PL preplibrary cflags | $(XSUBPP) miniperl$X
	$(eval top=$(shell echo $(dir $@) | sed -e 's![^/]\+!..!g'))
	cd $(dir $@) && $(top)miniperl_top -I$(top)lib Makefile.PL \
	 INSTALLDIRS=perl INSTALLMAN1DIR=none INSTALLMAN3DIR=none \
	 PERL_CORE=1 LIBPERL_A=libperl.a PERL_CORE=1 PERL="$(top)miniperl_top"

# Allow building modules by typing "make cpan/Module-Name"
$(static_ext) $(dynamic_ext) $(nonxs_ext) $(disabled_dynamic_ext) $(disabled_nonxs_ext): %: %/pm_to_blib

nonxs_ext: $(nonxs_tgt)
dynamic_ext: $(dynamic_tgt)
static_ext: $(static_tgt)
extensions: cflags $(dynamic_tgt) $(static_tgt) $(nonxs_tgt)
modules: extensions

# Some things needed to make modules
%/Makefile.PL: | miniperl$X
	./miniperl_top make_ext_Makefile.pl $@

cflags: cflags.SH
	sh $<

makeppport: $(CONFIGPM) | miniperl$X
	./miniper_top mkppport

makefiles: $(ext:pm_to_blib=Makefile)

dynaloader: DynaLoader$o

cpan/Devel-PPPort/PPPort.pm: | miniperl$X
	cd cpan/Devel-PPPort && ../../miniperl -I../../lib PPPort_pm.PL

cpan/Devel-PPPort/ppport.h: cpan/Devel-PPPort/PPPort.pm | miniperl$X
	cd cpan/Devel-PPPort && ../../miniperl -I../../lib ppport_h.PL

UNICORE = lib/unicore
UNICOPY = cpan/Unicode-Normalize/unicore

cpan/Unicode-Normalize/Makefile: cpan/Unicode-Normalize/unicore/CombiningClass.pl

# mktables does not touch the files unless they need to be rebuilt,
# which confuses make.
$(UNICORE)/%.pl: $(UNICORE)/mktables $(UNICORE)/*.txt $(CONFIGPM) | miniperl$X
	cd lib/unicore && ../../miniperl_top mktables
	touch $@
$(UNICOPY)/%.pl: $(UNICORE)/%.pl | $(UNICOPY)
	cp -a $< $@
$(UNICOPY):
	mkdir -p $@

# The following rules ensure that modules listed in mkppport.lst get
# their ppport.h installed
mkppport_lst = $(shell cat mkppport.lst | grep '^[a-z]')

$(patsubst %,%/pm_to_blib,$(mkppport_lst)): %/pm_to_blib: %/ppport.h
# Having %/ppport.h here isn't a very good idea since the initial ppport.h matches
# the pattern too
$(patsubst %,%/ppport.h,$(mkppport_lst)): cpan/Devel-PPPort/ppport.h
	cp -f $< $@

lib/ExtUtils/xsubpp: dist/ExtUtils-ParseXS/lib/ExtUtils/xsubpp
	cp -f $< $@

# No ExtUtils dependencies here because that's where they come from
cpan/ExtUtils-ParseXS/Makefile cpan/ExtUtils-Constant/Makefile: \
		%/Makefile: %/Makefile.PL preplibrary cflags | miniperl$X miniperl_top
	$(eval top=$(shell echo $(dir $@) | sed -e 's![^/]\+!..!g'))
	cd $(dir $@) && $(top)miniperl_top Makefile.PL PERL_CORE=1 PERL=$(top)miniperl_top

cpan/List-Util/pm_to_blib: dynaloader

# ---[ modules cleanup & rebuilding ] ------------------------------------------

modules-reset:
	$(if $(nonxs_ext),            rm -f $(patsubst %,%/pm_to_blib,$(nonxs_ext)))
	$(if $(static_ext),           rm -f $(patsubst %,%/pm_to_blib,$(static_ext)))
	$(if $(dynamic_ext),          rm -f $(patsubst %,%/pm_to_blib,$(dynamic_ext)))
	$(if $(disabled_nonxs_ext),   rm -f $(patsubst %,%/pm_to_blib,$(disabled_nonxs_ext)))
	$(if $(disabled_dynamic_ext), rm -f $(patsubst %,%/pm_to_blib,$(disabled_dynamic_ext)))

modules-makefiles: $(ext_makefiles)

modules-clean: clean-modules

# ---[ Misc ]-------------------------------------------------------------------

utilities: miniperl$X $(CONFIGPM)
	$(MAKE) -C utils all

translators: miniperl$X $(CONFIGPM) dist/Cwd/pm_to_blib
	$(MAKE) -C x2p all

pod/%: miniperl$X lib/Config.pod pod/%.PL config.sh
	cd pod && ../miniperl_top $*.PL

# ---[ modules lists ]----------------------------------------------------------
modules.done: modules.list uni.data
	echo -n > modules.done
	-cat $< | (while read i; do $(MAKE) -C $$i && echo $$i >> modules.done; done)

modules.pm.list: modules.done
	-cat $< | (while read i; do find $$i -name '*.pm'; done) > $@

modules.list: $(CONFIGPM) $(MODLISTS) cflags
	./modconfig_all

# ---[ install ]----------------------------------------------------------------
.PHONY: install install.perl install.pod

META.yml: Porting/makemeta Porting/Maintainers.pl Porting/Maintainers.pm miniperl$X
	./miniperl_top $<

install: install.perl install.man

install.perl: installperl miniperl$X
	./miniperl_top installperl --destdir=$(DESTDIR) $(INSTALLFLAGS) $(STRIPFLAGS)
	-@test ! -s extras.lst || $(MAKE) extras.install

install.man: installman miniperl$X
	./miniperl_top installman --destdir=$(DESTDIR) $(INSTALLFLAGS)

install.miniperl: miniperl$X xlib/Config.pm xlib/Config_heavy.pl
	install -D -m 0755 miniperl $(hostbin)/$(target_name)-miniperl$X
	-ln -s $(target_name)-miniperl$X $(hostbin)/$(target_arch)-miniperl$X 
	install -D -m 0644 xlib/Config.pm $(hostprefix)/$(target_arch)/lib/perl/Config.pm
	install -D -m 0644 xlib/Config_heavy.pl $(hostprefix)/$(target_arch)/lib/perl/Config_heavy.pl

# ---[ clean ]------------------------------------------------------------------
.PHONY: clean clean-obj clean-generated-files clean-subdirs clean-modules
clean: clean-obj clean-generated-files clean-subdirs clean-modules

clean-obj:
	-test -n "$o" && rm -f *$o
	-test -n "$O" && rm -f *$O

clean-subdirs:
	@for i in utils x2p; do $(MAKE) -C $$i clean; done

# assuming modules w/o Makefiles were never built and need no cleaning
clean-modules:
	@for i in $(ext) $(disabled_ext); do test -f $$i/Makefile && $(MAKE) $$i/Makefile && $(MAKE) -C $$i clean || true; done

clean-generated-files:
	-rm -f uudmap.h opmini.c generate_uudmap$X bitcount.h $(CONFIGPM)
	-rm -f git_version.h lib/re.pm lib/Config_git.pl
	-rm -f perlmini.c perlmain.c
	-rm -f config.h xconfig.h
	-rm -f $(UNICOPY)/*
	-rm -f pod/perlmodlib.pod
	-rm -f ext.libs static.list
	-rm -f $(patsubst %,%/ppport.h,$(mkppport_lst))
	-rm -f cpan/Devel-PPPort/ppport.h cpan/Devel-PPPort/PPPort.pm
