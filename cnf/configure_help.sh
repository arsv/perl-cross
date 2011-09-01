#!/bin/bash

cat <<EOF
Usage:
	configure [options]

configure adheres to common GNU autoconf style, but also accepts most
of the original Configure options. Both short (-D) and long (--define)
options are supported. Valid ways to supply arguments for the options:
-f config.sh, -fconfig.sh -D key=val, -Dkey=val, --set-key=val, --set key=val.
Whenever necessary, dashes in "key" are converted to underscores so it's ok
to use --set-d-something instead of --set-d_something.

The options themselves are either self-explainatory or too obscure to be
documented here. In latter case check which config.sh variable you're
interested in and refer to Porting/Glossary for description.

	--help			show this message
	--mode=<mode>		(don't use this)
		--mode=cross	Force cross-compilation mode
	--regenerate		Re-generate config.h, xconfig.h
				and Makefile.config
				from config.sh and xconfig.sh

	--prefix=/usr		Installation prefix
	--html1dir=<dir>	For HTML documentation
	--html3dir=<dir>
	--man1dir=<dir>		For manual pages
	--man3dir=<dir>

	--build=<machine>	Default prefix for \$HOSTCC etc.
	--target=<machine>	Same, for primary \$CC
	--target-tools-prefix=<p>	same, but doesn't affect targetarch etc.
	--hints=<h1>,<h2>,...	Use specified hints (cnf/hints/<h1> etc.)
				Does not affect hint selection for modules
	
	--with-libs=<libs>	Comma-separated list of libraries to use
				(only basenames, use "dl" to have -ldl
				 passed to linker)

	--with-cc=		C compiler
	--with-cpp=		C preprocessor
	--with-ranlib=		ranlib; set to 'true' or 'echo' if
				 you don't need it
	--with-objdump=		objdump; only needed for some tests
		
	--host-cc=		Same, for host/build system
	--host-cpp=		(only useful when cross-compiling)
	--host-ranlib=
	--host-objdump=			
	--host-libs=

	--sysroot=		path to (copy of) target system root

Options from the original Configure which are not supported or make
no sense for this version of configure:

	-e		go on without questioning past the production
			 of config.sh (ignored)
	-E		stop at the end of questions, after having
			 produced config.sh (ignored)
	-r		reuse C symbols value if possible, skips costly
			 nm extraction (ignored, other method is used)
	-s		silent mode (ignored)
	-K		(not supported)
	-S		perform variable substitutions on all .SH files
			 (ignored)
	-V 		show version number (not supported)

The following options are used to manipulate the values configure will
write to config.sh. Check Porting/Glossary for the list of possible
symbols.

	-d		(ignored) use defaults for all answers.
	-f file.sh	load configuration from specified file
	-h		(ignored)
	-D symbol[=value]	define symbol to have some value:
		-D symbol         symbol gets the value 'define'
		-D symbol=value   symbol gets the value 'value'
	    common used examples (see INSTALL for more info):
		-Duse64bitint            use 64bit integers
		-Duse64bitall            use 64bit integers and pointers
		-Dusethreads             use thread support (also --use-threads)
		-Dinc_version_list=none  do not include older perl trees in @INC
		-DEBUGGING=none          DEBUGGING options
		-Dcc=gcc                 same as --with-cc=gcc
		-Dprefix=/opt/perl5      same as --prefix=/opt/perl5
	-O		let -D and -U override definitions
			 from loaded configuration file.
	-U symbol	undefine symbol:
		-U symbol    symbol gets the value 'undef'
		-U symbol=   symbol gets completely empty
		e.g.:  -Uversiononly

	-A [a:]symbol=value	manipulate symbol after the platform specific
				hints have been applied:
		-A append:symbol=value   append value to symbol
		-A symbol=value          like append:, but with a separating space
		-A define:symbol=value   define symbol to have value
		-A clear:symbol          define symbol to be ''
		-A define:symbol         define symbol to be 'define'
		-A eval:symbol=value     define symbol to be eval of value
		-A prepend:symbol=value  prepend value to symbol
		-A undef:symbol          define symbol to be 'undef'
		-A undef:symbol=         define symbol to be ''
		e.g.:   -A prepend:libswanted='cl pthread '
			-A ccflags=-DSOME_MACRO


	--enable-<something>		Set use<something> to 'define'
	--has-<function>		Set d_<function> to 'define'
	--include-<header>[=yes|no]	Set i_<header> to 'define' or 'undef'
					e.g. for <sys/time.h>:
						--include-sys-time-h=no
	--set symbol=value		Set symbol to value

When configuring a cross-build, -D/--set and other similar options affect
target perl configuration (config.sh) only. Use the following options if
you need to tweak xconfig.sh:

	--host-<option>[=value]		Pass --<option>[=value] to miniperl
					configure on the host system (xconfig.sh)
			e.g. --host-define-foo, --host-set-foo=bar

	--target-<option>[=value]	(same for tconfig.sh; do not use)

Generally configure tries to build all modules it can find in the source tree.
Use the following options to alter modules list:

	--static-mod=mod1,mod2,...	Build specified modules statically
	--disable-mod=mod1,mod2,...	Do not build specified modules
					modX should be something like
					cpan/Archive-Extract
					static only applies to XS modules
	--only-mod=mod1,mod2,...	Build listed modules only

	--disable-disabled-mods		Do not generate make rules for	
					disabled modules. Without this option,
					any module found by counfigure can be built
					manually with "make cpan/Module-Name".
	--all-static			Build all found XS modules as static
					unless specified otherwise

config.log contains verbose description of what was tested, and how.
Check it if configure output looks suspicious.
EOF
