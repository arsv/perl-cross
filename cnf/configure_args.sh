#!/bin/bash

function defineyesno {
	if [ "$2" == "yes" ]; then
		setvaru "$1" "$3"
	elif [ "$2" == "no" ]; then
		setvaru "$1" "$4"
	elif [ -z "$2" ]; then
		setvaru "$1" "$3"
	else
		die "Bad value for $1, only 'yes' and 'no' are allowed"
	fi
}

function defyes { defineyesno "$1" "$2" 'define' 'undef'; }
function defno  { defineyesno "$1" "$2" 'undef' 'define'; }

# setordefine key hasarg arg default
function setordefine {
	if [ -n "$2" ]; then
		setvaru "$1" "$3"
	else
		setvaru "$1" "$4"
	fi
}

# pushvar stem value
function pushnvar {
	eval n_$1=\$[n_$1+0]
	eval n_=\${n_$1}
	eval $1_$n_="'$2'"
	eval n_$1=\$[n_$1+1]
	unset -v n_
}

# pushvar stem key value
function pushnvarkvx {
	eval n_$1=\$[n_$1+0]
	eval n_=\${n_$1}
	eval $1_k_$n_="'$2'"
	eval $1_v_$n_="'$3'"
	eval $1_x_$n_="'$4'"
	eval n_$1=\$[n_$1+1]
	unset -v n_
}

config_arg0="$0"
config_argc=$#
config_args="$*"

