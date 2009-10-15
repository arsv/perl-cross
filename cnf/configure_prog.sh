#!/bin/sh

# Find out which progs to use (mostly by trying prefixes based on $target)

# whichprog msg symbol fail prog1 prog2 ...
function whichprog {
	_what="$1"; shift
	_symbol="$1"; shift
	_fail="$1"; shift
	eval _force="\"\$$_symbol\""
	mstart "Checking for $_what"

	if [ -n "$_force" ]; then
		if which "$_force" >&/dev/null; then
			result "$_force (forced)"
			setvar "$_symbol" "$_force"
			return 0
		else
			result "forced '$_force' not found"
			if [ -n "$_fail" -a "$_fail" != "0" ]; then
				fail "no $_what found"
			fi
			return 1
		fi
	fi
	
	for p in "$@"; do
		if [ -n "$p" ]; then
			if which "$p" >&/dev/null; then
				result "$p"
				setvar "$_symbol" "$p"
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

check whichprog "C compiler" cc 1      ${pf1}gcc ${pf1}cc ${pf2}gcc
check whichprog "linker"     ld 1      ${pf1}ld ${pf2}ld
check whichprog "ar"         ar 1      ${pf1}ar ${pf2}ar
check whichprog "ranlib"     ranlib 0  ${pf1}ranlib ${pf2}ranlib
check whichprog "readelf"    readelf 1 ${pf1}readelf ${pf2}readelf readelf
check whichprog "objdump"    objdump 1 ${pf1}objdump ${pf2}objdump

const 'cpp' "$cc -E"

failpoint
