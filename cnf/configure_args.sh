# Arguments parsing.

defuser() {
	define "$1" "$2" 'args'
}

defineyesno() {
	if [ "$2" = "yes" ]; then
		defuser "$1" "$3"
	elif [ "$2" = "no" ]; then
		defuser "$1" "$4"
	elif [ -z "$2" ]; then
		defuser "$1" "$3"
	else
		die "Bad value for $1, only 'yes' and 'no' are allowed"
	fi
}

defyes() { defineyesno "$1" "$2" 'define' 'undef'; }
defno()  { defineyesno "$1" "$2" 'undef' 'define'; }

# setordefine key hasarg arg default-a default-b
setordefine() {
	if [ -n "$2" ]; then
		defuser "$1" "$3"
	else case "$1" in
		# There are several variables that take true/false
		# instead of define/undef. And some code that does not accept
		# "define" instead of "true". Ugh.
		useopcode|useposix|useshrplib|usevfork)
			defuser "$1" "$5"
			;;
		*)
			defuser "$1" "$4"
			;;
	esac fi
}

# Like source but avoid $PATH searches for simple file names.
# Also guards loop variables from being clobbered by the loaded file.
sourcenopath() {
	case "$1" in
		/*) source "$1" ;;
		*) source "./$1" ;;
	esac
	shift
	eval "$@"
}

define config_arg0 "$0"
define config_argc $#
define config_args "$*"

alist=''

# Do *not* use shifts here! The args may be used later
# to call configure --mode=target, and saving them
# by other means is hard.
i=1
n=''	# next opt
while [ $i -le $# -o -n "$n" ]; do
	# in case we've got a short-opt cluster (-abc etc.)
	if [ -z "$n" ]; then
		eval a="\${$i}"; i=$((i+1))	# arg ("set" or 'D')
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
		eval k="\${$i}"; i=$((i+1))
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
		mode) mode="$v" ;;
		help) mode="help" ;;
		regen|regenerate) mode="regen" ;;
		keeplog) defuser "$a" 1 ;;
		prefix|html[13]dir|libsdir|libdir)	defuser $a "$v" ;;
		man[13]dir|otherlibsdir)	defuser $a "$v" ;;
		siteprefix|sitehtml[13]dir)	defuser $a "$v" ;;
		siteman[13]dir|vendorman[13]dir)defuser $a "$v" ;;
		vendorprefix|vendorhtml[13]dir)	defuser $a "$v" ;;
		target|targetarch)		defuser $a "$v" ;;
		build|buildarch)		defuser $a "$v" ;;
		cc|cpp|ar|ranlib|objdump)	defuser $a "$v" ;;
		sysroot)			defuser $a "$v" ;;
		ttp|tools-prefix|target-tools-prefix)
			setenv 'toolsprefix' "$v"
			;;
		no-dynaloader|without-dynaloader)
			defuser 'usedl' 'undef'
			;;
		with-dynaloader)
			defuser 'usedl' 'define'
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
				v=`echo ",$v" | sed -r -e 's/,([^,]+)/-l\1 /g'`
				defuser 'libs' "$v"
			fi
			;;
		host-*)
			what=`echo "$a" | sed -e 's/^host-//'`
			hco="$hco --$what=$v"
			;;
		with-*)
			what=`echo "$a" | sed -r -e 's/^[^-]+-//' -e 's/-/_/g'`
			defuser "$what" "$v"
			;;
		disable-mod|disable-ext|disable-module|disable-modules)
			for m in `echo "$v" | sed -e 's/,/ /g'`; do
				s=`modsymname "$m"`
				defuser "disable_$s" "1"
			done
			;;
		static-mod|static-ext|static-modules|static)
			for m in `echo "$v" | sed -e 's/,/ /g'`; do
				s=`modsymname "$m"`
				defuser "static_$s" "1"
			done
			;;
		only-mod|only-ext|only-modules|only)
			for m in `echo "$v" | sed -e 's/,/ /g'`; do
				s=`modsymname "$m"`
				defuser "only_$s" "1"
				defuser "onlyext" "$s $onlyext"
			done
			;;
		all-static) defuser 'allstatic' 1 ;;
		use) defuser "use$k" 'define' ;;
		dont-use) defuser "use$k" 'undef' ;;
		set) defuser "$k" "$v" ;;
		has) defyes "d_$k" "$v" ;;
		no) defno "d_$k" "$v" ;;
		include) defyes "i_$k" "$v" ;;
		dont-include) defno "i_$k" "$v" ;;
		host|target|build) ;;
		# original Configure options
		D)
			setordefine "$k" "$x" "$v" 'define' 'true'
			;;
		U)
			test -n "$v" && msg "WARNING: -Ukey=val, val ignored; use -Dkev=val instead"
			setordefine "$k" "$x" "" 'undef' 'false' # "" is *not* a typo here!
			;;
		O) msg "WARNING: -O ignored" ;;
		f) sourcenopath "$v" "i=$i" "n=$n" ;;
		A) setenv "a_$k" "$v"; alist="$alist $k" ;;
		S|V|K) die "-$a is not supported" ;;
		d|r) msg "WARNING: -$a makes no sense for this version of configure and was ignored" ;;
		e|E) msg "WARNING: -$a ignored; you'll have to proceed with 'make' anyway" ;;
		*) die "Unknown argument $a" ;;
	esac
done

for k in $alist; do
	getenv v "x_$k"
	test -n "$v" && die "Cannot append to an explicitly set variable $k"
done

unset -v i a k v x n

# use64bitint must be passed to miniperl
test "$use64bitint" = 'define' && hco="$hco -Duse64bitint"
