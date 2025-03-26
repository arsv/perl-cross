# Testing perl

---

Perl ships with an extensive test suite, covering the interpreter itself
and most of the modules. To run a full test, use

```sh
(cd t && ./perl harness)
```

or just

```sh
make test
```

This works just as well with perl-cross &mdash; assuming you do it on the target
from within a full perl build tree. Depending on the target, the latter part
may not be practical, and actually makes little sense when you think of it.

perl-cross provides an alternative way for on-target testing: testpack,
tarball with the tests (and little else) that can be transferred to the
target. It's must smaller than the perl tree, ~23MB instead of 150+MB,
and unlike `make test` it's set up to test the perl that's already
installed in its proper location.

To make the pack, run

```sh
make testpack
```

then transfer TESTPACK.tar.gz to the target, unpack it there and do

```sh
(cd TESTPACK/t/ && ./perl harness)
```

Run

```sh
make clean-testpack
```

in the source tree to remove TESTPACK/ if necessary after TESTPACK.tar.gz has been built.

At this point testpack does not include all the tests that `make test` does.
So if you need to make absolutely sure the perl passes every test, do transfer the whole
build tree and run `make test` instead. However, testpack should be more than enough
to catch bad cross-compiling issues.

## Caveats

Just like the rest of the language, perl testsuite is one big hack with a lot of
counter-intuitive and counter-productive issues no-one bothers to fix. Following
the tradition, I merely document some of them here.

- Some of the tests scan perl source tree and/or check it against MANIFEST.
  If you did some equivalent of "make DESTDIR=\`pwd\`/out install" within the
  source tree, make sure to remove out/ before running tests.
- It may be tempting to run "perl harness" instead of
  "./perl harness". It will work, however the actual tests will still be run
  using ./perl, so if you do that make sure "perl" and "./perl" are the same.
- The tests (NOT the harness!) decide whether to run themselves by checking
  $Config{extensions}.
- Most tests do reset @INC and populate it with values like "../lib" etc.
  Testpack mitigates it somewhat, but it's still there.
- (harness only) $PERL5LIB value is ignored, however $PERL5LIB_TEST will be used.
  See t/TEST for reference.
- Test for some cpan/ modules do different things depending on $PERL_CORE value.
  Even in testpack, $PERL_CORE will be 1. Don't ask. Google for "dual-life perl module".
- To run a single test, use something like   
  `./perl harness ../cpan/Archive-Extract/t/01_Archive-Extract.t`   
  from the t/ directory. It is possible to run some of the tests without harness,
  but others will fail with bogus error messages.

## Tests excluded from testpack

Check TESTPACK.px, namely %exclude hash at the top.

Short summary: porting/, most of ExtUtils, CPAN meta-modules and some XS stuff is excluded,
the rest should work. Given the nature of the excluded tests, they will probably never work
well with cross-builds. Also, XS::APItest and anything that depends on it.
