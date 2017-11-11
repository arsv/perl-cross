# Hints loading. This gets called after setting up the toolchains
# but before everything else, and the goal of the hints is
# to provide non-testable values and possibly suppress undesirable tests.

# We want to see
#	var=value
# in hint files, but this would break things (overwrite argv variables
# for instance). So we use sed to turn those lines into
#	hint "var" "value"
# Unlike pretty much any other place in cnf/, the last assignment
# is effective here, not the first.

tryhints() {
	# win32 hints are mixed-case
	_hint=`echo "$1" | tr A-Z a-z`
	hintfile="$base/hints/$_hint"

	if [ -f "$hintfile" ]; then
		msg "	using $hintfile"
		sed -r -e "/^([A-Za-z0-9_]+)=/s//hint \1 /"\
			"$hintfile" > config.hint.tmp
		. ./config.hint.tmp
		rm -f config.hint.tmp
	else
		log "	no hints for $_hint"
	fi
}

hint() {
	define "$1" "$2" 'hinted'
}

set_win32_archname() {
	if [ "$arch" = 'x86_64' ]; then
		architecture='x64'
	else
		architecture="$arch"
	fi

	if [ "$usemulti" = 'define' ]; then
		archname="MSWin32-$architecture-multi"
	elif [ "$useperlio" = 'define' ]; then
		archname="MSWin32-$architecture-perlio"
	else
		archname="MSWin32-$architecture"
	fi

	if [ "$useithreads" = 'define' ]; then
		archname="$archname-thread"
	fi

	if [ "$arch" != 'x86_64' -a "$use64bitint" = 'define' ]; then
		archname="$archname-64bit"
	fi

	if [ "$uselongdouble" = 'define' ]; then
		archname="$archname-ld"
	fi
}

msg "Checking which hints to use"

arch=`echo "$targetarch" | cut -d - -f 1`

if [ "$osname" = "MSWin32" ]; then
	# Win32 archnames do not follow the simple scheme below
	set_win32_archname
else
	# For i686-pc-linux-gnu, try linux and i686-linux
	archname="$arch-$osname"
fi

if [ -n "$userhints" ]; then
	for h in `echo "$userhints" | sed -e 's/,/ /g'`; do
		tryhints 'hint' "$h"
	done
else
	tryhints "$archname"
	tryhints "$osname"
fi

# Check whether we'll need to append anything to archname
# configure_version must be included somewhere before this point
if [ "$useversionedarchname" = 'define' ]; then
	msg "Using versioned archname ($archname-$api_versionstring)"
	define archname "$archame-$api_versionstring"
else
	define archname "$archname"
fi

# Add separator to log file
log
