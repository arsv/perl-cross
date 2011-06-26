#!/bin/bash

function defineyesno {
	if [ "$2" == "yes" ]; then
		setvar "$1" "$3"
	elif [ "$2" == "no" ]; then
		setvar "$1" "$4"
	elif [ -z "$2" ]; then
		setvar "$1" "$3"
	else
		die "Bad value for $1, only 'yes' and 'no' are allowed"
	fi
}

function defyes { defineyesno "$1" "$2" 'define' 'undef'; }
function defno  { defineyesno "$1" "$2" 'undef' 'define'; }

config_arg0="$0"
config_argc=0
config_args="$*"

for arg in "$@"; do
	config_argc=$[config_argc+1]
	a=`echo "$arg" | sed -e 's/=.*//' -e 's/^--//'`
	v=`echo "$arg" | sed -n -e 's/[^=]*=//p'`
	A="$a"
	case "$a" in 
		with-*) a=`echo "$a" | sed -e 's/^with-//'` ;;
	esac
	case "$a" in
		mode) test -z "$mode" && setvar $a "$v" || die "Can't set mode twice!" ;;
		help) setvar "mode" "help" ;;
		regen|regenerate) setvar "mode" "regen" ;;
		prefix|html[13]dir|libsdir)	setvar $a "$v" ;;
		man[13]dir|otherlibsdir)	setvar $a "$v" ;;
		siteprefix|sitehtml[13]dir)	setvar $a "$v" ;;
		siteman[13]dir|vendorman[13]dir)setvar $a "$v" ;;
		vendorprefix|vendorhtml[13]dir)	setvar $a "$v" ;;
		byteorder)			setvar $a "$v" ;;
		build|target|targetarch)	setvar $a "$v" ;;
		cc|cpp|ar|ranlib|objdump)	setvar $a "$v" ;;
		sysroot)			setvar $a "$v" ;;
		hint|hints)
			if [ -n "$userhints" ]; then
				userhints="$userhints,$v"
			else
				userhints="$v"
			fi
			;;
		libs)
			if [ -n "$v" ]; then
				v=`echo ",$v" | sed -e 's/,\([^,]\+\)/-l\1 /g'`
				setvar 'libs' "$v"
			fi
			;;
		host-*)
			what=`echo "$a" | sed -e 's/^host-//'`
			hco="$hco --$what='$v'"
			;;
		target-*)
			what=`echo "$a" | sed -s 's/-/_/g'`
			setvar "$what" "$v"
			;;
		disable-mod|disable-ext|disable-module|disable-modules)
			for m in `echo "$v" | sed -e 's/,/ /g'`; do
				s=`modsymname "$m"`
				setvar "disable_$s" "1"
			done
			;;
		static-mod|static-ext|static-modules|static)
			for m in `echo "$v" | sed -e 's/,/ /g'`; do
				s=`modsymname "$m"`
				setvar "static_$s" "1"
			done
			;;
		only-mod|only-ext|only-modules|only)
			for m in `echo "$v" | sed -e 's/,/ /g'`; do
				s=`modsymname "$m"`
				setvar "only_$s" "1"
				setvar "onlyext" "$s $onlyext"
			done
			;;
		use-*)
			what=`echo "$a" | sed -e 's/^use-//'`
			setvar "use$what" 'define'
			;;
		dont-use-*)
			what=`echo "$a" | sed -e 's/^dont-use-//'`
			setvar "use$what" 'undef'
			;;
		set-*)
			what=`echo "$a" | sed -e 's/^set-//' -e 's/-/_/g'`
			test -z "$v" && msg "--$a=<empty> has no effect"
			setvar "$what" "$v"
			;;
		has-*)
			what=`echo "$a" | sed -e 's/^has-//'`
			defyes "d_$what" "$v"
			;;
		no-*)
			what=`echo "$a" | sed -e 's/^no-//' -e 's/_/-/g'`
			defno "d_$what" "$v"
			;;
		lacks-*)
			what=`echo "$a" | sed -e 's/^lacks-//' -e 's/_/-/g'`
			defno "d_$what" "$v"
			;;
		include-*)
			what=`echo "$a" | sed -e 's/^include-//' -e 's/-h$//' -e 's![/.-]!!g'`
			defyes "i_$what" "$v"
			;;
		dont-include-*)
			what=`echo "$a" | sed -e 's/^dont-include-//' -e 's/-h$//' -e 's![/.-]!!g'`
			defno "i_$what" "$v"
			;;
		mode|host|target|build)
			;;
		*) die "Unknown argument $a" ;;
	esac
done
