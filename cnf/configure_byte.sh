# Target byte order check

mstart "Guessing byte order"
if nothinted 'byteorder'; then
	try_start
	try_includes "sys/types.h"
	if [ "$uvsize" = 8 ]; then
		try_add "$uvtype foo = 0x8877665544332211;"
	elif [ "$uvsize" = 4 ]; then
		try_add "$uvtype foo = 0x44332211;"
	elif [ -n "$uvsize" ]; then
		result "unknown"
		fail "Cannot check byte order with uvsize=$uvsize"
	else
		result "unknown"
		fail "Cannot check byte order without known uvsize"
	fi

	# Most targets use .data but PowerPC has .sdata instead
	if try_compile && try_objdump -j .data -j .sdata -s; then
		byteorder=`grep '11' try.out | grep '44' | sed -e 's/  .*//' -e 's/[^1-8]//g' -e 's/\([1-8]\)\1/\1/g'`
	else
		byteorder=''
	fi

	if [ -n "$byteorder" ]; then
		result "$byteorder"
	else
		result "unknown"
		fail "Cannot determine byteorder for this target,"
		msg "please supply -Dbyteorder= in the command line."
		msg "Common values: 1234 for 32bit little-endian, 4321 for 32bit big-endian."
	fi
fi
