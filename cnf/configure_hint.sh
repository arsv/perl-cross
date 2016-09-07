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
	_v=`valueof "$1"`
	test -z "$_v" && setvaru "$1" "$2" 'hinted'
}

msg "Checking which hints to use"

# For i686-pc-linux-gnu, try linux and linux-i686
arch=`echo "$targetarch" | cut -d - -f 1`
tryhints "$osname"
tryhints "$osname-$arch"

for h in `echo "$userhints" | sed -e 's/,/ /g'`; do
	tryhints 'hint' "$h"
done

# While we're at that, set archname (for module install paths and such)
setvardefault archname "$arch-$osname"

# Check whether we'll need to append anything to archname
# configure_version must be included somewhere before this point
# Note: this breaks "set only if not set by this point" rule,
# but allows using -Darchname *and* -Duseversionedarchname at the same time
if [ "$useversionedarchname" = 'define' ]; then
	msg "Using versioned archname ($archname-$api_versionstring)"
	setvar 'archname' "$archame-$api_versionstring"
fi

# Add separator to log file
log

# Process -A arguments, if any
for k in $appendlist; do
	v=`valueof "a_$k"`
	appendvar "$k" "$v"
done
