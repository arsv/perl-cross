#!/bin/bash

# checkintdefined DEF includes
function checkintdefined {
	d="$1"; shift
	k=`echo "$d" | tr A-Z a-z | sed -e 's/^/d_/'`
	mstart "Checking whether $d is defined"
	try_start
	try_includes $*
	try_add "int i = $d;"
	try_compile
	resdef 'yes' 'no' $k
}

checkintdefined DBL_DIG 'limits.h' 'float.h'
checkintdefined LDBL_DIG 'limits.h' 'float.h'
