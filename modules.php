<? include "_head.php" ?>

<p><b>perl</b> uses executable Makefiles written in perl itself for its modules.
This fact poses several problems during cross-build. To make things worse, those
Makefiles use ExtUtils::MakeMaker (a module) which in turn depends on several
more modules.</p>


<h2>Makefile rules for modules</h2>

<p>For various reasons, module-related make rules only apply to modules found
by configure. A module is always a directory located under cpan/ or ext/;
check cnf/configure_mods.sh on how exactly configure decides which directories
to use, and the type of module (XS/non-XS). The modules to be built are listed in
<tt>$nonxs_ext</tt>, <tt>$static_ext</tt>, <tt>$dynamic_ext</tt>; additionally,
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
<p>That file, <tt>pm_to_blib</tt>, is a real file and it's used as a flag for the
whole module, which allows to avoid costly recursive make runs. As long as pm_to_blib
is up-to-date, make won't attempt to rebuild the module. Note that this system
is not very stable, and it is possible get unfinished build with all pm_to_blibs in
place; right now there's no good way to deal with it except for removing pm_to_blib files
manually and re-running make.</p>

<p>Here's what make does for a target like "cpan/Some-Module/pm_to_blib":</p>
<ul>
	<li>First, in case there's no cpan/Some-Module/Makefile.PL
	(happens for some modules), a script called make_ext_Makefile.pl
	is used to make a minimalistic Makefile.PL</li>
	<li>miniperl is used next to run Makefile.PL. Because Makefile.PL
	uses ExtUtils::MakeMaker and MakeMaker itself depends on some of ExtUtils
	modules, a separate set of rules is used at this point to make sure
	all those modules are available. See <tt>$(EXTUTILS)</tt> in the top-level Makefile.
	Makefile.PL produces regular <tt>cpan/Some-Module/Makefile</tt>.</li>
	<li><tt>make -C cpan/Some-Module</tt> is spawned to build the module.
	Standard MakeMaker rules ensure that, among other things, pm_to_blib
	will be touch(1)ed somewhere in process.</li>
</ul>
<p>Most of these operations require miniperl, so it will be built before attempting
to build any of the module targets.</p>

<p>The modules listed in <tt>$(EXTUTILS)</tt>, while simple and non-XS,
do require running make, which gets the files copied to the right locations.</p>


<a name="rebuilding"></a>
<h3>Re-building modules</h3>

<p>Sometimes <tt>pm_to_blib</tt> file gets touched before the module is built
completely. Typically this means there were built errors, but it can also happen
when MakeMaker decides to Makefile needs to be re-built.
As long as <tt>pm_to_blib</tt> is up-to-date, make won't be invoked
for this module and the build won't be finished.</p>

<p>There are two possible resolution. First, if the module name is known,
removing <tt>pm_to_blib</tt> manually will force rebuilt. Second,</p>
<pre>
	make modules-reset
</pre>
<p>will remove <tt>pm_to_blib</tt> from all non-disabled modules. Note that even
the latter operation is relatively cheap — it won't force a complete rebuilding
of all modules, it will just force "make -C cpan/Some-Module" invocations.</p>


<a name="cleaning"></a>
<h3>Cleaning up modules</h3>

<p><b>Running <tt>make clean</tt> on a module</b> requires an <b>up-to-date <tt>Makefile</tt></b>
for that module, which in turn <b>depends on usable miniperl, MakeMaker and its subdependecies</b>.
In other words, <b>running <tt>make clean</tt> may start build process</b>. That's rather
counter-intuitive, but that's how MakeMaker works.</p>

<p>Top-level Makefile will only invoke "make clean" for modules that have pre-built Makefile.
The idea is that if there's no Makefile, the module was never built and doesn't require any
cleaning. It's not always true. To ensure all modules are really cleaned up,
<pre>
	make modules-makefiles modules-clean
</pre>
can be used. Note that it will try to build Makefiles for all (non-disabled) modules,
even those that were not built yet (potentially running per-module configure and other
nasty things).</p>

<p>Avoiding <tt>make clean</tt> on apparently non-built modules has also another benefit:
this way it's possible to run <tt>make clean</tt> after a failed <tt>miniperl</tt> build.</p>


<h2>Module configuration</h2>

<p>Some modules have configure-like tests in their Makefile.PLs, which sometimes
can't handle cross-compilation very well. A notable case is Time::HiRes, whose
Makefile.PL exits with non-zero status (and thus stops the whole process) because
it can't run compiled executables. Fortunately, its Makefile.PL allows overriding
those tests with non-standard keys from $Config (=config.sh); check cnf/hints/t/linux
for <tt>d_nanosleep</tt> and <tt>d_clock_*</tt>.</p>

<p>Other modules from the perl distribution seem to avoid this, but third-party
modules may be a problem. There's no good solution here. Chances are high you'll have
to tweak the module itself before trying to build it.</p>


<h2>Cross-compiling perl modules</h2>

