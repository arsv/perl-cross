# Toolchain detection

tryprog() {
	log "trying $1=$2"
	if command -v "$2" 1>/dev/null 2>/dev/null; then
		define "$1" "$2"
		result "$2"
		return 0
	else
		return 1
	fi
}

# whichprog symbol VAR prog1 prog2
whichprog() {
	mstart "Checking for $1"
	hinted "$1" && return

	if [ "$mode" = "buildmini" ]; then
		getenv ev "HOST$2"
	else
		getenv ev "$2"
	fi

	if [ -n "$ev" ]; then
		if tryprog $1 "$ev"; then
			return
		else
			die "Supplied $vv is not usable"
		fi
	fi

	if [ "$mode" = 'native' -o "$mode" = 'buildmini' ]; then
		tryprog $1 "$3" && return
	fi

	test -n "$toolsprefix" && tryprog $1 "$toolsprefix-$3" && return
	test -n "$target"      && tryprog $1 "$target-$3"      && return
	test -n "$targetarch"  && tryprog $1 "$targetarch-$3"  && return

	result "none found"
	define "$1" 'false' # ouch
	return 1
}

whichprog cc CC gcc || whichprog cc CC cc
whichprog ld LD ld
whichprog ar AR ar
whichprog ranlib RANLIB ranlib
whichprog readelf READELF readelf
whichprog objdump OBJDUMP objdump

define cpp "$cc -E"
log

mstart "Trying $cc"
if not hinted 'cctype'; then
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
			define 'cctype' 'gcc'
			define 'ccversion' "$_cv"
			define 'gccversion' "$_cv"
			result "gcc $_cv"
			;;
		clang*)
			_cv=`echo "$_cl" | sed -e 's/.*version //' -e 's/ .*//'`
			define 'cctype' 'clang'
			define 'ccversion' "$_cv"
			result "clang $_cv"
			;;
		*)
			result 'unknown'
			;;
	esac; fi
fi

mstart "Checking whether $cc is a C++ compiler"
if not hinted 'd_cplusplus'; then
	try_start
	try_cat <<END
#if defined(__cplusplus)
YES
#endif
END
	try_dump
	if not run $cc $ccflags -E try.c > try.out 2>>$cfglog; then
		define 'd_cplusplus' 'undef'
		result "probably no"
	else
		_r=`grep -v '^#' try.out | grep . | head -1 | grep '^YES'`
		if [ -n "$_r" ]; then
			define 'd_cplusplus' 'define'
			result "yes"
		else
			define 'd_cplusplus' 'undef'
			result 'no'
		fi
	fi
fi

mstart "Deciding how to declare external symbols"
if not hinted "extern_C"; then
	case "$d_cplusplus" in
		define)
			define "extern_C" 'extern "C"'
			result "$extern_C"
			;;
		*)
			define "extern_C" 'extern'
			result "$extern_C"
			;;
	esac
fi

# File name extensions, must be set before running any compile/link tests

define _o '.o'
define _a '.a'
define so 'so'

# Linker flags setup

predef lddlflags "-shared"
predef ccflags ''
predef ldflags ''
predef cppflags ''

if [ "$mode" = 'target' -o "$mode" = 'native' ]; then
	if [ -n "$sysroot" ]; then
		msg "Adding --sysroot to {cc,ld}flags"
		prepend ccflags "--sysroot=$sysroot"
		prepend ldflags "--sysroot=$sysroot"
		# While cccdlflags are used together with ccflags,
		# ld is always called with lddlflags *instead*of* ldflags
		prepend lddlflags "--sysroot=$sysroot"
		# Same for cpp
		prepend cppflags "--sysroot=$sysroot"
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
				append lddlflags "$f"
				;;
		esac
	done
fi

# finish ccflags # done later in _hdrs because of LARGEFILE_SOURCE
enddef ldflags
enddef lddlflags
enddef cppflags

mstart "Checking whether ld supports scripts"
if not hinted 'ld_can_script'; then
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

	if run $cc $cccdlflags $ccdlflags $ccflags $lddlflags -o a.out try.c \
		-Wl,--version-script=try.h >/dev/null 2>&1 \
		&& test -s a.out
	then
		define ld_can_script 'define'
		result "yes"
	else
		define ld_can_script 'undef'
		result "no"
	fi
fi

# Guessing OS is better done with the toolchain available.
# CC output is crucial here -- Android toolchains come with
# generic armeabi prefix and "android" is one of the few osname
# values that make difference later.

mstart "Trying to guess target OS"
if not hinted 'osname'; then
	run $cc -v > try.out 2>&1
	try_dump_out

	_ct=`sed -ne '/^Target: /s///p' try.out`
	test -z "$_ct" && _ct="$targetarch"

	case "$_ct" in
		*-android|*-androideabi)
			define osname "android"
			result "Android"
			;;
		*-linux*)
			define osname "linux"
			result "Linux"
			;;
		*-bsd*)
			define osname "bsd"
			result "BSD"
			;;
		*)
			result "no"
			;;
	esac
fi

# Check whether debugging should be enabled
# Allow -DEBUGGING as well (sets EBUGGING=define)
case "$DEBUGGING:$EBUGGING" in
	:*)
		DEBUGGING=$EBUGGING
		;;
esac

mstart "Checking whether to enable -g"
predef optimize ''
case "$DEBUGGING" in
	both|define)
		append optimize "-g"
		result "yes" ;;
	*)
		result "no" ;;
esac

mstart "Checking whether to use -DDEBUGGING"
case "$DEBUGGING" in
	both|define)
		append optimize '-DDEBUGGING'
		result "yes" ;;
	*)
		result "no" ;;
esac

# gcc 4.9 by default does some optimizations that break perl.
# see perl ticket 121505.
case "$cctype-$ccversion" in
	gcc-4.9*|gcc-5.*|gcc-6.*)
		append 'optimize' '-fwrapv -fno-strict-aliasing'
		;;
esac
enddef optimize
