#!/bin/sh

function byteorder {
	mstart "Guessing byte order"
	ifhint 'byteorder' && return 0

	try_start
	try_add 'int foo = 0x44332211;'
	if try_compile; then
		if try_objdump -j .data -s; then
			byteorder=`grep '11' try.out | grep '44' | sed -e 's/  .*//' -e 's/[^1-4]//g' -e 's/\([1-4]\)\1/\1/g'`
			result "$byteorder"
			return 0
		fi
	fi

	result 'unknown'
	return -1
}

check byteorder
