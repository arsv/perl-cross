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
		msg "	no hints for $1"
	fi
}

function hint {
	eval _value="\"\$$1\""
	if [ -z "$_value" ]; then
		setvaru "$1" "$2" 'hinted'
	fi
}

msg "Checking which hints to use"
if [ -n "$userhints" ]; then
	for h in `echo "$userhints" | sed -e 's/,/ /g'`; do
		usehints "$h"
	done
fi
	
# For i686-pc-linux-gnu, try such hints:
#	i686-pc-linux-gnu	(complete target arch)
#	linux-gnu		(os name)
#	linux
#	i686-pc			(machine name)
#	i686
if [ -n "$targetarch" ]; then
	h_arch=`echo "$targetarch" | cut -d - -f 1`
	h_mach=`echo "$targetarch" | cut -d - -f 2`
	h_base=`echo "$targetarch" | cut -d - -f 3`
	h_type=`echo "$targetarch" | cut -d - -f 3-`
	log "	got arch='$h_arch' mach='$h_mach' base='$h_base' type='$h_type'"
	usehints "a/$targetarch"
	usehints "t/$h_type"
	usehints "t/$h_base"
	usehints "h/$h_arch-$h_mach"
	usehints "h/$h_arch"
	# Once we get all this $h_*, let's set archname
	setvardefault archname "$h_arch-$h_base"
elif [ -n "$target" ]; then
	usehints "z/$target"
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
