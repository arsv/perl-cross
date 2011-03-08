default: all

include Makefile.config

DYNALOADER = DynaLoader$o
CONFIGPM_FROM_CONFIG_SH = lib/Config.pm lib/Config_heavy.pl
CONFIGPM = $(CONFIGPM_FROM_CONFIG_SH) lib/Config_git.pl
CONFIGPOD = lib/Config.pod
XCONFIGPM = xlib/Config.pm xlib/Config_heavy.pl
STATIC = static
MINIPERL = ./miniperl$X -Ilib
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

nonxs_ext =	cpan/Archive-Extract/pm_to_blib\
		cpan/Archive-Tar/pm_to_blib\
		dist/Attribute-Handlers/pm_to_blib\
		cpan/AutoLoader/pm_to_blib\
		cpan/B-Debug/pm_to_blib\
		dist/B-Deparse/pm_to_blib\
		cpan/B-Lint/pm_to_blib\
		cpan/CGI/pm_to_blib\
		cpan/CPAN/pm_to_blib\
		cpan/CPANPLUS/pm_to_blib\
		cpan/CPANPLUS-Dist-Build/pm_to_blib\
		cpan/Class-ISA/pm_to_blib\
		ext/Devel-SelfStubber/pm_to_blib\
		cpan/Digest/pm_to_blib\
		ext/Errno/pm_to_blib\
		cpan/ExtUtils-CBuilder/pm_to_blib\
		cpan/ExtUtils-Command/pm_to_blib\
		cpan/ExtUtils-Constant/pm_to_blib\
		dist/ExtUtils-Install/pm_to_blib\
		cpan/ExtUtils-MakeMaker/pm_to_blib\
		cpan/ExtUtils-Manifest/pm_to_blib\
		cpan/ExtUtils-ParseXS/pm_to_blib\
		cpan/File-Fetch/pm_to_blib\
		cpan/File-Path/pm_to_blib\
		cpan/File-Temp/pm_to_blib\
		ext/FileCache/pm_to_blib\
		dist/Filter-Simple/pm_to_blib\
		cpan/Getopt-Long/pm_to_blib\
		dist/I18N-LangTags/pm_to_blib\
		cpan/IO-Compress/pm_to_blib\
		cpan/IO-Zlib/pm_to_blib\
		cpan/IPC-Cmd/pm_to_blib\
		ext/IPC-Open2/pm_to_blib\
		ext/IPC-Open3/pm_to_blib\
		cpan/Locale-Codes/pm_to_blib\
		dist/Locale-Maketext/pm_to_blib\
		cpan/Locale-Maketext-Simple/pm_to_blib\
		cpan/Log-Message/pm_to_blib\
		cpan/Log-Message-Simple/pm_to_blib\
		cpan/Math-BigInt/pm_to_blib\
		cpan/Math-BigRat/pm_to_blib\
		cpan/Math-Complex/pm_to_blib\
		cpan/Memoize/pm_to_blib\
		cpan/Module-Build/pm_to_blib\
		dist/Module-CoreList/pm_to_blib\
		cpan/Module-Load/pm_to_blib\
		cpan/Module-Load-Conditional/pm_to_blib\
		cpan/Module-Loaded/pm_to_blib\
		cpan/Module-Pluggable/pm_to_blib\
		cpan/NEXT/pm_to_blib\
		dist/Net-Ping/pm_to_blib\
		cpan/Object-Accessor/pm_to_blib\
		cpan/Package-Constants/pm_to_blib\
		cpan/Params-Check/pm_to_blib\
		cpan/Parse-CPAN-Meta/pm_to_blib\
		cpan/PerlIO-via-QuotedPrint/pm_to_blib\
		cpan/Pod-Escapes/pm_to_blib\
		cpan/Pod-LaTeX/pm_to_blib\
		cpan/Pod-Parser/pm_to_blib\
		dist/Pod-Perldoc/pm_to_blib\
		dist/Pod-Plainer/pm_to_blib\
		cpan/Pod-Simple/pm_to_blib\
		dist/Safe/pm_to_blib\
		dist/SelfLoader/pm_to_blib\
		cpan/Shell/pm_to_blib\
		dist/Switch/pm_to_blib\
		cpan/Term-ANSIColor/pm_to_blib\
		cpan/Term-Cap/pm_to_blib\
		cpan/Term-UI/pm_to_blib\
		cpan/Test/pm_to_blib\
		cpan/Test-Harness/pm_to_blib\
		cpan/Test-Simple/pm_to_blib\
		cpan/Text-Balanced/pm_to_blib\
		cpan/Text-ParseWords/pm_to_blib\
		cpan/Text-Tabs/pm_to_blib\
		dist/Thread-Queue/pm_to_blib\
		dist/Thread-Semaphore/pm_to_blib\
		cpan/Tie-File/pm_to_blib\
		ext/Tie-Memoize/pm_to_blib\
		cpan/Tie-RefHash/pm_to_blib\
		ext/Time-Local/pm_to_blib\
		cpan/Unicode-Collate/pm_to_blib\
		dist/XSLoader/pm_to_blib\
		cpan/autodie/pm_to_blib\
		ext/autouse/pm_to_blib\
		dist/base/pm_to_blib\
		cpan/bignum/pm_to_blib\
		dist/constant/pm_to_blib\
		cpan/encoding-warnings/pm_to_blib\
		cpan/if/pm_to_blib\
		dist/lib/pm_to_blib\
		cpan/libnet/pm_to_blib\
		cpan/parent/pm_to_blib\
		cpan/podlators/pm_to_blib
