#!/bin/bash

function byteorder {
	mstart "Guessing byte order"
	ifhint 'byteorder' && return 0

	try_start
	try_includes "sys/types.h"
	if [ "$uvsize" == 8 ]; then
		try_add "$uvtype foo = 0x8877665544332211;"
	elif [ "$uvsize" == 4 ]; then
		try_add "$uvtype foo = 0x44332211;"
	elif [ -n "$uvsize" ]; then
		result "unknown"
		msg "\tcan't check byte order with uvsize=$uvsize"
		exit 1
	else
		result "unknown"
		msg "\tcan't check byte order without known uvsize"
		exit 1
	fi

	if try_compile; then
		# Most targets use .data but PowerPC has .sdata instead
		if try_objdump -j .data -j .sdata -s; then
			byteorder=`grep '11' try.out | grep '44' | sed -e 's/  .*//' -e 's/[^1-8]//g' -e 's/\([1-8]\)\1/\1/g'`
			if [ -n "$byteorder" ]; then
				result "$byteorder"
				return 0
			else
				msg "\tcannot determine byteorder for this target"
				msg "\tplease supply -Dbyteorder= in the command line"
				msg "\tcommon values: 1234 for 32bit little-endian, 4321 for 32bit big-endian"
				exit 1
			fi
		fi
	fi

	result 'unknown'
	exit 1
}

check byteorder