<p><i>Note: this part is highly experimental and is not expected to work well.</i></p>

<p>perl uses executable Makefiles written in perl itself. Furthermore, those
Makefiles use info from config.sh, including compiler and directories. This
poses several problems, as during cross-build we have different
settings which require different configs:</p>
<ol>
	<li value="0">miniperl (build host)<ul>
		<li>perl: none yet</li>
		<li>libdir: none</li>
		<li>cc: build native cc</li>
		<li>destdir: $perl_src</li>
		<li>config: xconfig.sh</li>
	</ul></li>
	<li value="1">Perl source dir (build host)<ul>
		<li>perl: $perl_src/miniperl</li>
		<li>libdir: $perl_src/lib/perl (specified explicitly)</li>
		<li>cc: build-to-target cross-compiler</li>
		<li>destdir: $sysroot/$prefix</li>
		<li>config: config.sh</li>
	</ul></li>

	<li value="2">Standalone cross-build (build host)<ul>
		<li>perl: $target-miniperl</li>
		<li>libdir: $hostprefix/$target/perl/lib:$sysroot/$prefix/lib/perl</li>
		<li>cc: build-to-target cross-compiler</li>
		<li>destdir: $sysroot/$prefix</li>
		<li>config: config.sh</li>
	</ul></li>

	<li value="3">Native target build (target host)<ul>
		<li>perl: perl</li>
		<li>libdir: $prefix/lib/perl</li>
		<li>cc: target native cc</li>
		<li>destdir: $prefix</li>
		<li>config: tconfig.sh<br>
		(installed as config.sh in
			target:$prefix/lib/perl/Config_heavy.pl)</li>
	</ul></li>
</ol>

<p>There's no way configure can guess target native cc; user should specify it explicitly,
or some default value should be used ("cc", probably). Also, we have to assume that it
works with the same libc (and other libraries) as build-to-target cross-cc — i.e. that one
can use all i_* and d_* obtained for setting 1 in setting 3.</p>

<p>Setting 3 is probably the less reliable, <b>and</b> it probably won't be used anyway
(at least for a typical "embedded" scenario, where everything is cross-compiled from
the build host and the target tend to lack cc at all). Anyway, for the sake of completeness,
and for non-embedded uses, we should try to set a usable perl installation there,
which implies possibility of native module building.</p>

<p>I left config.sh for settings 1 and 2, mostly because all (rather complicated) build
scripts default to config.sh and I don't want to modify them now. The second one, xconfig.sh,
is bound to miniperl, roughly for the same reason. This means that another config file,
tconfig.sh, should be introduced for native target builds.</p>

<p>Here arises another problem. config.sh is not always used directly; for many
things <i>including</i> MakeMaker activity, Config.pm (and thus
Config_heavy.pl) is used instead.  Which means different Config_heavy.pl should
generated and installed also.</p>

<p>The best way to do this would be to modify installperl script,
but once again I want to do as little modifications as possibly, so I
just overwrite Config_heavy.pl installed by installperl with
one generated from tconfig.sh after installperl finishes.</p>

<p>Original Config_heavy.pl (the one built from config.sh) is
still needed for setting 2. I put it to
built:$hostprefix/$target/lib/perl and make that dir standard lib
directory for $target-miniperl, with
$sysroot/$prefix/lib/perl listed as otherlibsdir, so that
$target-miniperl will be using cross-compiling
Config_heavy.pl together with any module from the target installation.
It's ok to alter default lib search path for miniperl, every time it's used for
primary perl build it's supplied with -I option.</p>


<h3>Auxilliary scripts</h3>

<p>perl comes with several module-related scripts (cpan etc.).
Ideally, these should be installed twice: unprefixed under
$sysroot/$prefix for setting 3 and $target-prefixed under
$hostprefix/bin (or $hostprefix/$target/bin) for setting 2.
Unfortunately, CPAN.pm is quite heavy and can't be used with miniperl due to
unavailablity of dynaloaded modules (including IO, POSIX and probably
network-related modules).</p>

<p>There can be two ways to solve this:</p>
<ol>
	<li value="1">Use pre-installed host perl, possibly of different
	   version, supplied with $hostprefix/$target/lib/perl as
	   libdir to make it pick up our Config_heavy.pl instead
	   of its own.
	<li value="2">Build full-fledged hostperl in addition to miniperl,
	   solely for the setting 2, installing it as
	   build:$hostprefix/bin/$target-hostperl, or
	   build:$hostprefix/$target/bin/hostperl, or something like that, with
	   modules in build:$hostprefix/$target/lib/perl.
</ol>

<p>Probably it would be better to check for the host perl first, see if it's good enough,
and fall back to hostperl if something is wrong with it.</p>

<p>The Second solution is the most reliable, but is difficult to implement.
Among other things, it would require rewriting module building scripts.</p>

<p>And thinking of possible need to install additional modules for hostperl makes my head spin.</p>

<p>All these things are not implemented yet.</p>

<? include "_foot.php" ?>
