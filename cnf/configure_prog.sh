#!/bin/bash

# Find out which progs to use (mostly by trying prefixes based on $target)

# whichprog msg symbol fail prog1 prog2 ...
function whichprog {
	_what="$1"; shift
	_symbol="$1"; shift
	_fail="$1"; shift
	_force=`valueof "$_symbol"`
	_src=`valueof "x_$_symbol"`
	mstart "Checking for $_what"

	if [ -n "$_force" ]; then
		if which "$_force" >&/dev/null; then
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
			if which "$p" >&/dev/null; then
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
	check whichprog "C compiler" cc 1      ${ttp}gcc ${ttp}cc
	check whichprog "linker"     ld 1      ${ttp}gcc
	check whichprog "ar"         ar 1      ${ttp}ar
	check whichprog "ranlib"     ranlib 0  ${ttp}ranlib
	check whichprog "readelf"    readelf 1 ${ttp}readelf
	check whichprog "objdump"    objdump 1 ${ttp}objdump
else 
	check whichprog "C compiler" cc 1      ${pf1}gcc ${pf1}cc ${pf2}gcc
	check whichprog "linker"     ld 1      ${pf1}gcc ${pf1}cc ${pf2}gcc ${pf1}ld ${pf2}ld
	check whichprog "ar"         ar 1      ${pf1}ar ${pf2}ar
	check whichprog "ranlib"     ranlib 0  ${pf1}ranlib ${pf2}ranlib
	check whichprog "readelf"    readelf 1 ${pf1}readelf ${pf2}readelf readelf
	check whichprog "objdump"    objdump 1 ${pf1}objdump ${pf2}objdump
fi

setvar 'cpp' "$cc -E"

failpoint

# some more info on the compiler
mstart "Checking for GNU cc in disguise and/or its version number"
if not hinted 'gccversion'; then
	try_start
	try_cat <<END
#if defined(__GNUC__) && !defined(__INTEL_COMPILER)
#ifdef __VERSION__
VERSION __VERSION__
#endif
#endif
END
	try_dump
	if not run $cc $ccflags -E try.c > try.out 2>>$cfglog; then
		result "definitely not gcc"
	else
		# a bit paranoid here, in case some non-gnu compiler will decide to
		# output something unexpected
		_r=`grep -v '^#' try.out | grep . | head -1 | grep '^VERSION' | sed -e 's/VERSION //' -e 's/"//g'`
		if [ -n "$_r" ]; then
			setvar 'gccversion' "$_r"
			setvar 'cctype' 'gcc'
			result "gcc ver. $_r"
		else
			result "probably not gcc"
		fi
	fi
fi

if [ -z "$cctype" ]; then
	mstart "Trying to guess what kind of compiler \$cc is"
	if not hinted 'cctype'; then
		if $cc -V >try.out 2>&1; then
			_cl=`head -1 try.out`
		elif $cc --version >try.out 2>&1; then
			_cl=`head -1 try.out`
		else
			_cl=''
		fi

		if [ -n "$_cl" ]; then
			case "$_cl" in
				*\(GCC\)*)
					setvar 'cctype' 'gcc'
					result 'GNU cc (probably defunct)'
					;;
				*"Intel(R) C++ Compiler"*|*"Intel(R) C Compiler"*)
					setvar 'cctype' 'icc'
					setvar ccversion `$cc --version | sed -n -e 's/^icp\?c \((ICC) \)\?//p'`
					result 'Intel cc'
					;;
				*" Sun "*"C"*)
					setvar 'cctype' 'sun'
					result 'Sun cc'
					;;
				*)
					result 'unknown'
					;;
			esac
		else 
			_cc=`echo "$cc" | sed -e 's!.*/!!' -e "s/^$target-//" | sed -e 's/-[0-9][0-9.a-z]*$//'`
			if [ -n "$_cc" -a "$_cc" != 'cc' ]; then
				setvar 'cctype' "$_cc"
				result "$_cc"
			else
				result 'unknown'
			fi
		fi
	fi
fi

if [ "$mode" == 'target' -o "$mode" == 'native' ]; then
	if [ -n "$sysroot" ]; then
		msg "Adding --sysroot to {cc,ld}flags"
		setvar 'ccflags' "--sysroot='$sysroot' $ccflags"
		setvar 'ldflags' "--sysroot='$sysroot' $ldflags"
	fi
fi
