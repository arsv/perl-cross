<? include "_head.php" ?>

<p>Hints are pre-defined values for config.sh variables, used when
testing for particular value is impossible or such test should be
avoided for whatever reasons.</p>

<p>Hints for perl-cross are stored under <tt>cnf/hints</tt>.
Unless told otherwise with <tt>--hints</tt>, configure will load
hints for <tt>$archname</tt> and <tt>$osname</tt>. A build that ends
up creating <tt>$prefix/lib/perl5/5.24.0/x86_64-linux</tt> likely
starts by loading <tt>cnf/hints/x86_64_linux</tt> and <tt>cnf/hints/linux</tt>.

<p>Hints in perl-cross are not just regular shell scripts.
They are filtered with <tt>sed</tt> and generally should not contain
anything but</p>
<pre>
	variable="properly quoted value"
</pre>
<p>lines, which are internally converted to</p>
<pre>
	hint variable "properly quoted value"
</pre>
<p>and then executed.</p>


<h2>Difference between mainline perl hints and perl-cross hints</h2>

<p>Hint files supplied with the mainline perl (hints/ in the source tree)
and not used by perl-cross configure. This is mainly because mainline perl
hint files are expected to take care of preset variables and command line
options by themselves, in style with the rest of Configure, while perl-cross
configure handles such things in a different manner.
These two systems do not mix very well.</p>

<p>Another reason is that mainline hints are allowed to run tests and look
around in the host system, which is a good way to get into troubles during
cross builds.</p>

<p>Mainline hints use <span>(os).sh</span> naming scheme and must determine
other aspects of target configuration internally using conditionals.
In contrast, perl-cross uses passive hint files with nothing but variable
assignments in them.</p>

<p>perl-cross does not support callbacks and per-file cflags from the mainline
hints. Callbacks are not really necessary in non-interactive mode because all
user-set values are known from the very start, and cctype hints partially
solve the problem of compiler related settings.</p>

<? include "_foot.php" ?>
