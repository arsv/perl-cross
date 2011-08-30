#!/bin/bash

# Second part of configure_hint.sh
# By this point, $cctype may be known, and thus it may be a good
# idea to check for compiler-specific hints

if [ -n "$targetarch" -a -n "$cctype" ]; then
	msg "Checking which hints to use for cc type $cctype"
	trypphints 'hintover' "$h_pref"\
		"$targetarch-$cctype" "$h_arch-$h_mach-$cctype" "$h_arch-$cctype" \
		"$h_type-$cctype" "$h_base-$cctype" "default-$cctype"

elif [ -n "$target" -a -n "$cctype" ]; then
	msg "Checking which hints to use for cc type $cctype"
	trypphints 'hintover' "$h_pref"\
		"$targetarch-$cctype""default-$cctype"
fi
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
