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
		return 1
	else
		result "unknown"
		msg "\tcan't check byte order without known uvsize"
		return 1
	fi

	if try_compile; then
		if try_objdump -j .data -s; then
			byteorder=`grep '11' try.out | grep '44' | sed -e 's/  .*//' -e 's/[^1-8]//g' -e 's/\([1-8]\)\1/\1/g'`
			result "$byteorder"
			return 0
		fi
	fi

	result 'unknown'
	return 1
}

check byteorder
