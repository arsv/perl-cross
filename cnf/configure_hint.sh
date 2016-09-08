# Hints loading. This gets called after setting up the toolchains
# but before everything else, and the goal of the hints is
# to provide non-testable values and possibly suppress undesirable tests.

# We want to see
#	var=value
# in hint files, but this will break things (say, overwrite variables
# set by user). So we use sed to make those lines look like
#	hint "var" "value"
# Unlike pretty much any other place in cnf/, the last assignment is
# effective here.

tryhints() {
	hintfile="$base/hints/$1"
	if [ -f "$hintfile" ]; then
		msg "	using $hintfile"
		sed -r -e "/^([A-Za-z0-9_]+)=/s//hint \1 /"\
			"$hintfile" > config.hint.tmp
		. ./config.hint.tmp
		rm -f config.hint.tmp
	else
		log "	no hints for $1"
	fi
}

hint() {
	define "$1" "$2" 'hinted'
}

msg "Checking which hints to use"

# For i686-pc-linux-gnu, try linux and i686-linux
arch=`echo "$targetarch" | cut -d - -f 1`
archname="$arch-$osname"

tryhints "$osname"
tryhints "$archname"

for h in `echo "$userhints" | sed -e 's/,/ /g'`; do
	tryhints 'hint' "$h"
done

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
