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
# The following modules are required to build Makefiles for other modules
# Be careful here! They must be built before running any Makefile.PLs,
# and they must have their own rules down below (search for EXTUTILS)
EXTUTILS = lib/ExtUtils/xsubpp lib/ExtUtils/Constant.pm \
	$(patsubst cpan/ExtUtils-Constant/lib/%,lib/%,$(wildcard cpan/ExtUtils-Constant/lib/ExtUtils/Constant/*.pm))

POD1 = $(wildcard pod/*.pod)
MAN1 = $(patsubst pod/%.pod,man/man1/%$(man1ext),$(POD1))

obj += $(madlyobj) $(mallocobj) gv$o toke$o perly$o pad$o regcomp$o dump$o util$o mg$o reentr$o mro$o
obj += hv$o av$o run$o pp_hot$o sv$o pp$o scope$o pp_ctl$o pp_sys$o
obj += doop$o doio$o regexec$o utf8$o taint$o deb$o universal$o globals$o perlio$o perlapi$o numeric$o
obj += mathoms$o locale$o pp_pack$o pp_sort$o

plextract = pod/pod2html pod/pod2latex pod/pod2man pod/pod2text \
	pod/pod2usage pod/podchecker pod/podselect

static_tgt = $(patsubst %,%/pm_to_blib,$(static_ext))
static_obj = $(shell for i in $(static_ext); do echo $$i | sed -e 's!\(.*[/-]\(.*\)\)!\1/\2.o!g'; done)
dynamic_tgt = $(patsubst %,%/pm_to_blib,$(dynamic_ext))
nonxs_tgt = $(patsubst %,%/pm_to_blib,$(nonxs_ext))

ext = $(nonxs_ext) $(dynamic_ext) $(static_ext)
tgt = $(nonxs_tgt) $(dynamic_tgt) $(static_tgt)

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

$(XCONFIGPM): miniperl$X tconfig.sh | xlib
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
	

# ---[ site/perl ]--------------------------------------------------------------

perl$x: perlmain$o $(obj) libperl$a $(static_tgt) ext.libs
	$(eval extlibs=$(shell cat ext.libs))
	$(CC) $(LDFLAGS) -o $@ -Wl,-E $(filter %$o,$^) $(filter %$a,$^) $(static_obj) $(LIBS) $(extlibs)

%$o: %.c config.h
	$(CC) $(CFLAGS) -c -o $@ $<

globals.o: uudmap.h

perlmain.c: miniperlmain.c writemain
	./writemain DynaLoader $(static_ext) > perlmain.c

ext.libs: $(static_ext) | miniperl$X
	./miniperl_top extlibs $(static_ext) > $@

# ---[ site/library ]-----------------------------------------------------------

libperl$a: op$o perl$o $(obj) DynaLoader$o
	$(AR) cru $@ $(filter %.o,$^)
	$(RANLIB) $@

perl.o: git_version.h

preplibrary: miniperl$X $(CONFIGPM) lib/re.pm

configpod: $(CONFIGPOD)
$(CONFIGPM_FROM_CONFIG_SH) $(CONFIGPOD): config.sh miniperl$X configpm Porting/Glossary lib/Config_git.pl
	./miniperl_top configpm

# Both git_version.h and lib/Config_git.pl are built
# by make_patchnum.pl.
git_version.h lib/Config_git.pl: make_patchnum.pl | miniperl$X
	./miniperl_top make_patchnum.pl

lib/re.pm: ext/re/re.pm
	cp -f ext/re/re.pm lib/re.pm

# ---[ Modules ]----------------------------------------------------------------

# The rules below replace make_ext script used in the original
# perl build chain. Some host-specific functionality is lost.
# Check miniperl_top to see how it works.
$(nonxs_tgt): %/pm_to_blib: %/Makefile
	$(MAKE) -C $(dir $@) all PERL_CORE=1 LIBPERL=libperl.a

DynaLoader.o: ext/DynaLoader/pm_to_blib

ext/DynaLoader/pm_to_blib: %/pm_to_blib: %/Makefile
	$(MAKE) -C $(dir $@) all PERL_CORE=1 LIBPERL=libperl.a LINKTYPE=static $(STATIC_LDFLAGS)

$(static_tgt): %/pm_to_blib: %/Makefile $(nonxs_tgt)
	$(MAKE) -C $(dir $@) all PERL_CORE=1 LIBPERL=libperl.a LINKTYPE=static $(STATIC_LDFLAGS)

$(dynamic_tgt): %/pm_to_blib: %/Makefile
	$(MAKE) -C $(dir $@) all PERL_CORE=1 LIBPERL=libperl.a LINKTYPE=dynamic

%/Makefile: %/Makefile.PL preplibrary cflags | $(EXTUTILS) miniperl$X miniperl_top
	$(eval top=$(shell echo $(dir $@) | sed -e 's![^/]\+!..!g'))
	cd $(dir $@) && $(top)miniperl_top Makefile.PL PERL_CORE=1 PERL=$(top)miniperl_top

# Allow building modules by typing "make cpan/Module-Name"
$(static_ext) $(dynamic_ext) $(nonxs_ext): %: %/pm_to_blib

$(static_tgt) $(dynamic_tgt): $(nonxs_tgt)

%/Makefile.PL: | miniperl$X
	./miniperl_top make_ext_Makefile.pl $@

cflags: cflags.SH
	sh $<

makeppport: miniperl$X $(CONFIGPM)
	./miniperl_top mkppport

makefiles: $(ext:pm_to_blib=Makefile)

nonxs_ext: $(nonxs_tgt)
dynamic_ext: $(dynamic_tgt)
static_ext: $(static_tgt)
extensions: cflags $(dynamic_tgt) $(static_tgt) $(nonxs_tgt)

dynaloader: $(DYNALOADER)

$(DYNALOADER): ext/DynaLoader/pm_to_blib ext/DynaLoader/Makefile
	make -C $(dir $<)

cpan/Devel-PPPort/PPPort.pm: | miniperl$X
	cd cpan/Devel-PPPort && ../../miniperl_top PPPort_pm.PL

cpan/Devel-PPPort/ppport.h: cpan/Devel-PPPort/PPPort.pm | miniperl$X
	cd cpan/Devel-PPPort && ../../miniperl_top ppport_h.PL

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

# $EXTUTILS building rules
lib/ExtUtils/xsubpp: cpan/ExtUtils-ParseXS/lib/ExtUtils/xsubpp
	cp -f $< $@

lib/ExtUtils/Constant.pm: cpan/ExtUtils-Constant/lib/ExtUtils/Constant.pm
	cp -f $< $@

lib/ExtUtils/Constant/%: cpan/ExtUtils-Constant/lib/ExtUtils/Constant/%
	mkdir -p `dirname $@`
	cp -f $< $@

cpan/ExtUtils-ParseXS/lib/ExtUtils/xsubpp: cpan/ExtUtils-ParseXS/pm_to_blib

# No ExtUtils dependencies here because that's where they come from
cpan/ExtUtils-ParseXS/Makefile cpan/ExtUtils-Constant/Makefile: \
		%/Makefile: %/Makefile.PL preplibrary cflags | miniperl$X miniperl_top
	$(eval top=$(shell echo $(dir $@) | sed -e 's![^/]\+!..!g'))
	cd $(dir $@) && $(top)miniperl_top Makefile.PL PERL_CORE=1 PERL=$(top)miniperl_top

cpan/List-Util/pm_to_blib: dynaloader

# ---[ Misc ]-------------------------------------------------------------------

utilities: miniperl$x $(CONFIGPM) $(plextract)
	$(MAKE) -C utils all

translators: miniperl$x $(CONFIGPM) cpan/Cwd/pm_to_blib
	$(MAKE) -C x2p all

pod/%: miniperl$X lib/Config.pod pod/%.PL config.sh
	cd pod && ../miniperl_top $*.PL

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
clean:
	-test -n "$o" && rm -f *$o
	-test -n "$O" && rm -f *$O
	@for i in utils; do $(MAKE) -C $$i clean; done
	@for i in $(nonxs_ext) $(static_ext) $(dynamic_ext); do $(MAKE) -C $$i clean; done
	-rm -f uudmap.h opmini.c generate_uudmap$X bitcount.h $(CONFIGPM)
	-rm -f git_version.h lib/re.pm lib/Config_git.pl
	-rm -f perlmini.c perlmain.c
	-rm -f config.h xconfig.h
	-rm -f $(UNICOPY)/*
	-rm -f $(patsubst %,%/ppport.h,$(mkppport_lst))
	-rm -f cpan/Devel-PPPort/ppport.h cpan/Devel-PPPort/PPPort.pm
