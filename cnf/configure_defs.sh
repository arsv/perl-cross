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
function checkdefined {
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

checkintdefined DBL_DIG 'limits.h float.h'
checkintdefined LDBL_DIG 'limits.h float.h'

checkdefined __GLIBC__ d_gnulibc "Checking if we're using GNU libc" "stdio.h"

