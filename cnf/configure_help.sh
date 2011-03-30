#!/bin/sh

cat <<EOF
Usage:
	configure [--option[=value]] ...

Options are either self-explainatory or too obscure to be
documented here. In latter case check which config.sh variable you're
interested in and refer to Porting/Glossary for description (most
options are just slightly modified variable names).

	--help				show this message
	--mode=<mode>			(don't use this)
		--mode=cross		Force cross-compilation mode
	--regenerate			Re-generate config.h, xconfig.h and Makefile.config
					from config.sh and xconfig.sh

	--prefix=/usr			Used for default values only
	--html1dir=<dir>		For HTML documentation
	--html3dir=<dir>
	--man1dir=<dir>			For manual pages
	--man3dir=<dir>

	--build=<machine>		Default prefix for \$HOSTCC etc.
	--target=<machine>		Same, for primary \$CC
	--hints=<h1>,<h2>,...		Use specified hints (cnf/hints/<h1> etc.)
					Does not affect hint selection for modules
	
	--with-libs=<libs>		Comma-separated list of libraries to use
					(only basenames, use "dl" to have -ldl passed to linker)

	--with-cc=			C compiler
	--with-cpp=			C preprocessor
	--with-ranlib=			ranlib; set to 'true' or 'echo' if you don't need it
	--with-objdump=			objdump; only needed for some configure tests
					(all for target system when cross-compiling)
		
	--host-cc=			Same, for host system
	--host-cpp=			(only useful when cross-compiling)
	--host-ranlib=
	--host-objdump=			
	--host-libs=

	--target-cc=			Same, for/on target system.
	--target-cpp=			(not used by this script *at all*; set these
	--target-ranlib=		if you want to build modules natively on the
	--target-objdump=		target system)

	--sysroot=			path to (copy of) target system root

	--enable-<something>		See use<something> in Glossary
	--has-<function>		See d_<function> in Glossary
	--include-<header>[=yes|no]	Assume given header is present (or missing)
					in the system. E.g., disabling <sys/time.h>:
						--include-sys-time-h=no
	--set-<something>=value		See <something> in Glossary

	--host-<option>[=value]		Results in --<option>[=value] being passed to
					configure for the host system
					(only useful when cross-compiling)

	--static-mod=mod1,mod2,...	Build modules mod1, mod2, ..., statically
	--disable-mod=mod1,mod2,...	Do not build modules mod1, mod2, ...
					modX should be something like cpan/Archive-Extract
					static only applies to XS modules

Note: unlike traditional autoconf'ed scripts, this configure does not allow option values
without = sign ("--option value").

config.log contains verbose description of what was tested, and how.
Check it if configure output looks suspicious.
EOF
