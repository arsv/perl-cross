# Cross-compiling perl

---

All configure-related files (except for ./configure which is just
a wrapper script) are stored in cnf/ directory.
For the sake of clarity/readability, sh functions are used extensively.

Each config.sh variable is only set once, and immediately written
to config.sh. Attempts to re-set it later are ignored. This scheme is used
to implement hints and handle command-line overrides: both force the value
to be written early, prevent normal configure code from setting it.
Check configure__f.sh for the code that does it.

Values that cannot be tested on the build host are supposed to be set
by target-specific hint files. See [hints page](hints.md) on this.

## configure files

cnf/configure is the entry point, and the only file that calls other
configure_* files. Test-specific functions are defined in their respective
test files. The tests are mostly independent, but do rely on values from
preceeding tests, and most rely on target toolchain being set up.

## configure variables

Most variables from config.sh are described in Porting/Glossary in the
perl source. Make sure to check that file.

To see where a particular variable gets defined, grep its name in cnf/*.sh.
Beware there's one exception: d_(func)_r and (func)_r_proto are not greppable.
Those symbols are set in configure_thrd.sh.

## Patching perl files

There are some minor changes perl-cross needs in the original perl files.
Relevant patches for each supported upstream version are supplied in
`cnf/diffs/`.

The patches are applied by `crosspatch` make target, which is
the first one in `make all` sequence.

For each successfully applied `cnf/diffs/file.patch` a lock file
`cnf/diffs/file.applied` is created, so the patches are not applied
twice.

## Building miniperl

miniperl should work on the build, not target, platform. It is compiled
using native compiler, unlike primary perl executable which is built later
using build-to-target cross-compiler. Because of this, during cross-build
configure is run twice, first to set up miniperl and then to set up
the main perl config.

Native and target build differ in file extensions: the latter uses usual .o
(default) but the former has .host.o instead. All object files are kept in
the same (root) directory.

Different configs are used for different platforms:
config.{h,sh} for the target build and xconfig.{h,sh} for build-time miniperl.
**Beware**: this is exactly opposite of what the original Configure does,
The relation was inversed because most tools use config.sh by default, and cross-build
is viewed as primary. Among other things, building extensions with config.sh
is simpler, and extensions are not built for miniperl.

See also [Cross-compiling modules](modules.md) on some issues
with config files.

## Build-time scripts

Most of the time perl-cross tries to use scripts like configpm,
utils/ext/* etc. unchanged.
.

Some of the code used during build stage tries to load XS modules.
Most of the time, for mundane tasks like can_run() or tempfile() or strftime().
This is not acceptable for perl-cross, which uses miniperl to run those
(unlike the native makefiles which can and do rely on newly-built perl).

Current solution is either to patch the offending scripts, or to provide
minimalistic pure-perl stubs for the required XS modules.   
Patches are kept in `cnf/diffs`, and stubs are in `cnf/stub`.   
In one particular case, Digest::MD5, a dynaloaded module was replaced with
non-XS equivalent Digest::MD5::Perl from CPAN.

The way configpm used to choose which files to update made no sense with
the new configure, so it was changed: --config-sh, --config-pm and --config-pod
were added, with default values set to config.sh, lib/Config.pm
and lib/Config.pod.
