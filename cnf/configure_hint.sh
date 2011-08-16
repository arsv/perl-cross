#!/bin/sh

# We want to see
#	var=value
# in hint files, but this will break things (say, overwrite variables
# set by user). So we use sed to make those lines look like
#	hint "var" "value"
# The first, not the last occurence of a variable is effective.
# That's why more specific hint files are tried first.

function usehints {
	hintfile="$base/hints/$1"
	if [ -f "$hintfile" ]; then
		msg "	using $hintfile"
		sed -e '/^\([A-Za-z0-9_]\+\)=/s//hint \1 /' "$hintfile" > config.hint.tmp
		. ./config.hint.tmp
		rm -f config.hint.tmp
	else
		log "	no hints for $1"
	fi
}

function hint {
	eval _value="\"\$$1\""
	if [ -z "$_value" ]; then
		setvaru "$1" "$2" 'hinted'
	fi
}

function trypphints {
	h_="$1-"; shift
	for ha in $@; do
		for hp in $h_ ''; do
			hh=`echo "$ha" | sed -e "s!:!$hp!"`
			usehints "$hh"
		done
	done
}

msg "Checking which hints to use"
if [ -n "$userhints" ]; then
	for h in `echo "$userhints" | sed -e 's/,/ /g'`; do
		usehints "$h"
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

	trypphints "$h_pref"\
		":$targetarch" "a/:$h_arch-$h_mach" "a/:$h_arch" \
		"s/:$h_type" "s/:$h_base"

	# Once we get all this $h_*, let's set archname
	setvardefault archname "$h_arch-$h_base"
elif [ -n "$target" ]; then
	usehints "$target"
	setvardefault archname "$target"
fi

usehints "default"

# Add separator to log file
log

# Process -A arguments, if any
test -n "$n_appendlist" && for((i=0;i<n_appendlist;i++)); do
	k=`valueof "appendlist_k_$i"`
	v=`valueof "appendlist_v_$i"`
	x=`valueof "appendlist_x_$i"`
	if [ -z "$k" -a -n "$v" ]; then
		k="$v"
		v=""
	fi
	case "$k" in
		*:*) a=${k/%:*/}; k=${k/#*:/} ;;
		*) a='append-sp' ;;
	esac
	case "$a" in
		append-sp) setvaru $k "`valueof $k` $v" 'user' ;;
		append) setvaru $k "`valueof $k`$v" 'user' ;;
		prepend) setvaru $k "$v`valueof $k`" 'user' ;;
		define) setordefine "$k" "$x" "$v" 'define' ;;
		undef) setordefine "$k" "$x" "" 'undef' ;;
		clear) setvaru $k '' 'user' ;;
		eval) setvaru $k `eval "$v"` 'user' ;;
		*) die "Bad -A action $a" ;;
	esac
done