# Do *not* use shifts here! The args may be used later
# to call configure --mode=target, and saving them
# by other means is hard.
i=1
n=''	# next opt
while [ $i -le $# -o -n "$n" ]; do
	# in case we've got a short-opt cluster (-abc etc.)
	if [ -z "$n" ]; then
		eval a="\${$i}"; i=$[i+1]	# arg ("set" or 'D')
	else
		a="-$n"
		n=''
	fi
	k=''					# key ("prefix")
	v=''					# value ("/usr/local")
	x=''

	# check what kind of option is this
	case "$a" in
		# short opts
		-[dehrsEKOSV]*)
			n=`echo "$a" | sed -e 's/^-.//'`
			a=`echo "$a" | sed -e 's/^-\(.\).*/\1/'`
			;;
		-[A-Za-z]*)
			k=`echo "$a" | sed -e 's/^-.//'`
			a=`echo "$a" | sed -e 's/^-\(.\).*/\1/'`
			;;
		--[A-Za-z]*)
			a=`echo "$a" | sed -e 's/^--//'`
			;;
		*)
			echo "Bad option $a"
			continue;
			;;
	esac
	# split --set-foo and similar constructs into --set foo
	# and things like --prefix=/foo into --prefix and /foo
	case "$a" in
		set-*|use-*|include-*)
			k=`echo "$a" | sed -e 's/^[^-]*-//'`
			a=`echo "$a" | sed -e 's/-.*//'`
			;;
		dont-use-*|dont-include-*)	
			k=`echo "$a" | sed -e 's/^dont-[^-]*-//'`
			a=`echo "$a" | sed -e 's/^\(dont-[^-]*\)-.*/\1/'`
			;;
		*=*)
			k=`echo "$a" | sed -e 's/^[^=]*=//'`
			a=`echo "$a" | sed -e 's/=.*//'`
			;;
	esac
	# check whether kv is required
	# note that $x==1 means $k must be set; the value, $v, may be empty
	case "$a" in
		help|regen*|mode|host|target|build|keeplog|[dehrsEKOSV]) x='' ;;
		all-static|no-*) x='' ;;
		*) x=1 ;;
	esac
	# fetch argument if necessary (--set foo=bar)
	# note that non-empty n means there must be no argument
	if [ -n "$x" -a -z "$k" -a -z "$n" ]; then
		eval k="\${$i}"; i=$[i+1]
	fi
	# split kv pair into k and v (k=foo v=bar)
	case "$k" in
		*=*)
			v=`echo "$k" | sed -e 's/^[^=]*=//'`
			k=`echo "$k" | sed -e 's/=.*//'`
			x=1
			;;
		*)
			x=''
			;;
	esac
	#echo "a=$a k=$k v=$v"

	# Account for the fact that in "--set foo" foo is key
	# while in "--mode foo" foo is value
	case "$a" in
		set|use|has|no|include|dont-use|dont-include|D|U)	
			k=`echo "$k" | sed -e 's/-/_/g'`
			;;
		*)
			if [ -z "$v" -a -n "$k" ]; then
				v="$k"
				k=""
			fi
	esac
	#if [ -z "$v" -a -n "$k" ]; then v="$k"; k=""; fi

	# ($a, $k, $v) are all set here by this point
	# having non-empty x here means the option actually had a parameter
	# and can be used to separate -Dfoo and -Dfoo=''
	#log "a=$a k=$k v=$v ($x)"

	# process the options
	case "$a" in
		mode) setvar $a "$v" ;;
		help) setvar "mode" "help" ;;
		regen|regenerate) setvar "mode" "regen" ;;
		keeplog) setvar "$a" 1 ;;
		prefix|html[13]dir|libsdir)	setvar $a "$v" ;;
		man[13]dir|otherlibsdir)	setvar $a "$v" ;;
		siteprefix|sitehtml[13]dir)	setvar $a "$v" ;;
		siteman[13]dir|vendorman[13]dir)setvar $a "$v" ;;
		vendorprefix|vendorhtml[13]dir)	setvar $a "$v" ;;
		target|targetarch)		setvar $a "$v" ;;
		build|buildarch)		setvar $a "$v" ;;
		cc|cpp|ar|ranlib|objdump)	setvar $a "$v" ;;
		sysroot)			setvar $a "$v" ;;
		ttp|tools-prefix|target-tools-prefix)
			setvar 'toolsprefix' "$v"
			;;
		no-dynaloader|without-dynaloader)
			setvaru 'usedl' 'undef' 'user'
			;;
		with-dynaloader)
			setvaru 'usedl' 'define' 'user'
			;;
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
			what=`echo "$a" | sed -e 's/-/_/g'`
			setvaru "$what" "$v"
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
		disable-disabled-mods) setvar 'disabledmods' 'undef' ;;
		all-static) setvar 'allstatic' 1 ;;
		use) setvaru "use$k" 'define' ;;
		dont-use) setvaru "use$k" 'undef' ;;
		set) setvaru "$k" "$v" ;;
		has) defyes "d_$k" "$v" ;;
		no) defno "d_$k" "$v" ;;
		include) defyes "i_$k" "$v" ;;
		dont-include) defno "i_$k" "$v" ;;
		mode|host|target|build) ;;
		# original Configure options
		D)
			setordefine "$k" "$x" "$v" 'define'
			;;
		U)
			test -n "$v" && msg "WARNING: -Ukey=val, val ignored; use -Dkev=val instead"
			setordefine "$k" "$x" "" 'undef' # "" is *not* a typo here!
			;;
		O) overwrite=1 ;;
		f) pushnvar loadfile "$v" ;;
		A)	# see configure_hint
			pushnvarkvx appendlist "$k" "$v" "$x" ;;
		S|V|K) die "-$a is not supported" ;;
		d|r) msg "WARNING: -$a makes no sense for this version of configure and was ignored" ;;
		e|E) msg "WARNING: -$a ignored; you'll have to proceed with 'make' anyway" ;;
		*) die "Unknown argument $a" ;;
	esac
done
unset -v i a k v x n

# Process -f args (if any) after all options have been parsed
test -n "$n_loadfile" && for((i=0;i<n_loadfile;i++)); do
	f=`valueof "loadfile_$i"`
	sourcenopath $f
done
unset -v i f

# Handle -O
if [ -n "$overwrite" -a -n "$uservars" ]; then
	for k in $uservars; do
		v=`valueof "u_$k"`
		setenv $k "$v"
	done
fi
