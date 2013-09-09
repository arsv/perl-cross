#!/bin/bash

# We want to see
#	var=value
# in hint files, but this will break things (say, overwrite variables
# set by user). So we use sed to make those lines look like
#	hint "var" "value"
# Unlike pretty much any other place in cnf/, the last assignment is
# effective here.

function tryhints {
	hintfile="$base/hints/$1"
	if [ -f "$hintfile" ]; then
		msg "	using $hintfile"
		sed -e "/^\([A-Za-z0-9_]\+\)+=/s//happend \1 /" \
		    -e "/^\([A-Za-z0-9_]\+\)=/s//hint \1 /"\
			"$hintfile" > config.hint.tmp
		. ./config.hint.tmp
		rm -f config.hint.tmp
	else
		log "	no hints for $1"
	fi
}

function hint {
	_v=`valueof "$1"`
	test -z "$_v" && setvaru "$1" "$2" 'hinted'
}

function happend {
	_v=`valueof "$1"`
	_s=`valueof "x_$1"`
	if [ -z "$_v" ]; then
		setvaru "$1" "$2" 'hinted'
	elif [ "$_s" == 'hinted' ]; then
		appendvar "$1" "$2"
	fi
}

# trypphints prefix hint
# tries hint then prefix-hint
function tryphints {
	test -n "$2" && tryhints "$2"
	test -n "$1" -a -n "$2" && tryhints "$1-$2"
}

msg "Checking which hints to use"
# For i686-pc-linux-gnu, try such hints:
#	i686-pc-linux-gnu	(complete target arch)
#	a/i686-pc		(architecture/machine name)
#	a/i686
#	s/linux-gnu		(operating system name)
#	s/linux
if [ -n "$targetarch" ]; then
	h_arch=`echo "$targetarch" | cut -d - -f 1`
	h_mach=`echo "$targetarch" | cut -d - -f 2`
	h_base=`echo "$targetarch" | cut -d - -f 3`
	h_type=`echo "$targetarch" | cut -d - -f 3-`
	log "	got arch='$h_arch' mach='$h_mach' base='$h_base' type='$h_type'"

	case "$mode" in
		buildmini) h_pref='host' ;;
		target) h_pref='target' ;;
		*) h_pref=''
	esac

	tryphints "$h_pref" 'default'
	tryphints "$h_pref" "$h_base"
	tryphints "$h_pref" "$h_type"
	tryphints "$h_pref" "$h_arch"
	tryphints "$h_pref" "$h_arch-$h_mach"
	tryphints "$h_pref" "$targetarch"

	# Once we get all this $h_*, let's set archname
	setvardefault archname "$h_arch-$h_base"
elif [ -n "$target" ]; then
	log "	got target=$target"
	setvardefault archname "$target"

	case "$mode" in
		buildmini) h_pref='host' ;;
		target) h_pref='target' ;;
		*) h_pref=''
	esac

	tryphints "$h_pref" 'default'
	tryphints "$h_pref" "$target"

	setvardefault archname "$target"
else 
	die "No \$target defined (?!)"
fi

if [ -n "$userhints" ]; then
	for h in `echo "$userhints" | sed -e 's/,/ /g'`; do
		tryhints 'hint' "$h"
	done
fi

# Check whether we'll need to append anything to archname
# configure_version must be included somewhere before this point
# Note: this breaks "set only if not set by this point" rule,
# but allows using -Darchname *and* -Duseversionedarchname at the same time
if [ "$useversionedarchname" == 'define' ]; then
	msg "Using versioned archname ($archname-$api_versionstring)"
	setvar 'archname' "$archame-$api_versionstring"
fi

# Add separator to log file
log
