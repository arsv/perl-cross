# Cross-compiling perl

---

Hints are pre-defined values for config.sh variables, used when
testing for particular value is impossible or such test should be
avoided for whatever reasons.

Hints for perl-cross are stored under `cnf/hints`.
Unless told otherwise with `--hints`, configure will load
hints for `$archname` and `$osname`. A build that ends
up creating `$prefix/lib/perl5/5.24.0/x86_64-linux` likely
starts by loading `cnf/hints/x86_64_linux` and `cnf/hints/linux`.

Hints in perl-cross are not just regular shell scripts.
They are filtered with `sed` and generally should not contain
anything but

```text
variable="properly quoted value"
```

lines, which are internally converted to

```text
hint variable "properly quoted value"
```

and then executed.

### Difference between mainline perl hints and perl-cross hints

Hint files supplied with the mainline perl (hints/ in the source tree)
and not used by perl-cross configure. This is mainly because mainline perl
hint files are expected to take care of preset variables and command line
options by themselves, in style with the rest of Configure, while perl-cross
configure handles such things in a different manner.
These two systems do not mix very well.

Another reason is that mainline hints are allowed to run tests and look
around in the host system, which is a good way to get into troubles during
cross builds.

Mainline hints use (os).sh naming scheme and must determine
other aspects of target configuration internally using conditionals.
In contrast, perl-cross uses passive hint files with nothing but variable
assignments in them.

perl-cross does not support callbacks and per-file cflags from the mainline
hints. Callbacks are not really necessary in non-interactive mode because all
user-set values are known from the very start, and cctype hints partially
solve the problem of compiler related settings.
