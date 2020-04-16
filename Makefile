default: all

include Makefile.config

CONFIGPM = lib/Config.pm lib/Config_git.pl
CONFIGPOD = lib/Config.pod
STATIC = static
# Note: MakeMaker will look for xsubpp only in specific locations
# This is one of them; but dist/ExtUtils-ParseXS isn't.
XSUBPP = lib/ExtUtils/xsubpp
# For autodoc.pl below
MANIFEST_CH = $(shell sed -e 's/\s.*//' MANIFEST | grep '\.[ch]$$')
# cpan/Pod-Perldoc/Makefile does not accept PERL_CORE=1 in MM command line,
# it needs the value to be in $ENV
export PERL_CORE=1

POD1 = $(wildcard pod/*.pod)
MAN1 = $(patsubst pod/%.pod,man/man1/%$(man1ext),$(POD1))

# Different perl version come with slightly different source lists.
# Only pick files actually present in the source tree.
# perl.c, perlmain.c, op.c, miniperl.c should not be in this list
src = av.c scope.c doop.c doio.c dump.c gv.c hv.c mg.c reentr.c mro_core.c
src += perly.c pp.c pp_hot.c pp_ctl.c pp_sys.c regcomp.c regexec.c
src += utf8.c sv.c taint.c toke.c util.c deb.c run.c universal.c
src += pad.c globals.c keywords.c perlio.c perlapi.c numeric.c
src += mathoms.c locale.c pp_pack.c pp_sort.c caretx.c dquote.c $(time64.c)
src += pp_type.c xsutils.c # cperl
src += $(mallocsrc)

obj = $(patsubst %.c,%$o,$(wildcard $(src)))

static_modules = $(patsubst %,%/pm_to_blib,$(fullpath_static_ext))
dynamic_modules = $(patsubst %,%/pm_to_blib,$(fullpath_dynamic_ext))
nonxs_modules = $(patsubst %,%/pm_to_blib,$(fullpath_nonxs_ext))
disabled_dynamic = $(patsubst %,%/pm_to_blib,$(disabled_dynamic_ext))
disabled_nonxs = $(patsubst %,%/pm_to_blib,$(disabled_nonxs_ext))
# perl module names for static mods
static_pmn = $(shell for e in $(fullpath_static_ext) ; do grep '^NAME =' $$e/Makefile | cut -d' ' -f3 ; done)

dynaloader_o = $(patsubst %,%$o,$(dynaloader))

modules = $(fullpath_nonxs_ext) $(fullpath_dynamic_ext) $(fullpath_static_ext)
disabled = $(disabled_nonxs_ext) $(disabled_dynamic_ext)

# ---[ perl-cross patches ]-----------------------------------------------------
# Note: the files are patched in-place, and so do not make valid make-rules
# Because of this, they are only applied loosely, allowing the user to intervene
# if need be.
CROSSPATCHES = $(shell find cnf/diffs/$(patchset) -name '*.patch')
CROSSPATCHED = $(patsubst %.patch,%.applied,$(CROSSPATCHES))

.PHONY: crosspatch

crosspatch: $(CROSSPATCHED)

# A minor fix for buildroot, force crosspatching when running "make perl modules"
# instead of "make all".
miniperlmain$O: crosspatch

# Original versions are not saved anymore; patch generally takes care of this,
# and if that fails, reaching for the source tarball is the safest option.
$(CROSSPATCHED): %.applied: %.patch
	patch -p1 -i $< && touch $@

# ---[ common ]-----------------------------------------------------------------

# Do NOT delete any intermediate files
# (mostly Makefile.PLs, but others can be annoying too)
.SECONDARY:

# Force full patching before any building starts. Als, force early building
# of miniperl -- not really necessary, but makes the build process more logical.
# No reason to try CC if HOSTCC fails.
#
# Dynaloader is also built separately as race failures have been observed.
all:
	$(MAKE) crosspatch
	$(MAKE) miniperl$X
	$(MAKE) dynaloader
	$(MAKE) perl$x nonxs_ext utilities extensions pods

config.h: config.sh config_h.SH
	CONFIG_H=$@ CONFIG_SH=$< ./config_h.SH

xconfig.h: xconfig.sh config_h.SH
	CONFIG_H=$@ CONFIG_SH=$< ./config_h.SH

# Prevent the following rule from overwriting Makefile by running Makefile.SH
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

uudmap.h bitcount.h mg_data.h: generate_uudmap$X
	./generate_uudmap uudmap.h bitcount.h mg_data.h

opmini.c: op.c
	cp -f $^ $@

opmini$O: opmini.c
	$(HOSTCC) $(HOSTCFLAGS) -DPERL_EXTERNAL_GLOB -c -o $@ $<

perlmini.c: perl.c
	cp -f $^ $@

perlmini$O: perlmini.c
	$(HOSTCC) $(HOSTCFLAGS) -DPERL_IS_MINIPERL -c -o $@ $<
	
# Do not re-generate perly.c and perly.h even if they appear out-of-date.
# Use "make regen_perly" to force update.
# The following rule cancels implicit .y -> .c make would use otherwise
%.c: %.y

regen_perly:
	perl regen_perly.pl

# ---[ site/perl ]--------------------------------------------------------------

ifeq ($(useshrplib),true)
ifeq ($(soname),)
perl$x: LDFLAGS += -Wl,-rpath,$(archlib)/CORE
endif
endif # or should it be "else"?
perl$x: LDFLAGS += -Wl,-E

perl$x: perlmain$o $(LIBPERL) $(static_modules) static.list ext.libs
	$(eval extlibs=$(shell cat ext.libs))
	$(eval statars=$(shell cat static.list))
	$(CC) $(LDFLAGS) -o $@ $(filter %$o,$^) $(LIBPERL) $(statars) $(LIBS) $(extlibs)

%$o: %.c config.h
	$(CC) $(CFLAGS) -c -o $@ $<

globals.o: uudmap.h

perlmain.c: ext/ExtUtils-Miniperl/pm_to_blib $(patsubst %,%/Makefile,$(fullpath_static_ext)) | miniperl$X
	./miniperl_top -MExtUtils::Miniperl -e 'writemain(\"$@", @ARGV)' $(dynaloader) $(static_pmn)

ext.libs: Makefile.config $(patsubst %,%/Makefile,$(fullpath_static_ext)) | $(static_modules) miniperl$X
	./miniperl_top extlibs $(static_pmn) > $@

static.list: Makefile.config $(patsubst %,%/Makefile,$(fullpath_static_ext)) | $(static_modules) miniperl$X
	./miniperl_top statars $(static_pmn) > $@

# ---[ site/library ]-----------------------------------------------------------

libperl: $(LIBPERL)

$(LIBPERL): op$o perl$o $(obj) $(dynaloader_o)

# It would be better to test for static-library suffix here, but the suffix
# is not used explicitly anywhere else, including in -Dlibperl=
# So let's make it so that useshrplib controls the kind of the library
# regardless of the library name.
# This is in-line with gcc and ld behavior btw.
ifneq ($(soname),)
$(LIBPERL): LDDLFLAGS += -Wl,-soname -Wl,$(soname)

  ifneq ($(soname),$(LIBPERL))
$(LIBPERL): $(soname)
$(soname):
	ln -sf $(LIBPERL) $@

  endif
endif

ifeq ($(useshrplib),true)
$(LIBPERL):
	$(CC) $(LDDLFLAGS) -o $@ $(filter %$o,$^) $(LIBS)
else
$(LIBPERL):
	$(AR) cru $@ $(filter %$o,$^)
	$(RANLIB) $@
endif

perl.o: git_version.h

config-pm: $(CONFIGPM)
configpod: $(CONFIGPOD)

# Both git_version.h and lib/Config_git.pl are built
# by make_patchnum.pl.
git_version.h lib/Config_git.pl: make_patchnum.pl | miniperl$X
	./miniperl_top make_patchnum.pl

lib/Config.pm lib/Config_heavy.pl lib/Config.pod: config.sh cflags \
		lib/Config_git.pl Porting/Glossary | miniperl$X
	./miniperl_top configpm

# NOT used by this Makefile, replaced by miniperl_top
# Avoid building.
lib/buildcustomize.pl: write_buildcustomize.pl | miniperl$X
	./miniperl$X -Ilib $< > $@

# ---[ Modules ]----------------------------------------------------------------

# The rules below replace make_ext script used in the original
# perl build chain. Some host-specific functionality is lost.
# Check miniperl_top to see how it works.
$(nonxs_modules) $(disabled_nonxs): %/pm_to_blib: | %/Makefile
	$(MAKE) -C $(dir $@) all PERL_CORE=1 LIBPERL=$(LIBPERL)

DynaLoader$o: | ext/DynaLoader/pm_to_blib
	@if [ ! -f ext/DynaLoader/DynaLoader$o ]; then rm $<; echo "Stale pm_to_blib, please re-run make"; false; fi
	cp ext/DynaLoader/DynaLoader$o $@

ext/DynaLoader/pm_to_blib: %/pm_to_blib: | %/Makefile
	$(MAKE) -C $(dir $@) all PERL_CORE=1 LIBPERL=$(LIBPERL) LINKTYPE=static static

ext/DynaLoader/Makefile: config.h | dist/lib/pm_to_blib

$(static_modules): %/pm_to_blib: | %/Makefile $(nonxs_tgt)
	$(MAKE) -C $(dir $@) all PERL_CORE=1 LIBPERL=$(LIBPERL) LINKTYPE=static static

$(dynamic_modules) $(disabled_dynamic): %/pm_to_blib: | %/Makefile
	$(MAKE) -C $(dir $@) all PERL_CORE=1 LIBPERL=$(LIBPERL) LINKTYPE=dynamic

lib/re.pm: ext/re/re.pm
	cp -f ext/re/re.pm lib/re.pm

lib/lib.pm: dist/lib/pm_to_blib

.PHONY: preplibrary

preplibrary: $(CONFIGPM) | miniperl$X lib/re.pm lib/lib.pm

dist/lib/Makefile: dist/lib/Makefile.PL cflags config.h $(CONFIGPM) | miniperl$X
	$(eval top=$(shell echo $(dir $@) | sed -re 's![^/]+!..!g'))
	cd $(dir $@) && $(top)miniperl_top -I$(top)lib Makefile.PL \
	 PERL_CORE=1 LIBPERL_A=$(LIBPERL) PERL="$(top)miniperl_top"

%/Makefile: %/Makefile.PL preplibrary cflags config.h | $(XSUBPP) miniperl$X
	$(eval top=$(shell echo $(dir $@) | sed -re 's![^/]+!..!g'))
	cd $(dir $@) && $(top)miniperl_top -I$(top)lib Makefile.PL \
	 INSTALLDIRS=perl INSTALLMAN1DIR=none INSTALLMAN3DIR=none \
	 PERL_CORE=1 LIBPERL_A=$(LIBPERL) PERL="$(top)miniperl_top"

# Allow building modules by typing "make cpan/Module-Name"
.PHONY: $(modules) $(disabled)
$(modules) $(disabled): %: %/pm_to_blib

.PHONY: nonxs_ext dynamic_ext static_ext extensions modules

nonxs_ext: $(nonxs_modules)
dynamic_ext: $(dynamic_modules)
static_ext: $(static_modules)
extensions: cflags nonxs_ext dynamic_ext static_ext
modules: extensions

# Some things needed to make modules
%/Makefile.PL: | miniperl$X
	./miniperl_top make_ext_Makefile.pl $@

cflags: cflags.SH
	sh $<

.PHONY: makeppport

makeppport: $(CONFIGPM) | miniperl$X
	./miniper_top mkppport

makefiles: $(patsubst %,%/Makefile,$(modules))

dynaloader: $(dynaloader_o)

$(ppport)/pm_to_blib: dynaloader

$(ppport)/PPPort.pm: $(ppport)/pm_to_blib

$(ppport)/ppport.h: $(ppport)/PPPort.pm | miniperl$X
	cd $(ppport) && ../../miniperl -I../../lib ppport_h.PL

cpan/Unicode-Normalize/Makefile: lib/unicore/CombiningClass.pl
dist/Unicode-Normalize/Makefile: lib/unicore/CombiningClass.pl

# mktables does not touch the files unless they need to be rebuilt,
# which confuses make.

pod/perluniprops.pod: lib/unicore/CombiningClass.pl

lib/unicore/CombiningClass.pl: $(CONFIGPM)
	./miniperl_top lib/unicore/mktables -w -C lib/unicore -P pod -maketest -makelist -p

# The following rules ensure that modules listed in mkppport.lst get
# their ppport.h installed.
mkppport_lst = $(shell cat mkppport.lst | grep '^[a-z]')

$(patsubst %,%/pm_to_blib,$(mkppport_lst)): %/pm_to_blib: %/ppport.h
# This one does not fit the above pattern
cpan/YAML-LibYAML/pm_to_blib: cpan/YAML-LibYAML/LibYAML/ppport.h
# Having %/ppport.h here isn't a very good idea since the initial ppport.h matches
# the pattern too
$(patsubst %,%/ppport.h,$(mkppport_lst)): $(ppport)/ppport.h
	cp -f $< $@

lib/ExtUtils/xsubpp: dist/ExtUtils-ParseXS/lib/ExtUtils/xsubpp
	cp -f $< $@

# No ExtUtils dependencies here because that's where they come from
cpan/ExtUtils-ParseXS/Makefile cpan/ExtUtils-Constant/Makefile: \
		%/Makefile: %/Makefile.PL preplibrary cflags | miniperl$X miniperl_top
	$(eval top=$(shell echo $(dir $@) | sed -re 's![^/]+!..!g'))
	cd $(dir $@) && $(top)miniperl_top Makefile.PL PERL_CORE=1 PERL=$(top)miniperl_top

cpan/List-Util/pm_to_blib: | dynaloader

ext/Pod-Functions/pm_to_blib: | cpan/Pod-Simple/pm_to_blib

cpan/Pod-Simple/pm_to_blib: | cpan/Pod-Escapes/pm_to_blib

$(dynamic_modules): | $(dynaloader_o) dist/ExtUtils-CBuilder/pm_to_blib

dist/ExtUtils-CBuilder/pm_to_blib: | cpan/Perl-OSType/pm_to_blib cpan/Text-ParseWords/pm_to_blib

# ---[ modules cleanup & rebuilding ] ------------------------------------------

.PHONY: modules-reset modules-makefiles modules-clean

modules-reset:
	$(if $(nonxs_modules),    rm -f $(nonxs_modules))
	$(if $(static_modules),   rm -f $(static_modules))
	$(if $(dynamic_modules),  rm -f $(dynamic_modules))
	$(if $(disabled_nonxs),   rm -f $(disabled_nonxs))
	$(if $(disabled_dynamic), rm -f $(disabled_dynamic))

modules-makefiles: makefiles

modules-clean: clean-modules

# ---[ Misc ]-------------------------------------------------------------------

.PHONY: utilities

utilities: miniperl$X $(CONFIGPM)
	$(MAKE) -C utils all

# ---[ modules lists ]----------------------------------------------------------
modules.done: modules.list
	echo -n > modules.done
	-cat $< | (while read i; do $(MAKE) -C $$i && echo $$i >> modules.done; done)

modules.pm.list: modules.done
	-cat $< | (while read i; do find $$i -name '*.pm'; done) > $@

modules.list: $(CONFIGPM) $(MODLISTS) cflags
	./modconfig_all

# ---[ pods ]-------------------------------------------------------------------
pod/perltoc.pod: modules extra.pods \
	pod/perlapi.pod \
	pod/perlintern.pod \
	pod/perlmodlib.pod \
	pod/perluniprops.pod \
	pod/$(perldeltapod)

pods: pod/perltoc.pod

pod/perltoc.pod: pod/buildtoc | miniperl$X
	./miniperl_top -f pod/buildtoc -q

pod/perlapi.pod: pod/perlintern.pod

pod/perlintern.pod: autodoc.pl embed.fnc | miniperl$X 
	./miniperl_top autodoc.pl

pod/perlmodlib.pod: pod/perlmodlib.PL MANIFEST | miniperl$X
	./miniperl_top pod/perlmodlib.PL -q

pod/$(perldeltapod): pod/perldelta.pod
	ln -sf $(notdir $<) $@

ifdef perlcdeltapod
pod/$(perlcdeltapod): pod/perlcdelta.pod
	ln -sf $(notdir $<) $@

pod/perltoc.pod: pod/$(perlcdeltapod)
endif

extra.pods: | miniperl$X
	-@test ! -f extra.pods || rm -f `cat extra.pods`
	-@rm -f extra.pods
	-@for x in `grep -l '^=[a-z]' README.* | grep -v README.vms` ; do \
	    nx=`echo $$x | sed -e "s/README\.//"`; \
	    ln -sf ../$$x "pod/perl"$$nx".pod" ; \
	    echo "pod/perl"$$nx".pod" >> extra.pods ; \
	done

# ---[ test ]-------------------------------------------------------------------

.PHONY: test
test:
	cd t/ && ln -sf ../perl . && LD_LIBRARY_PATH=$(PWD) ./perl harness

# ---[ install ]----------------------------------------------------------------
.PHONY: install install.perl install.sym install.pod

META.yml: Porting/makemeta Porting/Maintainers.pl Porting/Maintainers.pm miniperl$X
	./miniperl_top $<

install:
	$(MAKE) install.perl
	$(MAKE) install.man

install.perl: installperl | miniperl$X
	./miniperl_top installperl --destdir=$(DESTDIR) $(INSTALLFLAGS) $(STRIPFLAGS)
	-@test ! -s extras.lst || $(MAKE) extras.install
ifneq ($(perlname),perl)
	-rm -f $(DESTDIR)$(installbin)/$(perlname)$(version)
	ln -sf $(perlname) $(DESTDIR)$(installbin)/perl
else
	-rm -f $(DESTDIR)$(installbin)/$(perlname)$(version)
endif

install.sym: # deprecated

install.man: installman pod/perltoc.pod | miniperl$X
	./miniperl_top installman --destdir=$(DESTDIR) $(INSTALLFLAGS)

# ---[ testpack ]---------------------------------------------------------------
.PHONY: testpack
testpack: TESTPACK.tar.gz

TESTPACK.list: | miniperl$X TESTPACK.px
	./miniperl$X TESTPACK.px TESTPACK.list TESTPACK
TESTPACK.tar.gz: TESTPACK.list
	tar -zcvf $@ -T $<

# ---[ clean ]------------------------------------------------------------------
# clean-modules must go BEFORE clean-generated-files because it depends on config.h!
.PHONY: clean clean-obj clean-generated-files clean-subdirs clean-modules clean-testpack
clean: clean-obj clean-modules clean-generated-files clean-subdirs clean-testpack

clean-obj:
	-test -n "$o" && rm -f *$o
	-test -n "$O" && rm -f *$O

clean-subdirs:
	$(MAKE) -C utils clean

# assuming modules w/o Makefiles were never built and need no cleaning
clean-modules: config.h
	@for i in $(modules disabled); do \
		test -f $$i/Makefile && \
		touch $$i/Makefile && \
		$(MAKE) -C $$i clean \
		|| true; \
	done

clean-generated-files:
	-rm -f uudmap.h opmini.c generate_uudmap$X bitcount.h $(CONFIGPM)
	-rm -f git_version.h lib/re.pm lib/Config_git.pl
	-rm -f perlmini.c perlmain.c
	-rm -f config.h xconfig.h
	-rm -f pod/perlmodlib.pod
	-rm -f ext.libs static.list
	-rm -f $(patsubst %,%/ppport.h,$(mkppport_lst))
	-rm -f $(ppport)/ppport.h $(ppport)/PPPort.pm

clean-testpack:
	-rm -fr TESTPACK
	-rm -f TESTPACK.list