#nonxs_ext = cpan/Archive-Extract/pm_to_blib cpan/Getopt-Long/pm_to_blib

ext = $(dynamic_ext) $(static_ext) $(nonxs_ext)

# ---[ common ]-----------------------------------------------------------------

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

perl$x: perlmain$o $(obj) libperl$a op$o
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
preplibrary: miniperl$X $(CONFIGPM) lib/re.pm

$(CONFIGPM_FROM_CONFIG_SH): $(CONFIGPOD)

configpod: $(CONFIGPOD)
$(CONFIGPOD): config.sh miniperl$X configpm Porting/Glossary lib/Config_git.pl
	$(MINIPERL) configpm

# Both git_version.h and lib/Config_git.pl are built
# by make_patchnum.pl.
git_version.h: lib/Config_git.pl

lib/Config_git.pl: $(MINIPERL_EXE) make_patchnum.pl
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
%/pm_to_blib: %/Makefile preplibrary
	$(MAKE) -C $(dir $@) all PERL_CORE=1 LIBPERL=libperl.a

#$(DYNALOADER): ext/DynaLoader/Makefile preplibrary $(nonxs_ext)
#	$(MAKE) -C ext/DynaLoader DynaLoader.o PERL_CORE=1 LIBPERL=libperl.a LINKTYPE=static $(STATIC_LDFLAGS)
#	cp ext/DynaLoader/DynaLoader.o .

$(static_ext):
	$(MAKE) -C $(dir $@) all PERL_CORE=1 LIBPERL=libperl.a LINKTYPE=static $(STATIC_LDFLAGS)

#$(dynamic_ext):	%/Makefile preplibrary makeppport $(DYNALOADER) FORCE $(PERLEXPORT)
#	$(MINIPERL) make_ext.pl $@ MAKE=$(MAKE) LIBPERL_A=$(LIBPERL) LINKTYPE=dynamic

%/Makefile: %/Makefile.PL miniperl$X miniperl_top preplibrary cflags
	$(eval top=$(shell echo $(dir $@) | sed -e 's![^/]\+!..!g'))
	cd $(dir $@) && $(top)miniperl_top Makefile.PL PERL_CORE=1 PERL=$(top)miniperl_top

cflags: cflags.SH
	sh $<

makefiles: $(ext:pm_to_blib=Makefile)

nonxs_ext: $(nonxs_ext)
dynamic_ext: $(dynamic_ext)
static_ext: $(static_ext)
extensions: uni.data cflags $(dynamic_ext) $(static_ext) $(nonxs_ext)

dynaloader: $(DYNALOADER)
$(DYNALOADER): miniperl$x preplibrary $(nonxs_ext)
	$(MINIPERL) make_ext.pl $@ MAKE=$(MAKE) LIBPERL_A=$(LIBPERL) LINKTYPE=static $(STATIC_LDFLAGS)

#d_dummy $(dynamic_ext):	miniperl$X preplibrary makeppport $(DYNALOADER) FORCE $(PERLEXPORT)
#	$(MINIPERL) make_ext.pl $@ MAKE=$(MAKE) LIBPERL_A=$(LIBPERL) LINKTYPE=dynamic
#
#s_dummy $(static_ext):	miniperl$X preplibrary makeppport $(DYNALOADER) FORCE
#	$(MINIPERL) make_ext.pl $@ MAKE=$(MAKE) LIBPERL_A=$(LIBPERL) LINKTYPE=static $(STATIC_LDFLAGS)

#n_dummy $(nonxs_ext):	miniperl$X preplibrary cflags
#	$(MINIPERL) make_ext.pl $@ MAKE=$(MAKE) LIBPERL_A=$(LIBPERL)

#.PHONY: makeppport
#makeppport: miniperl$X $(CONFIGPM)
#	./miniperl$X -Ilib mkppport

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
