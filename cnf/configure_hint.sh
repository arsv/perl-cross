#!/bin/bash

# We want to see
#	var=value
# in hint files, but this will break things (say, overwrite variables
# set by user). So we use sed to make those lines look like
#	hint "var" "value"
# The first, not the last occurence of a variable is effective.
# That's why more specific hint files are tried first.

function usehints {
	hintfunc="$1"
	hintfile="$base/hints/$2"
	if [ -f "$hintfile" ]; then
		msg "	using $hintfile"
		sed -e "/^\([A-Za-z0-9_]\+\)=/s//$hintfunc \1 /" "$hintfile" > config.hint.tmp
		. ./config.hint.tmp
		rm -f config.hint.tmp
	else
		log "	no hints for $2"
	fi
}

function hint {
	eval _value="\"\$$1\""
	if [ -z "$_value" ]; then
		setvaru "$1" "$2" 'hinted'
	fi
}

function hintover {
	eval _value="\"\$$1\""
	eval _source="\"\$x_$1\""
	if [ -z "$_value" -o "$_source" == 'hinted' ]; then
		setvaru "$1" "$2" 'hinted'
	fi
}

function trypphints {
	hh="$1"; shift
	hp="$1"; shift
	for ha in $@; do
		test -n "$hp" && usehints "$hh" "$hp-$ha"
		usehints "$hh" "$ha"
	done
}

msg "Checking which hints to use"
if [ -n "$userhints" ]; then
	for h in `echo "$userhints" | sed -e 's/,/ /g'`; do
		usehints 'hint' "$h"
	done
fi
	
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

	trypphints 'hint' "$h_pref"\
		"$targetarch" "$h_arch-$h_mach" "$h_arch" \
		"$h_type" "$h_base" "default"

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

	trypphints 'hint' "$h_pref" "$target" "default"

	setvardefault archname "$target"
else 
	die "No \$target defined (?!)"
fi

# Add separator to log file
log
