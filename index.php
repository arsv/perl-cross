<? include "_head.php" ?>

<p><b>perl-cross</b> provides alternative <tt>configure</tt> script, top-level Makefile
as well as some auxilliary files for the standard <b>perl</b> distribution intended to
allow cross-compiling perl in a relatively straighforward way.</p>

<div class="warn">perl-cross is not a part of perl distribution,
it's a third-party tool in an eternal-alpha state.
<div>Use at your own risk!</div>
If you can use Configure from the vanilla distribution, you probably <i>should</i> use Configure;
<b>perl-cross</b> is for the cases when Configure just can't make it.</div>

<p>The configure script from perl-cross is essentially a 100 kB long session
of severe bash(1) abuse. Unlike the products of GNU autoconf, it sacrifices portability
for readability; it will likely only run on a relatively sane GNU system with GNU binutils
(which is kind of expected if you're doing a <i>cross-build</i>, but still is a limitation).
</p>

<p>Typical native build:</p>
<pre>
	./configure
	make
	make DESTDIR=... install
</pre>
<p>Typical cross-build for a uclibc system on a Geode board:</p>
<pre>
	./configure --target=i586-pc-linux-uclibc
	make
	make DESTDIR=... install
</pre>
<p>See <a href="usage.html">configure usage</a> page for a complete list of available
<tt>configure</tt> options.</p>


<h2>History</h2>

<p>perl can't be cross-compiled "out of the box". You can get an impression
it isn't so when you read INSTALL file, but once you start digging deeper
(or just trying to do it), you quickly find out that this cross-compilation</p>
<ul>
	<li>requires SSH access to the target system</li>
	<li>and/or requires hand-crafted config.sh</li>
	<li>...and still doesn't work</li>
	<li>when performed routinely, is performed in some non-standard way<br>
	(by circumventing Configure and patching source tree)</li>
</ul>

<p>Cross-compiling is rarely easy, but in case of perl this was not enough to
explain why it is <b>so</b> hard. After all, many autoconf'ed projects allow it
much easier. I had no intention to build native toolchain for my Alix project
(more for ideological reasons, not due to impossiblity, but that's another
question). A close look at config.sh made me sure I'm <b>not</b> going
to hand-craft it. CE and other ports were outright target-specific hacks,
didn't work too and could not satisfy me anyway. So I started hacking it on my
own.</p>

<p>Currently the whole thing works well enough to suite my needs.
It's still of alpha quality though; use with caution, and be ready
to tweak it (I hope it's tweakable enough).</p>

<h2>Authors</h2>

<p>Alex Suykov <tt>&lt;alex.suykov@gmail.com&gt;</tt>.<br>
Feel free to ask questions, most of the time I'll try to help.</p>

<p>Several other people contributed patches and suggestions.</p>

<p>If possible, please report successful builds and/or
problems you encountered while using perl-cross for your particular platform.</p>

<? include "_foot.php" ?>
