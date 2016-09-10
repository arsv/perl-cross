<? include "_head.php" ?>

<p>Unpack perl-X.Y.Z-cross-W.Q.tar.gz over perl-X.Y.Z distribution.<br>
Perl-cross package should overwrite top-level Makefile and some other files
in the perl source tree.</p>

<p>The build process is similar to that of most autoconf-based packages.
For a native build, use something like</p>
<pre>
	./configure --prefix=/usr
	make
	make DESTDIR=/some/tmp/dir install
</pre>
<p>For a cross-build, specify your target:</p>
<pre>
	./configure --prefix=/usr --target=i586-pc-linux-uclibc
	make
	make DESTDIR=/some/tmp/dir install
</pre>

<p>Check below for <a href="#targets">other possible make targets</a>.</p>

<h2>Target-specific notes</h2>

<p><b>Android</b>, assuming NDK is installed in <tt>/opt/android-ndk</tt>:</p>
<pre>
	ANDROID=/opt/android-ndk
	TOOLCHAIN=arm-linux-androideabi-4.9/prebuilt/linux-x86_64
	PLATFORM=$ANDROID/platforms/android-16/arch-arm
	export PATH=$PATH:$ANDROID/toolchains/$TOOLCHAIN/bin
	./configure --target=arm-linux-androideabi --sysroot=$PLATFORM
</pre>
<p>Adjust platform and compiler version to match your particular NDK.</p>

<p><b>arm-linux-uclibc</b>: successful build is highly likely.<br>
Check target tools prefix, it may be useful here, especially
if <tt>--sysroot</tt> is used.</p>
<pre>
	./configure --target=arm-linux-uclibc --target-tools-prefix=arm-linux-
</pre>

<p><b>ix86-* with Intel cc</b>, native build: use <tt>-Dcc=icc</tt>.
Configure will not supply any optimization options to the compiler,
consider <tt>-Doptimize</tt> if necessary.</p>

<p><b>MinGW32</b>: cannot be built yet. Configure will produce config.sh,
but current perl-cross Makefiles can't handle win32 build.</p>
<pre>
	./configure --target=i486-mingw32 --no-dynaloader
</pre>

<h2>Complete configure options list</h2>

<p>Overall call order:</p>
<pre>
	configure [options]
</pre>

<p>Perl-cross configure adheres to common GNU autoconf style, but also accepts
most of the original Configure options. Both short and long options
are supported (<tt>-D</tt>, <tt>--define</tt>).</p>

<p>Valid ways to supply arguments for the options:</p>
<ul>
	<li><tt>-f config.sh</tt></li>
	<li><tt>-fconfig.sh</tt></li>
	<li><tt>-D key=val</tt></li>
	<li><tt>-Dkey=val</tt></li>
	<li><tt>--set-key=val</tt></li>
	<li><tt>--set key=val</tt></li>
</ul>
<p>Whenever necessary, dashes in "key" are converted to underscores; use
<tt>--set-d-<i>something</i></tt> instead of <tt>--set-d_<i>something</i></tt>.
</p>

<p>The only essential thing configure does is writing <tt>config.sh</tt>
(and possibly <tt>xconfig.sh</tt>). Most options are meant to alter the values
written there. Refer to Porting/Glossary for description of variables found in
<tt>config.sh</tt>. This page only decribes <i>how</i> to modify them,
not <i>which values</i> to use.</p>

<p>General configure control options:</p>
<dl>
	<dt>--help</dt>	
		<dd>dump a short help message on stdout and exit</dd>
	<dt>--mode=(native|cross|target|buildmini)</dt>
		<dd>set configure mode; used internally</dd>
	<dt>--keeplog</dt>
		<dd>Append to config.log instead of truncating it;
		used internally.</dd>
	<dt>--regenerate</dt>
		<dd>Re-generates config.h, xconfig.h and Makefile.config
		from config.sh and xconfig.sh.
		Does not change config.sh or xconfig.sh.</dd>
</dl>

