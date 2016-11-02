# After we known what types we have, we've got to chose which
# of them to use.

msg "Choosing C types to be used for perl internal types"
case "$use64bitint:$d_quad:$quadtype" in
	define:define:?*)
		define ivtype "$quadtype"
		define uvtype "$uquadtype"
		define ivsize '8'
		define uvsize '8'
		;;
	*)	define ivtype "long"
		define uvtype "unsigned long"
		define ivsize $longsize
		define uvsize $longsize
		;;
esac

case "$uselongdouble:$d_longdbl" in
	define:define)
		define nvtype 'long double'
		define nvsize $longdblsize
		;;
	*)	define nvtype 'double'
		define nvsize $doublesize
		;;
esac
msg "	IV will be "$ivtype", $ivsize bytes"
msg "	UV will be "$uvtype", $uvsize bytes"
msg "	NV will be "$nvtype", $nvsize bytes"

# The following code may be wrong, but there's no way to tell this
# for sure without running on-target tests.
# Using "undef" as a safe default fails op/range.t on some targets.
#
# Note that in reality there's not that much choice here, since
# nvtype is almost invariably IEEE 754 double (8 bytes) or long double
# (10 bytes), while uvtype is either 4-byte of 8-byte unsigned integer.
#
# Quite surprisingly, perl seems to be content with nv_preserves_uv_bits=0
# in all cases. However, given the floating-point type selection above,
# it's seems to be safe to assume preserved bits match IEEE 754 definitions
# as well.
#
# Signedness of uvtype doesn't generally matter, except when it's long double
# vs 64bit int. However, uvtype should always be unsigned, and the code above
# makes sure it is.
mstart "Guessing nv_preserves_uv_bits value"
if not hinted "nv_preserves_uv_bits"; then
	case "$nvsize:$uvsize" in
		4:*)
			define nv_preserves_uv_bits 16
			result "$nv_preserves_uv_bits"
			;;
		*:4)
			define nv_preserves_uv_bits 32
			result "$nv_preserves_uv_bits"
			;;
		8:8)
			define nv_preserves_uv_bits 53
			result "$nv_preserves_uv_bits"
			;;
		10:8)
			define nv_preserves_uv_bits 64
			result "$nv_preserves_uv_bits"
			;;
		*)
			define nv_preserves_uv_bits 0
			result "no idea"
			;;
	esac
fi

mstart "Deciding whether nv preserves full uv"
if not hinted "d_nv_preserves_uv"; then
	test $((8*uvsize)) = $nv_preserves_uv_bits
	resdef d_nv_preserves_uv "yes" "no"
fi

# nv_overflows_integers_at is a property of nvtype alone, it doesn't depend on
# uvtype at all. Assuming IEEE 754 floats here once again.
mstart "Checking integer capacity of nv"
if not hinted "nv_overflows_integers_at"; then
	case "$nvsize" in
		10)	define nv_overflows_integers_at '256.0*256.0*256.0*256.0*256.0*256.0*256.0*2.0*2.0*2.0*2.0*2.0*2.0*2.0*2.0'
			result "long double"
			;;
		8)	define nv_overflows_integers_at '256.0*256.0*256.0*256.0*256.0*256.0*2.0*2.0*2.0*2.0*2.0'
			result "double"
			;;
		4)	define nv_overflows_integers_at '256.0*256.0*2.0*2.0*2.0*2.0*2.0*2.0*2.0*2.0'
			result "float"
			;;
		*)	define nv_overflows_integers_at '0.0'
			result "unknown"
			;;
	esac
fi

# Target byte order check. Must be done after choosing $uvtype.
mstart "Guessing byte order"
if not hinted 'byteorder'; then
	try_start
	try_includes "stdint.h" "sys/types.h"
	if [ "$uvsize" = 8 ]; then
		try_add "$uvtype foo = 0x8877665544332211;"
	elif [ "$uvsize" = 4 ]; then
		try_add "$uvtype foo = 0x44332211;"
	elif [ -n "$uvsize" ]; then
		result "unknown"
		die "Cannot check byte order with uvsize=$uvsize"
	else
		result "unknown"
		die "Cannot check byte order without known uvsize"
	fi

	# Most targets use .data but PowerPC has .sdata instead
	if try_compile && try_objdump -j .data -j .sdata -s; then
		bo=`grep '11' try.out | grep '44' | sed -e 's/  .*//' -e 's/[^1-8]//g' -e 's/\([1-8]\)\1/\1/g'`
	else
		bo=''
	fi

	if [ -n "$bo" ]; then
		define byteorder "$bo"
		result "$bo"
	else
		result "unknown"
		msg "Cannot determine byteorder for this target,"
		msg "please supply -Dbyteorder= in the command line."
		msg "Common values: 1234 for 32bit little-endian, 4321 for 32bit big-endian."
		exit 255
	fi
fi

# Mantissa bits. Should be actual bits, i.e. not counting the implicit bit.
setmantbits() {
	mstart "Checking mantissa bits in $3"
	case "$2" in
		4) define $1 '23' ;;
		8) define $1 '52' ;;
		10) define $1 '64' ;;
		16) define $1 '112' ;;
		*) define $1 '0' ;;
	esac
	getenv v $1
	result "$v"
	unset v
}

setmantbits nvmantbits "$nvsize" "$nvtype"
setmantbits doublemantbits "$doublesize" 'double'
setmantbits longdblmantbits "$longdblsize" 'long double'
