# Toolchain detection

# Import common environment variables into config.sh
# setfromvar what SHELLVAR HOSTSHELLVAR
setfromvar() {
	v=`valueof "$1"`
	if [ "$mode" = "buildmini" ]; then
		w=`valueof "$3"`
	else
		w=`valueof "$2"`
	fi
	if [ -z "$v" -a -n "$w" ]; then
		log "Using $V$2 for $1"
		setvar "$1" "$w"
	fi
}

setfromvar cc CC HOSTCC
setfromvar ccflags CFLAGS HOSTCFLAGS
setfromvar cppflags CPPFLAGS HOSTCPPFLAGS
setfromvar ld LD HOSTLD
setfromvar ldflags LDFLAGS HOSTLDFLAGS
setfromvar ar AR HOSTAR
setfromvar ranlib RANLIB HOSTRANLIB
setfromvar objdump OBJDUMP HOSTOBJDUMP

# whichprog msg symbol fail prog1 prog2 ...
whichprog() {
	_what="$1"; shift
	_symbol="$1"; shift
	_fail="$1"; shift
	_force=`valueof "$_symbol"`
	_src=`valueof "x_$_symbol"`
	mstart "Checking for $_what"

	if [ -n "$_force" ]; then
		if command -v "$_force" 1>/dev/null 2>/dev/null; then
			setvar "$_symbol" "$_force"
			result "$_force ($_src)"
			return 0
		else
			result "'$_force' not found ($_src)"
			if [ -n "$_fail" -a "$_fail" != "0" ]; then
				fail "no $_what found"
			fi
			return 1
		fi
	fi

	for p in "$@"; do
		if [ -n "$p" ]; then
			if command -v "$p" 1>/dev/null 2>/dev/null; then
				setvar "$_symbol" "$p"
				result "$p"
				return 0
			fi
		fi
	done

	result "none found"
	if [ -n "$_fail" -a "$_fail" != "0" ]; then
		fail "no $_what found"
	fi

	return 1
}

if [ -n "$toolsprefix" ]; then
	ttp="$toolsprefix"
	whichprog "C compiler" cc 1      ${ttp}gcc ${ttp}cc
	whichprog "linker"     ld 1      ${ttp}gcc
	whichprog "ar"         ar 1      ${ttp}ar
	whichprog "ranlib"     ranlib 0  ${ttp}ranlib
	whichprog "readelf"    readelf 1 ${ttp}readelf
	whichprog "objdump"    objdump 1 ${ttp}objdump
else
	whichprog "C compiler" cc 1      ${pf1}gcc ${pf1}cc ${pf2}gcc
	whichprog "linker"     ld 1      ${pf1}gcc ${pf1}cc ${pf2}gcc ${pf1}ld ${pf2}ld
	whichprog "ar"         ar 1      ${pf1}ar ${pf2}ar
	whichprog "ranlib"     ranlib 0  ${pf1}ranlib ${pf2}ranlib
	whichprog "readelf"    readelf 1 ${pf1}readelf ${pf2}readelf readelf
	whichprog "objdump"    objdump 1 ${pf1}objdump ${pf2}objdump
fi

setvar 'cpp' "$cc -E"
log

mstart "Trying to guess what kind of compiler \$cc is"
if nothinted 'cctype'; then
	if run $cc --version >try.out 2>&1; then
		_cl=`head -1 try.out`
	elif run $cc -V >try.out 2>&1; then
		_cl=`head -1 try.out`
	else
		_cl=''
	fi

	try_dump_out
	if [ -z "$_cl" ]; then
		result 'unknown'
	else case "$_cl" in
		*\(GCC\)*)
			_cv=`echo "$_cl" | sed -e 's/.*(GCC) //' -e 's/ .*//g'`
			setvar 'cctype' 'gcc'
			setvar 'ccversion' "$_cv"
			setvar 'gccversion' "$_cv"
			result "gcc $_cv"
			;;
		clang*)
			_cv=`echo "$_cl" | sed -e 's/.*version //' -e 's/ .*//'`
			setvar 'cctype' 'clang'
			setvar 'ccversion' "$_cv"
			result "clang $_cv"
			;;
		*)
			result 'unknown'
			;;
	esac; fi
fi