<p>General installation setup:</p>
<dl>
	<dt>--prefix=<i>/usr</i></dt>
		<dd>Installation prefix (on the target).</dd>
	<dt>--html{1,3}dir=<i>dir</i></dt>
		<dd>Installation prefix for HTML documentation (not used)</dd>
	<dt>--man{1,3}dir=<i>dir</i></dt>
		<dd>Installation prefix for manual pages</dd>
	<dt>--target=<i>machine</i></dt>
		<dd>Target description (e.g. i586-pc-linux-uclibc);
		<i>machine</i>-gcc, <i>machine</i>-ld, <i>machine</i>-ar will be
		used for target build unless explicitly overriden, and perl
		<tt>archname</tt> will be set to <i>machine</i>. Hints will be
		choosen based on this value.</dd>
	<dt>--target-tools-prefix=<i>prefix</i></dt>
		<dd>Use <i>prefix-</i>gcc, <i>prefix-</i>ld without overriding
		<tt>archname</tt>.</dd>
	<dt>--build=<i>machine</i></dt>
		<dd>Same as --target but for host executables (miniperl)</dd>
	<dt>--hints=<i>h1,h2,...</i></dt>
		<dd>Suggest specified hint files (cnf/hints/h1 and so on).
		The hints are processed after other options,
		see <a href="#workflow">Workflow</a> below.</dd>

	<dt>--with-libs=<i>lib1,lib2,...</i></dt>
		<dd>Comma-separated list of libraries to check<br>
		(basenames only, use "dl" to have -ldl passed to the linker).</dd>

	<dt>--with-cc=<i>cmd</i></dt>
		<dd>(target) C compiler.</dd>
	<dt>--with-cpp=<i>cmd</i></dt>
		<dd>(target) C preprocessor.</dd>
	<dt>--with-ranlib=<i>cmd</i></dt>
		<dd>(target) ranlib; set to 'true' or 'echo' to disable.</dd>
	<dt>--with-objdump=<i>cmd</i></dt>
		<dd>(target) objdump; not used during the build,
		but crucial for some configure test.</dd>

	<dt>--host-cc=<i>cmd</i></dt>		
	<dt>--host-cpp=<i>cmd</i></dt>		
	<dt>--host-ranlib=<i>cmd</i></dt>
	<dt>--host-objdump=<i>cmd</i></dt>
	<dt>--host-libs=<i>cmd</i></dt>
		<dd>Same, for host executables.
		Only useful when cross-compiling.</dd>

	<dt>--sysroot=<i>/path</i></dt>
		<dd>Passed directly to target compiler, linker and preprocessor.
		See gcc(1) on how to use this option.</dd>
</dl>

