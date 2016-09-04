# After we known what types we have, we've got to chose which
# of them to use.

msg "Choosing C types to be used for perl internal types"
case "$use64bitint:$d_quad:$quadtype" in
define:define:?*)
	setvar ivtype "$quadtype"
	setvar uvtype "$uquadtype"
	setvar ivsize 8
	setvar uvsize 8
	;;
*)	setvar ivtype "long"
	setvar uvtype "unsigned long"
	setvar ivsize $longsize
	setvar uvsize $longsize
	;;
esac

case "$uselongdouble:$d_longdouble" in
define:define)
	setvar nvtype "long double"
	setvar nvsize $longdblsize
	;;
*)	setvar nvtype double
	setvar nvsize $doublesize
	;;
esac

msg "	IV will be "$ivtype", $ivsize bytes"
msg "	UV will be "$uvtype", $uvsize bytes"
msg "	NV will be "$nvtype", $nvsize bytes"

# The following code may be wrong, but there's no way to
# tell for sure without running on-target tests.
# And "undef" as a safe default fails op/range.t on some targets.
# So try to make a guess.
#
# Note that in reality there's not that much choice here, since
# nvtype is almost invariably an IEEE 754 double (8 bytes) or long double (10 bytes),
# while uvtype is either 4-byte of 8-byte unsigned integer.
#
# Quite surprisingly, perl seems to be content with nv_preserves_uv_bits=0
# in all cases. However, given the floating-point type selection above,
# it's seems to be safe to assume preserved bits match IEEE 754 definitions as well.
#
# Signedness of uvtype doesn't generally matter, except when it's long double vs 64bit int.
# However, uvtype should always be unsigned, and the code above makes sure it is.
mstart "Guessing nv_preserves_uv_bits value"
if nothinted "nv_preserves_uv_bits"; then
	case "$nvsize:$uvsize" in
		4:*)
			setvar nv_preserves_uv_bits 16
			result "$nv_preserves_uv_bits"
			;;
		*:4)
			setvar nv_preserves_uv_bits 32
			result "$nv_preserves_uv_bits"
			;;
		8:8)
			setvar nv_preserves_uv_bits 53
			result "$nv_preserves_uv_bits"
			;;
		10:8)
			setvar nv_preserves_uv_bits 64
			result "$nv_preserves_uv_bits"
			;;
		*)
			setvar nv_preserves_uv_bits 0
			result "no idea"
			;;
	esac
fi

mstart "Deciding whether nv preserves full uv"
if nothinted "d_nv_preserves_uv"; then
	test $nv_preserves_uv_bits -gt 0 -a $((8*uvsiz)) = $nv_preserves_uv_bits
	resdef "apparently so" "probably no" d_nv_preserves_uv
fi

# nv_overflows_integers_at is a property of nvtype alone, it doesn't depend on uvtype at all.
# Assuming IEEE 754 floats here once again.
mstart "Checking integer capacity of nv"
if nothinted "nv_overflows_integers_at"; then
	case "$nvsize" in
		10)	setvar nv_overflows_integers_at '256.0*256.0*256.0*256.0*256.0*256.0*256.0*2.0*2.0*2.0*2.0*2.0*2.0*2.0*2.0'
			result "long double"
			;;
		8)	setvar nv_overflows_integers_at '256.0*256.0*256.0*256.0*256.0*256.0*2.0*2.0*2.0*2.0*2.0'
			result "double"
			;;
		4)	setvar nv_overflows_integers_at '256.0*256.0*2.0*2.0*2.0*2.0*2.0*2.0*2.0*2.0'
			result "float"
			;;
		*)	result "unknown"
			;;
	esac
fi

failpoint
