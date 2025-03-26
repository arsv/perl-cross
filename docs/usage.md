# Cross-compiling perl

---

Unpack perl-X.Y.Z-cross-W.Q.tar.gz over perl-X.Y.Z distribution.   
Perl-cross package should overwrite top-level Makefile and some other files
in the perl source tree.

The build process is similar to that of most autoconf-based packages.
For a native build, use something like

```sh
./configure --prefix=/usr
make
make DESTDIR=/some/tmp/dir install
```

For a cross-build, specify your target:

```sh
./configure --prefix=/usr --target=i586-pc-linux-uclibc
make
make DESTDIR=/some/tmp/dir install
```

Check below for [other possible make targets](#make targets).

## Target-specific notes

**Android**, assuming NDK is installed in `/opt/android-ndk`:

```sh
ANDROID=/opt/android-ndk
TOOLCHAIN=arm-linux-androideabi-4.9/prebuilt/linux-x86_64
PLATFORM=$ANDROID/platforms/android-16/arch-arm
export PATH=$PATH:$ANDROID/toolchains/$TOOLCHAIN/bin
./configure --target=arm-linux-androideabi --sysroot=$PLATFORM
```

Adjust platform and compiler version to match your particular NDK.

**arm-linux-uclibc**: successful build is highly likely.   
Check target tools prefix, it may be useful here, especially
if `--sysroot` is used.

```sh
./configure --target=arm-linux-uclibc --target-tools-prefix=arm-linux-
```

**ix86-* with Intel cc**, native build: use `-Dcc=icc`.
Configure will not supply any optimization options to the compiler,
consider `-Doptimize` if necessary.

**MinGW32**: cannot be built yet. Configure will produce config.sh,
but current perl-cross Makefiles can't handle win32 build.

```sh
./configure --target=i486-mingw32 --no-dynaloader
```

## Complete configure options list

Overall call order:

```sh
configure [options]
```

Perl-cross configure adheres to common GNU autoconf style, but also accepts
most of the original Configure options. Both short and long options
are supported (`-D`, `--define`).

Valid ways to supply arguments for the options:

+ `-f config.sh`
+ `-fconfig.sh`
+ `-D key=val`
+ `-Dkey=val`
+ `--set-key=val`
+ `--set key=val`

Whenever necessary, dashes in "key" are converted to underscores; use
`--set-d-something` instead of `--set-d_something`.

The only essential thing configure does is writing `config.sh`
(and possibly `xconfig.sh`). Most options are meant to alter the values
written there. Refer to Porting/Glossary for description of variables found in
`config.sh`. This page only decribes _how_ to modify them,
not _which values_ to use.

General configure control options:

--help
:   dump a short help message on stdout and exit

--mode=(native|cross|target|buildmini)
:   set configure mode; used internally

--keeplog
:   Append to config.log instead of truncating it;
    used internally.

--regenerate
:   Re-generates config.h, xconfig.h and Makefile.config
    from config.sh and xconfig.sh.
    Does not change config.sh or xconfig.sh.

General installation setup:

--prefix=_/usr_
:   Installation prefix (on the target).

--html{1,3}dir=_dir_
:   Installation prefix for HTML documentation (not used)

--man{1,3}dir=_dir_
:   Installation prefix for manual pages

--target=_machine_
:   Target description (e.g. i586-pc-linux-uclibc);
    _machine_-gcc, _machine_-ld, _machine_-ar will be
    used for target build unless explicitly overriden, and perl
    `archname` will be set to _machine_. Hints will be
    choosen based on this value.

--target-tools-prefix=_prefix_
:    Use _prefix_-gcc, _prefix_-ld without overridin
    `archname`.

--build=_machine_
:   Same as --target but for host executables (miniperl)

--hints=_h1,h2,..._
:   Suggest specified hint files (cnf/hints/h1 and so on).
    The hints are processed after other options,
    see [Workflow]() below.

--with-libs=_lib1,lib2,..._
:   Comma-separated list of libraries to check
    (basenames only, use "dl" to have -ldl passed to the linker).

--with-cc=_cmd_
:   (target) C compiler.

--with-cpp=_cmd_
:   (target) C preprocessor.

--with-ranlib=_cmd_
:   (target) ranlib; set to 'true' or 'echo' to disable.

--with-objdump=_cmd_
:   (target) objdump; not used during the build,
    but crucial for some configure test.

--host-cc=_cmd_
:   

--host-cpp=_cmd_
:   

--host-ranlib=_cmd_
:   

--host-objdump=_cmd_
:   

--host-libs=_cmd_
:   Same, for host executables.
    Only useful when cross-compiling.

--sysroot=_/path_
:   Passed directly to target compiler, linker and preprocessor.
    See gcc(1) on how to use this option.

Options from the original Configure which are not supported or make
no sense for this version of configure:

-e
:   go on without questioning past the production of config.sh
    (ignored, you'll have to run make manually)

-E
:   stop at the end of questions, after having produced
    Jconfig.sh (ignored, that's the only way perl-cross works)

-r
:   reuse C symbols value if possible, skips costly nm
    extraction (ignored, configure uses completely different method
    of checking function availability)

-s
:   silent mode (ignored, perl-cross has no other modes)

-K
:   (not supported)

-S
:   perform variable substitutions on all .SH files
    (ignored, configure can't do that)

-V
:   show version number (not supported)

-d
:   use defaults for all answers (ignored, default mode)

-h
:   show help (ignored, use --help instead)

The following options are used to manipulate the values configure will
write to config.sh. Check Porting/Glossary for the list of possible
symbols.

-f _file.sh_
:   load configuration from a file.
    See Workflow below.

-D _symbol_[=_value_]
:   set value for symbol; default _value_ is "define".
    Common examples (see INSTALL for more info):

    + `-Duse64bitint` use 64bit integers
    + `-Duse64bitall` use 64bit integers and pointers
    + `-Dusethreads` use thread support (also `--enable-threads`)
    + `-Dinc_version_list=none` do not include older perl trees in @INC
    + `-DEBUGGING=none` DEBUGGING options
    + `-Dcc=gcc` same as `--with-cc=gcc`
    + `-Dprefix=/opt/perl5` same as `--prefix=/opt/perl5`

-U _symbol_
:   set _symbol_ to "undef"; `-U symbol=` set empty
    value.

-O
:   let -D and -U override definitions from loaded configuration
    files; without -O, configuration files specified with
    -f will overwrite anything that was set using configure options.
    See Workflow below.

-A [a:]_symbol_=_value_
:   append _value_ to _symbol_; some other forms are
    supported for compatibility with Configure but their use is
    discouraged.

--set _symbol_=_value_
:   Set _symbol_ to _value_ (default "").

--enable-_something_
:   Same as `--set usesomething=define`

--has-_function_
:   Same as `--set d_function=define`

--define-_something_
:   Same as `--set something=define`

--include-_header_[=yes|no]
:   Set i_*header* to 'define' or 'undef';
    e.g. to disable `<sys/time.h>`
    use `--include-sys-time-h=no`.

When configuring for a cross-build, `-D/--set` and other
similar options affect target perl configuration (config.sh) only.
Use `--host-option[=value]` to pass
`--option[=value` over to miniperl configure.

Configure tries to build all modules it can find in the source tree.
Use the following options to alter modules list:

--static-mod=_mod1,mod2,..._
:   Build specified modules statically

--disable-mod=_mod1,mod2,..._
:   Do not build specified modules.

--only-mod=_mod1,mod2,..._
:   Build listed modules only

--all-static
:   Build all XS modules as static.
    Does _not_ imply `--no-dynaloader`.

--no-dynaloader
:   Do not build DynaLoader. Implies `--all-static`.
    Resulting perl won't be able to load any XS modules.
    Same as `-Uusedl`.

modX should be something like `cpan/Archive-Extract`;
static only applies to XS modules and will not affect non-XS modules.

## make targets

!!! warning "Warning"
    run "make crosspatch" **BEFORE** making other
    targets manually.

Default make target is building perl and all configured modules.
Other targets:

crosspatch
:   Apply all patches from cnf/diffs. Files are only patched
    once, cnf/diffs/path/file.applied locks are created to track
    that.

miniperl
:    Build miniperl only.

config.h
:    

xconfig.h
:    

Makefile.config
:   Re-build resp. files from [x]config.sh, may be needed after
    editing [x]config.sh manually. Note that make may try updating
    Makefile.config as a dependency for something else, but it
    won't re-read it immediately.

dynaloader
:   Build DynaLoader module. This is the first big target after
    miniperl, and the first that requires target compiler.
    If you can't get past dynaloder, something's really wrong.
    May be used to check target compiler viability.

perl
:   Build the main perl executable. Implies dynaloader and any
    static modules, but does not build dynamic or non-XS ones.

nonxs_ext
:    

dynamic_ext
:    

static_ext
:   Build all non-XS / dynamic XS / static XS modules listed
    in Makefile.config.
    Check [Modules](modules.md) page for details.

modules
:    

extensions
:   Build all modules at once.

cpan/_Some-Module_
:    

ext/_Some-Module_
:   Build _Some-Module_.
    Only works for modules listed
    in Makefile.config.

modules-reset
:   Remove all `pm_to_blib` locks.
    See [Modules](modules.md) page for
    more info.

modules-makefiles
:   Create/update Makefiles for all configured modules.

modules-clean
:   Run make clean for all modules.
    May cause unexpected side effects,
    see [Modules](modules.md) page.

utilites
:   Build everything in `utils/`.

install
:   Same as `make install.perl install.man`.

install.perl
:   Install perl and all the modules.

install.man
:   Install manual pages.

test
:   Run perl test suite from `t/`

testpack
:   Build testpack for on-target testing.
    See [Testing](testing.md) page.

clean
:   Try to clean up the source tree. Does not always work
    as expected.

For most generated files, make _file_ should be enough to rebuild _file_.
