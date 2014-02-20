<? include "_head.php" ?>

<p>Hints are pre-defined values for config.sh variables, used when
testing for particular value is impossible or such test should be
avoided for whatever reasons.</p>

<p>Hints for perl-cross are stored under <tt>cnf/hints</tt>. They are
loaded automatically, depending on host, target and compiler settings,
in the following order:</p>
<div>
	[mode-]arch-machine-os-type<br>
	[mode-]arch-machine<br>
	[mode-]arch<br>
	[mode-]os-type<br>
	[mode-]os<br>
	default
</div>
<p>with <span>arch-machine-os-type</span> being standard target description
triplet (or quadruplet) like <tt>i686-pc-linux-gnu</tt>. <span>mode</span> can
be either <tt>host</tt> or <tt>target</tt>. All matching files are loaded,
and the most specific value is used.</p>

<p>Despite their looks, hints are not just regular shell scripts. They are filtered
with <tt>sed</tt> and generally should not contain anything but</p>
<pre>
	variable="properly quoted value"
</pre>
<p>lines, which are internally converted to</p>
<pre>
	hint variable "properly quoted value"
</pre>
<p>and then executed.</p>


<h2>Difference between mainline perl hints and perl-cross hints</h2>

<p>Hint files supplied with the mainline perl (found under hints/ in the source tree)
and not used by perl-cross configure. This is mainly because mainline perl hint
files are expected to take care of preset variables, command line options etc. by
themselves (in style with the rest of Configure) while configure handles such things
in a different manner, and these two systems do not mix very well.</p>

<p>Another reason is that mainline hints are allowed to run tests and look around
in the (host) system, which is a good way to get into troubles during cross builds.</p>

<p>Mainline hints use <span>(os).sh</span> naming scheme and must determine other
aspects of target configuration internally using conditionals. In contrast, perl-cross
uses much more elaborate (and less portable) naming scheme with mostly external
(by configure) hint selection.</p>

<p>perl-cross doesn't support callbacks and per-file cflags from the mainline hints.
Callbacks aren't really necessary in non-interactive mode because all user-set
values are known from the very start, and cctype hints partially solve the problem
of compiler related settings. Per-file cflags are not implemented yet.</p>


<h2>Per-compiler hints</h2>

<p>Along with each <span>arch-machine-os-type</span> hint, configure will also
try to load <span>arch-machine-os-type-cctype</span>, with cctype being "compiler
type". Compiler type is usually the basename of the compiler, like "gcc" or "icc".
Hints of these type are expected to set compiler flags. Note that for now this
feature is mostly useless since you're not expected to finish a build with anything
other than gcc.</p>

<p>Because of the way cctype hints are handled, there's one rather counter-intuitive side
effect: using <tt>-A</tt> on <tt>cctype</tt> is useless. Ok, <tt>-A cctype</tt> doesn't
make sense in the first place, but still. On the other hand, <tt>-Dcctype=</tt> is
ok.</p>

<? include "_foot.php" ?>
