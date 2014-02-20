**perl-cross** provides alternative configure script, top-level Makefile
as well as some auxiliary files for [perl](http://www.perl.org),
with the primary emphasis on cross-compiling the perl source.

perl-cross is not a part of perl distribution, it's a third-party tool in an eternal-alpha stage.  
***Use at your own risk!***  
If you can use Configure from the vanilla distribution, you probably **should** use Configure;  
perl-cross</b> is for the cases when Configure just can't make it.

The configure script from perl-cross is essentially a 100 kB long session
of severe [bash](http://www.gnu.org/software/bash/)(1) abuse.
Unlike the products of GNU autoconf, it sacrifices portability for readability;
it will likely only run on a relatively sane GNU system with GNU binutils.

Typical native build:
```
	./configure
	make
	make DESTDIR=... install
```

Typical cross-build for a uclibc system on a Geode board:
```
	./configure --target=i586-pc-linux-uclibc
	make
	make DESTDIR=... install
```

See [configure usage](http://arsv.github.io/perl-cross/usage.html) page
for a complete list of available configure options.

For documentation, check [project pages](http://arsv.github.io/perl-cross/).

For releases, check [releases branch](https://github.com/arsv/perl-cross/tree/releases).

perl-cross is a free software licensed under the same terms as the original perl source.
Check LICENSE, Copying and Artistic files.