# gcc 4.9 by default does some optimizations that break perl.
# see perl ticket 121505.
case "$cctype-$ccversion" in
	gcc-4.9*|gcc-5.*|gcc-6.*)
		appendvar 'ccflags' '-fwrapv -fno-strict-aliasing'
		;;
esac

mstart "Checking whether $cc is a C++ compiler"
if nothinted 'd_cplusplus'; then
	try_start
	try_cat <<END
#if defined(__cplusplus)
YES
#endif
END
	try_dump
	if not run $cc $ccflags -E try.c > try.out 2>>$cfglog; then
		setvar 'd_cplusplus' 'undef'
		result "probably no"
	else
		_r=`grep -v '^#' try.out | grep . | head -1 | grep '^YES'`
		if [ -n "$_r" ]; then
			setvar 'd_cplusplus' 'define'
			result "yes"
		else
			setvar 'd_cplusplus' 'undef'
			result 'no'
		fi
	fi
fi

mstart "Deciding how to declare external symbols"
if nothinted "extern_C"; then
	case "$d_cplusplus" in
		define)
			setvar "extern_C" 'extern "C"'
			result "$extern_C"
			;;
		*)
			setvar "extern_C" 'extern'
			result "$extern_C"
			;;
	esac
fi

# File name extensions, must be set before running any compile/link tests

setifndef _o '.o'
setifndef _a '.a'
setifndef so 'so'

# Linker flags setup

setifndef 'lddlflags' "-shared"
if [ "$mode" = 'target' -o "$mode" = 'native' ]; then
	if [ -n "$sysroot" ]; then
		msg "Adding --sysroot to {cc,ld}flags"
		prependvar 'ccflags' "--sysroot=$sysroot"
		prependvar 'ldflags' "--sysroot=$sysroot"
		# While cccdlflags are used together with ccflags,
		# ld is always called with lddlflags *instead*of* ldflags
		prependvar 'lddlflags' "--sysroot=$sysroot"
		# Same for cpp
		prependvar 'cppflags' "--sysroot=$sysroot"
	fi
fi

# Use $ldflags as default value for $lddlflags, together with whatever
# hints provided, but avoid re-setting anyting specified in the command line
if [ -n "$ldflags" -a "$x_lddlflags" != "user" ]; then
	msg "Checking which flags from \$ldflags to move to \$lddlflags"
	for f in $ldflags; do
		case "$f" in
			-L*|-R*|-Wl,-R*)
				msg "    added $f"
				appendvar 'lddlflags' "$f"
				;;
		esac
	done
fi

mstart "Checking whether ld supports scripts"
if nothinted 'ld_can_script'; then
	cat > try.c <<EOM
void foo() {}
void bar() {}
EOM
	cat > try.h <<EOM
LIBTEST_42 {
 global:
  foo;
 local: *;
 };
EOM
	log "try.c"
	try_dump
	log "try.h"
	try_dump_h
	rm -f a.out 2>/dev/null
	# Default values are set in _genc, but here we need one much earlier
	if [ ! -z "$lddlflags" ]; then
		_lddlflags="$lddlflags"
	else
		_lddlflags=' -shared'
	fi
	if run $cc $cccdlflags $ccdlflags $ccflags $ldflags $_lddlflags -o a.out try.c \
		-Wl,--version-script=try.h >/dev/null 2>&1 \
		&&  test -s a.out
	then
		setvar ld_can_script 'define'
		result "yes"
	else
		setvar ld_can_script 'undef'
		result "no"
	fi
fi

# Guessing OS is better done with the toolchain available.
# CC output is crucial here -- Android toolchains come with
# generic armeabi prefix and "android" is one of the few osname
# values that make difference later.

mstart "Trying to guess target OS"
if nothinted 'osname'; then
	run $cc -v > try.out 2>&1
	try_dump_out

	_ct=`sed -ne '/^Target: /s///p' try.out`
	test -z "$_ct" && _ct="$targetarch"

	case "$_ct" in
		*-android|*-androideabi)
			setvar osname "android"
			result "Android"
			;;
		*-linux*)
			setvar osname "linux"
			result "Linux"
			;;
		*-bsd*)
			setvar osname "bsd"
			result "BSD"
			;;
		*)
			result "no"
			;;
	esac
fi
