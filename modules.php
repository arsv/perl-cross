<? include "_head.php" ?>

<p>Build process for perl modules is unbelievably complex and awfully unsuited
for cross-compiling. Perl-cross takes some shortcuts to make it work, but it
has its limitations.</p>

<p>To add a module to your build, unpack it into cpan/ directory before running
configure. Check naming scheme there: a module called <tt>Some::Module</tt>
should be placed in cpan/Some-Module.</p>

<p>Native builds with cross-compiler perl are not supported.
With rare exceptions, it is not possible to build a module on the target
machine. Everything has to be cross-compiled.</p>


<h2>The problem with modules</h2>

<p>Building a perl module requires fully functional perl interpreter
and a bunch of rather complex modules available at build time.</p>

<p>That's a kind of chicken-and-egg problem, perl and modules
are needed to build perl and modules.</p>

<p>How the problem is resolved in perl-cross: miniperl is instructed
to use module sources directly for non-xs modules, without building
them, and xs modules are replaced with stubs from cnf/stub/ directory.
The entry point for the whole thing is miniperl_top. It runs miniperl
with a bunch of <tt>-I</tt> options to make it look like all the required
modules are available.</p>


<h2>Makefile rules for modules</h2>

<p>For various reasons, module-related make rules only apply to modules found
by configure. A module is always a directory located under cpan/ or ext/;
check cnf/configure_mods.sh on how exactly configure decides which directories
to use, and the type of module (XS/non-XS).

<p>The modules to be built are listed in <tt>$nonxs_ext</tt>,
<tt>$static_ext</tt>, <tt>$dynamic_ext</tt>; additionally,
<tt>$disabled_nonxs_ext</tt> and <tt>$disabled_dynamic_ext</tt> variables list
modules that were found but won't be built by "make modules" or "make all".</p>

<p>Consider a module located in cpan/Some-Module; its perl name is likely
Some::Module. Assuming it was correctly found by configure, the command to
make it is</p>
<pre>
	make cpan/Some-Module
</pre>
which will in turn call
<pre>
	make cpan/Some-Module/pm_to_blib
</pre>
<p><tt>pm_to_blib</tt>, is a real file and it's used as a flag for the
whole module, which allows to avoid costly recursive make runs.
As long as pm_to_blib is up-to-date, make won't attempt to rebuild the module.
This system is not very stable, and it is possible get unfinished build with
all pm_to_blibs in place; right now there's no good way to deal with it except
for removing pm_to_blib files manually and re-running make.</p>

<p>Here's what make does for a target like "cpan/Some-Module/pm_to_blib":</p>
<ul>
	<li>First, in case there is no cpan/Some-Module/Makefile.PL
	(happens for some modules), a script called make_ext_Makefile.pl
	is used to make a minimalistic Makefile.PL</li>
	<li>miniperl is used next to run Makefile.PL.
	Makefile.PL produces regular <tt>cpan/Some-Module/Makefile</tt>.</li>
	<li><tt>make -C cpan/Some-Module</tt> is spawned to build the module.
	Standard MakeMaker rules ensure that, among other things, pm_to_blib
	will be touch(1)ed at some point.</li>
</ul>
<p>Most of these operations require miniperl, so it will be built before
attempting to make any of the module targets.</p>


<a name="rebuilding"></a>
<h3>Re-building modules</h3>

<p>Sometimes <tt>pm_to_blib</tt> file gets touched before the module is built
completely. Typically this means there were built errors, but it can also
happen when MakeMaker decides to Makefile needs to be re-built.
As long as <tt>pm_to_blib</tt> is up-to-date, make won't be invoked
for this module and the build won't be finished.</p>

<p>There are two possible resolution. First, if the module name is known,
removing <tt>pm_to_blib</tt> manually will force rebuilt. Second,</p>
<pre>
	make modules-reset
</pre>
<p>will remove <tt>pm_to_blib</tt> from all non-disabled modules.
Even the latter is relatively cheap — it will not force a complete rebuild,
just "make -C cpan/Some-Module" invocations for all modules.</p>


<a name="cleaning"></a>
<h3>Cleaning up modules</h3>

<p><b>Running <tt>make clean</tt> on a module</b> requires an <b>up-to-date
<tt>Makefile</tt></b> for that module, which in turn <b>depends on usable
miniperl, MakeMaker and its subdependecies</b>. Running <tt>make clean</tt>
may prompt re-doing half the build. That's rather counter-intuitive,
but that's how MakeMaker works.</p>

<p>Top-level Makefile will only invoke "make clean" for modules that have
pre-built Makefile. The idea is that if there's no Makefile, the module has
never been built and doesn't require any cleaning.
It's not always true. To ensure all modules are really cleaned up,
<pre>
	make modules-makefiles modules-clean
</pre>
can be used. Note that it will try to build Makefiles for all (non-disabled)
modules, potentially running per-module configure and other nasty things.</p>


<h2>Module configuration</h2>

<p>Some modules have configure-like tests in their Makefile.PLs, which sometimes
can't handle cross-compilation very well. A notable case is Time::HiRes that
depends on <tt>d_nanosleep</tt> and <tt>d_clock_*</tt> from cnf/hints/linux.</p>

<p>Other modules from the perl distribution seem to avoid this, but third-party
modules may be a problem. There is no good solution here. Fixing Makefile.PL
and/or hinting the values may help in some cases.</p>

<p>Some modules analyze <tt>$^O</tt> value at build time, confusing host
and target platforms. At build time, <tt>$^O</tt> describes the host system,
and <tt>$Config{osname}</tt> should be used for the target.</p>


<? include "_foot.php" ?>
