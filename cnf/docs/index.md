# Cross-compiling perl

---

**perl-cross** provides alternative `configure` script,
top-level Makefile as well as some auxilliary files for the standard
**perl** distribution intended to allow cross-compiling perl in
a relatively straighforward way.

!!! note " "
    perl-cross is not a part of perl distribution, it's a third-party tool in an eternal-alpha state.
    
    **Use at your own risk!**
    
    If you can use Configure from the vanilla distribution, you probably should use Configure;   
    **perl-cross** is for the cases when Configure just can't make it.

The configure script from perl-cross is essentially a 100 kB long session
of severe sh(1) abuse. Unlike the products of GNU autoconf, it sacrifices
portability for readability; it will likely only run on a relatively sane GNU
system with GNU binutils (which is kind of expected for a cross-build
but still feels like a limitation).

Typical native build:

```sh
./configure
make
make DESTDIR=... install
```

Typical cross-build for a uclibc system on a Geode board:

```sh
./configure --target=i586-pc-linux-uclibc
make
make DESTDIR=... install
```

See [configure usage](usage.md) page for a complete list
of available `configure` options.

## History

perl can't be cross-compiled "out of the box".
You can get an impression it isn't so when you read INSTALL file,
but once you start digging deeper (or just trying to do it),
you quickly find out that this cross-compilation

- requires SSH access to the target system
- and/or requires hand-crafted config.sh
- ...and still doesn't work
- when performed routinely, is performed in some non-standard way
  (by circumventing Configure and patching source tree)

Cross-compiling is rarely easy, but in case of perl this was not enough to explain why it is **so** hard.
After all, many autoconf'ed projects allow it much easier.
I had no intention to build native toolchain for my Alix project
(more for ideological reasons, not due to impossiblity, but that's another question).
A close look at config.sh made me sure I'm **not** going to hand-craft it.
CE and other ports were outright target-specific hacks, didn't work too and could not satisfy me anyway.
So I started hacking it on my own.

Currently the whole thing works well enough to suite my needs.
It's still of alpha quality though; use with caution,
and be ready to tweak it (I hope it's tweakable enough).

## Authors

Alex Suykov <alex.suykov@gmail.com>.   
Feel free to ask questions, most of the time I'll try to help.

Several other people contributed patches and suggestions.

If possible, please report successful builds and/or problems you encountered
while using perl-cross for your particular platform.
