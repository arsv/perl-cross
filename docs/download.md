# Cross-compiling perl

---

Current version of perl-cross is 1.1.0   
Supported perl versions: perl-5.24.0, perl-5.25.4, cperl-5.24.0, cperl-5.25.0.   
Download it here:

!!! note " "
    <https://github.com/arsv/perl-cross/releases/download/1.1.0/perl-cross-1.1.0.tar.gz>

To use, unpack over an appropriate perl distribution, overwriting the original Makefile.
Use one of supported perl versions; the are version-specific patches inside.

For older releases, check [GitHub releases branch](https://github.com/arsv/perl-cross/tree/releases).

## Changelog
- 1.1.0 (2016-09-12)
    + Major code cleanup
    + Package name changed to `perl-cross-N.M.tar.gz`
    + Support for multiple perl versions
    + Experimental cperl support
    + General list of config.sh variables (configure_genc.sh) removed; values are now written to config.sh immediately
    + bash is no longer necessary to run configure; dash or busybox sh should be enough
    + Extended -A support removed (prepend and such)
    + Build host info (cf_by, cf_email etc) is no longer passed to config.sh
    + Various test fixes, and some new tests
    + Hints re-arranged, support for compiler hints removed
    + Newer gcc get -fwrapv -fno-strict-aliasing in ccflags
    + `gccversion` is now set for any cc
- 1.1 (2016-09-10) &mdash; botched release, see 1.1.0 instead
- 1.0.3 (2016-06-30)
    + perl-5.24.0
    + Android detection and proper osname
    + Errno.pm building fixed for Android
    + fixed rpath handling in presence of --sysroot
    + busybox sed may be used now instead of GNU sed
- 1.0.2 (2015-12-15)
    + perl-5.22.1
    + Berkeley DB detection fix (DB::File)
- 1.0.1 (2015-11-03)
    + poisoned paths patch from Buildroot
    + disable gcc built-ins to avoid false positives in hasfunc
    + proper escaping for values written to config.sh
- 1.0.0 (2015-08-26)
    + perl-5.22.0
    + floating-point functions detection and minor updates
    + absolutely nothing special about this release
- 0.9.7 (2015-06-28)
    + MakeMaker library detection fixes
    + better --no-dynaloader / --all-static options handling
- 0.9.6 (2015-03-07)
    + a2p yacc invocation suppressed for 5.20.2 sources
- 0.9.5 (2015-02-24)
    + perl 5.20.2
    + --sysroot handling fixed
- 0.9.4 (2014-11-04)
    + --all-static fix
- 0.9.3 (2014-10-14)
    + perl 5.20.1
    + bigendian target byteorder detection fix
- 0.9.2 (2014-09-20)
    + minor updates to handle perl 5.20.1-RC1
    + soname'd libperl installation
- 0.9.1 (2014-08-26)
    + module cleanup for 5.20.0
    + host-installed miniperl stuff removed
- 0.9 (2014-08-01)
    + perl-5.20.0
- 0.8.5 (2014-02-23)
    + out-of-source builds with absolute path to the source
    + patch --follow-symlinks is not used anymore
- 0.8.4 (2014-02-20)
    + variable/versioned libperl.so
    + out-of-source building support
    + default paths fixed (sitescript/vendorscript)
    + some Makefile fixes
    + project moved to GitHub
- 0.8.3 (2013-10-19)
    + Testpack for on-target testing
    + $extensions, ${static,dynamic,nonxs}_ext format changed to match Configure
    + $sharepath default fixed
- 0.8.2 (2013-09-09)
    + NV-related tests added
    + C++ and ELF format test added
    + largefile flags are now passed correctly to tests & modules
    + $ccdefines variable dropped in favor of $ccflags
    + hint files handling changed
    + config.sh variables list updated to match current Configure closely
    + --with-*, --host-* options handling fixed
- 0.8.1 (2013-09-05)
    + perl-5.18.1 (with no changes to perl-cross)
    + test-related fixes
- 0.8 (2013-08-08)
    + perl-5.18.0
    + module stubs are provided for ExtUtils::* to make them usable with miniperl
    + patch application is now done as a bulk phony target; patching the files in-place doen't translate well into make-dependencies
    + module paths fixes
    + Makefile dependencies cleaned up
- 0.7.4 (2013-04-11)
    + shared libperl support; enable with -Duseshrplib
    + nv_preserves_uv stuff reset to safe defaults; it can't be tested for currently, but at least it won't cause precision issues
- 0.7.3 (2013-04-05)
    + libs/perllibs split, and libswanted handling fixes; NDBM is properly linked now
    + standard format for extensions lists in $Config
    + install paths adjusted to match mainline perl
    + $libpth default value added, DynaLoader::dl_findfile should work now
    + drop-in replacement for Digest::MD5, calling Digest::Perl::MD5; no need to alter existing scripts anymore
    + patched Liblist now warns about non-usable libraries (and passes relevant tests)
    + minor config.sh tweaks
- 0.7.2 (2013-03-25)
    + perl-5.16.3
    + preliminary "make test" support (native builds only for now)
    + specifying --mode manually should work as expected in most cases
    + various configure/Makefile fixes
- 0.7.1 (2012-12-15)
    + use gcc for dynalinking modules
- 0.7 (2012-07-06)
    + perl-5.16.0
    + original perl files are now patched (vs. supplying modified versions)
    + Digest::Perl::MD5 added to allow using install{perl,man} with miniperl
    + Module name handling fixed in make_ext_Makefile.pl
    + archlib is now $prefix/lib/perl/$archname, instead of just $prefix/lib/perl/arch
    + d_csh set to undef, to prevent glob() failures
    + useithreads and use5005threads handling added
- 0.6.5 (2012-02-16)
    + inttypes.h added in byte order test
- 0.6.4 (2011-12-05)
    + /bin/sh changed to /bin/bash, take 2
- 0.6.3 (2011-11-02)
    + perl-5.14.2 (without any actual changes to perl-cross)
    + /bin/sh changed to /bin/bash everywhere
- 0.6.2 (2011-09-03)
    + Android and Intel CC builds support
    + --sysroot is now passed to compiler/linker
    + target specifications not recognized by config.sub are allowed
    + several configure tests fixes
    + no-DynaLoader configuration support
- 0.6.1 (2011-08-24)
    + static modules handling fixed
    + --all-static option for configure
- 0.6 (2011-08-20)
    + perl-5.14 support
    + make rules to build disabled modules
    + hints switched to flat directory style, added compiler and mode hints
    + libswanted handling fixed
    + configure now reads patchlevel.h to get perl version
    + minor fixes & cleanup
- 0.5 (2011-07-23)
    + need_va_copy bug fixed (this is what caused build errors on x86_64)
    + configure can now load configuration from a file (-f, -O)
    + support for most of the original Configure options (inc. -D, -U, -A)
    + --set/-D now allow passing arbitrary variables to config.sh
    + make rules to track MakeMaker dependencies
    + ccflags/ldflags support fixed
    + -DEBUGGING support added
    + environment clean-up added, configure no longer stumbles upon stray environment variables
    + Time::HiRes specific hints to allow successful builds
    + removed module tests for miniperl
- 0.4.1 (2011-04-25)
    + make rules for xsubpp changed
    + fixed static modules handling
- 0.4 (2011-03-11)
    + perl-5.12 support
    + miniperl_top introduced
    + make rules for all modules, make_ext is no longer used
- 0.3 (2011-03-04)
    + threads support
    + various fixes done after the demise of the old site
- 0.2 (2009-12-06)
    + make rules for DynaLoader fixed
    + other minor fixes to allow MIPS build
- 0.1 (2009-01-05)
    + first public release
