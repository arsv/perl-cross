# Cross-compiling perl

---

Build process for perl modules is unbelievably complex and awfully unsuited
for cross-compiling. Perl-cross takes some shortcuts to make it work, but it
has its limitations.

To add a module to your build, unpack it into cpan/ directory before running
configure. Check naming scheme there: a module called `Some::Module`
should be placed in cpan/Some-Module.

Native builds with cross-compiler perl are not supported.
With rare exceptions, it is not possible to build a module on the target
machine. Everything has to be cross-compiled.

## The problem with modules

Building a perl module requires fully functional perl interpreter
and a bunch of rather complex modules available at build time.

That's a kind of chicken-and-egg problem, perl and modules
are needed to build perl and modules.

How the problem is resolved in perl-cross: miniperl is instructed
to use module sources directly for non-xs modules, without building
them, and xs modules are replaced with stubs from cnf/stub/ directory.
The entry point for the whole thing is miniperl_top. It runs miniperl
with a bunch of `-I` options to make it look like all the required
modules are available.

## Makefile rules for modules

For various reasons, module-related make rules only apply to modules found
by configure. A module is always a directory located under cpan/ or ext/;
check cnf/configure_mods.sh on how exactly configure decides which directories
to use, and the type of module (XS/non-XS).

The modules to be built are listed in `$nonxs_ext`,
`$static_ext`, `$dynamic_ext`; additionally,
`$disabled_nonxs_ext` and `$disabled_dynamic_ext` variables list
modules that were found but won't be built by "make modules" or "make all".

Consider a module located in cpan/Some-Module; its perl name is likely
Some::Module. Assuming it was correctly found by configure, the command to
make it is

```sh
make cpan/Some-Module
```

which will in turn call

```sh
make cpan/Some-Module/pm_to_blib
```

`pm_to_blib`, is a real file and it's used as a flag for the
whole module, which allows to avoid costly recursive make runs.
As long as pm_to_blib is up-to-date, make won't attempt to rebuild the module.
This system is not very stable, and it is possible get unfinished build with
all pm_to_blibs in place; right now there's no good way to deal with it except
for removing pm_to_blib files manually and re-running make.

Here's what make does for a target like "cpan/Some-Module/pm_to_blib":

- First, in case there is no cpan/Some-Module/Makefile.PL
  (happens for some modules), a script called make_ext_Makefile.pl
  is used to make a minimalistic Makefile.PL
- miniperl is used next to run Makefile.PL.
  Makefile.PL produces regular `cpan/Some-Module/Makefile`.
- `make -C cpan/Some-Module` is spawned to build the module.
  Standard MakeMaker rules ensure that, among other things, pm_to_blib
  will be touch(1)ed at some point.

Most of these operations require miniperl, so it will be built before
attempting to make any of the module targets.

### Re-building modules

Sometimes `pm_to_blib` file gets touched before the module is built
completely. Typically this means there were built errors, but it can also
happen when MakeMaker decides to Makefile needs to be re-built.
As long as `pm_to_blib` is up-to-date, make won't be invoked
for this module and the build won't be finished.

There are two possible resolution. First, if the module name is known,
removing `pm_to_blib` manually will force rebuilt. Second,

```sh
make modules-reset
```

will remove `pm_to_blib` from all non-disabled modules.
Even the latter is relatively cheap &mdash; it will not force a complete rebuild,
just "make -C cpan/Some-Module" invocations for all modules.

### Cleaning up modules

**Running `make clean` on a module** requires an **up-to-date
`Makefile`** for that module, which in turn **depends on usable
miniperl, MakeMaker and its subdependecies**. Running `make clean`
may prompt re-doing half the build. That's rather counter-intuitive,
but that's how MakeMaker works.

Top-level Makefile will only invoke "make clean" for modules that have
pre-built Makefile. The idea is that if there's no Makefile, the module has
never been built and doesn't require any cleaning.
It's not always true. To ensure all modules are really cleaned up,

```sh
make modules-makefiles modules-clean
```

can be used. Note that it will try to build Makefiles for all (non-disabled)
modules, potentially running per-module configure and other nasty things.

## Module configuration

Some modules have configure-like tests in their Makefile.PLs, which sometimes
can't handle cross-compilation very well. A notable case is Time::HiRes that
depends on `d_nanosleep` and `d_clock_*` from cnf/hints/linux.

Other modules from the perl distribution seem to avoid this, but third-party
modules may be a problem. There is no good solution here. Fixing Makefile.PL
and/or hinting the values may help in some cases.

Some modules analyze `$^O` value at build time, confusing host
and target platforms. At build time, `$^O` describes the host system,
and `$Config{osname}` should be used for the target.