<p>Options from the original Configure which are not supported or make
no sense for this version of configure:</p>
<dl>
	<dt>-e</dt>
		<dd>go on without questioning past the production of config.sh<br>
		(ignored, you'll have to run make manually)</dd>
	<dt>-E</dt>	
		<dd>stop at the end of questions, after having produced
		Jconfig.sh (ignored, that's the only way perl-cross works)</dd>
	<dt>-r</dt>
		<dd>reuse C symbols value if possible, skips costly nm
		extraction (ignored, configure uses completely different method
		of checking function availability)</dd>
	<dt>-s</dt>
		<dd>silent mode (ignored, perl-cross has no other modes)</dd>
	<dt>-K</dt>
		<dd>(not supported)</dd>
	<dt>-S</dt>
		<dd>perform variable substitutions on all .SH files
		(ignored, configure can't do that)</dd>
	<dt>-V</dt>
		<dd>show version number (not supported)</dd>
	<dt>-d</dt>
		<dd>use defaults for all answers (ignored, default mode)</dd>
	<dt>-h</dt>
		<dd>show help (ignored, use --help instead)</dd>
</dl>

<p>The following options are used to manipulate the values configure will
write to config.sh. Check Porting/Glossary for the list of possible
symbols.</p>
<dl>
	<dt>-f <i>file.sh</i></dt>
		<dd>load configuration from a file.<br>
		See <a href="#workflow">Workflow</a> below.</dd>
	<dt>-D <i>symbol[=value]</i></dt>
		<dd>set value for symbol; default <i>value</i> is "define".<br>
	    	Common examples (see INSTALL for more info):
		<ul class="fixtab">
			<li><tt>-Duse64bitint</tt>
				use 64bit integers</li>
			<li><tt>-Duse64bitall</tt>
				use 64bit integers and pointers</li>
			<li><tt>-Dusethreads</tt>
				use thread support (also <tt>--enable-threads</tt>)</li>
			<li><tt>-Dinc_version_list=none</tt>
				do not include older perl trees in @INC</li>
			<li><tt>-DEBUGGING=none</tt>
				DEBUGGING options</li>
			<li><tt>-Dcc=gcc</tt>
				same as <tt>--with-cc=gcc</tt></li>
			<li><tt>-Dprefix=/opt/perl5</tt>
				same as <tt>--prefix=/opt/perl5</tt></li>
		</ul></dd>
	<dt>-U symbol</dt>
		<dd>set <i>symbol</i> to "undef"; <tt>-U symbol=</tt> set empty
		value.</dd>
	<dt>-O</dt>	
		<dd>let -D and -U override definitions from loaded configuration
		files; without -O, configuration files specified with -f will
		overwrite anything that was set using configure options.
		See <a href="#workflow">Workflow</a> below.</dd>

	<dt>-A [a:]symbol=value</dt>
		<dd>append <i>value</i> to <i>symbol</i>; some other forms are
		supported for compatibility with Configure but their use is
		discouraged.</dd>

	<dt>--set <i>symbol=value</i></dt>
		<dd>Set <i>symbol</i> to <i>value</i> (default "").</dd>
	<dt>--enable-<i>something</i></dt>
		<dd>Same as <tt>--set use<i>something</i>=define</tt></dd>
	<dt>--has-<i>function</i></dt>
		<dd>Same as <tt>--set d_<i>function</i>=define</tt></dd>
	<dt>--define-<i>something</i></dt>
		<dd>Same as <tt>--set <i>something</i>=define</tt></dd>
	<dt>--include-<i>header</i>[=yes|no]</dt>
		<dd>Set <tt>i_<i>header</i></tt> to 'define' or 'undef';
		e.g. to disable <tt>&lt;sys/time.h&gt;</tt>
		use <tt>--include-sys-time-h=no</tt>.</dd>
</dl>

<p>When configuring for a cross-build, <tt>-D</tt>/<tt>--set</tt> and other
similar options affect target perl configuration (config.sh) only.
Use <tt>--host-option</tt>[=<i>value</i>] to pass
<tt>--option</tt>[=<i>value</i> over to miniperl configure.</p>

<p>Configure tries to build all modules it can find in the source tree.
Use the following options to alter modules list:</p>
<dl>
	<dt>--static-mod=<i>mod1,mod2,...</i></dt>
		<dd>Build specified modules statically</dd>
	<dt>--disable-mod=<i>mod1,mod2,...</i></dt>
		<dd>Do not build specified modules.</dd>
	<dt>--only-mod=<i>mod1,mod2,...</i></dt>
		<dd>Build listed modules only</dd>
	<dt>--all-static</dt>
		<dd>Build all XS modules as static.
		Does <i>not</i> imply <tt>--no-dynaloader</tt>.</dd>
	<dt>--no-dynaloader</dt>
		<dd>Do not build DynaLoader. Implies <tt>--all-static</tt>.
		Resulting perl won't be able to load <i>any</i> XS modules.
		Same as <tt>-Uusedl</tt>.
</dl>
<p><tt><i>modX</i></tt> should be something like <tt>cpan/Archive-Extract</tt>;
static only applies to XS modules and will not affect non-XS modules.</p>


<a name="targets"></a>
<h2>make targets</h2>

<div class="warn">Warning: run "make crosspatch" <b>BEFORE</b> making other
targets manually.</div>

<p>Default make target is building perl and all configured modules.
Other targets:</p>
<dl>
	<dt>crosspatch</dt>
		<dd>Apply all patches from cnf/diffs. Files are only patched
		once, cnf/diffs/path/file.applied locks are created to track
		that.</dd>
	<dt>miniperl</dt>
		<dd>Build miniperl only.</dd>
	<dt>config.h</dt>
	<dt>xconfig.h</dt>
	<dt>Makefile.config</dt>
		<dd>Re-build resp. files from [x]config.sh, may be needed after
		editing [x]config.sh manually. Note that make may try updating
		Makefile.config as a dependency for something else, but it
		won't re-read it immediately.</dd>
	<dt>dynaloader</dt>
		<dd>Build DynaLoader module. This is the first big target after
		miniperl, and the first that requires target compiler.
		If you can't get past dynaloder, something's really wrong.
		May be used to check target compiler viability.</dd>
	<dt>perl</dt>
		<dd>Build the main perl executable. Implies dynaloader and any
		static modules, but does not build dynamic or non-XS ones.</dd>
	<dt>nonxs_ext</dt>
	<dt>dynamic_ext</dt>
	<dt>static_ext</dt>
		<dd>Build all non-XS / dynamic XS / static XS modules listed
		in Makefile.config.
		Check <a href="modules.html">Modules page</a> for details.</dd>
	<dt>modules</dt>
	<dt>extensions</dt>
		<dd>Build all modules at once.</dd>
	<dt>cpan/<i>Some-Module</i></dt>
	<dt>ext/<i>Some-Module</i></dt>
		<dd>Build <i>Some-Module</i>.
		Only works for modules listed in Makefile.config.</dd>
	<dt>modules-reset</dt>
		<dd>Remove all <tt>pm_to_blib</tt> locks.
		See <a href="modules.html#rebuilding">Modules</a> page for
		more info.</dd>
	<dt>modules-makefiles</dt>
		<dd>Create/update Makefiles for all configured modules.</dd>
	<dt>modules-clean</dt>
		<dd>Run <tt>make clean</tt> for all modules.
		May cause unexpected side effects,
		see <a href="modules.html#cleaning">Modules</a> page.</dd>
	<dt>utilites</dt>
		<dd>Build everything in <tt>utils/</tt>.</dd>
	<dt>install</dt>
		<dd>Same as <tt>make install.perl install.man</tt>.</dd>
	<dt>install.perl</dt>	
		<dd>Install perl and all the modules.</dd>
	<dt>install.man</dt>
		<dd>Install manual pages.</dd>
	<dt>test</dt>
		<dd>Run perl test suite from t/</dd>
	<dt>testpack</dt>
		<dd>Build testpack for on-target testing.
		See <a href="testing.html">Testing</a> page.</dd>
	<dt>clean</dt>
		<dd>Try to clean up the source tree. Does not always work
		as expected.</dd>
</dl>

<p>For most generated files, <tt>make <i>file</i></tt> should be enough
to rebuild <tt><i>file</i></tt>.</p>

<? include "_foot.php" ?>
