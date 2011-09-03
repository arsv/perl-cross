#!/bin/bash

# checkintdefined DEF "includes"
function checkintdefined {
	k=`echo "$1" | tr A-Z a-z | sed -e 's/^/d_/'`
	mstart "Checking whether $1 is defined"
	ifhint "$k" && return 0
	try_start
	try_includes $2
	try_add "int i = $1;"
	try_compile
	resdef 'yes' 'no' $k
}

# checkdefined DEF var "Message" "includes"
function checkdefinedmsg {
	mstart "$3"
	ifhint "$2" && return 0
	try_start
	try_includes $4
	try_add "#ifndef $1"
	try_add "#error here"
	try_add "#endif"
	try_add "int foo(void) { return 0; }"
	try_compile
	resdef 'yes' 'no' $2
}

function checkdefined {
	checkdefinedmsg "$1" "d_$1" "Checking whether $1 is defined in $2" "$2"
}

checkintdefined DBL_DIG 'limits.h float.h'
checkintdefined LDBL_DIG 'limits.h float.h'

checkdefinedmsg __GLIBC__ d_gnulibc "Checking if we're using GNU libc" "stdio.h"

# for fpclassify test later
if [ "$d_fpclassify" != 'undef' -o "$d_fpclass" != 'undef' ]; then
	checkdefined FP_SNAN "math.h"
	checkdefined FP_QNAN "math.h"
	if [ "$d_fpclassify" != 'undef' ]; then
		checkdefined FP_INFINITE "math.h"
		checkdefined FP_NORMAL "math.h"
		checkdefined FP_SUBNORMAL "math.h"
		checkdefined FP_ZERO "math.h"
	fi
	if [ "$d_fpclass" != 'undef' ]; then
		checkdefined FP_NEG_INF 'math.h'
		checkdefined FP_POS_INF 'math.h'
		checkdefined FP_NEG_INF 'math.h'
		checkdefined FP_NEG_NORM 'math.h'
		checkdefined FP_POS_NORM 'math.h'
		checkdefined FP_NEG_NORM 'math.h'
		checkdefined FP_NEG_DENORM 'math.h'
		checkdefined FP_POS_DENORM 'math.h'
		checkdefined FP_NEG_DENORM 'math.h'
		checkdefined FP_NEG_ZERO 'math.h'
		checkdefined FP_POS_ZERO 'math.h'
		checkdefined FP_NEG_ZERO 'math.h'
	fi
fi
