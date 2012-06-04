#!/bin/bash

# After we known what types we have, we've got to chose which
# of them to use.

# typeselect symb required-size it1 ut1 it2 ut2 ...
# Note: types are always selected in pairs, signed-unsigned,
# and it's assumed that sizeof(it[j]) == sizeof(ut[j])
function typeselect () {
	_rqsize="$1"; shift
	_symboli="$1"; shift
	_symbolu="$1"; shift

	mstart "Looking which type to use for $_symboli"
	for _itype in "$@"; do
		_utype=`unsignedof "$_itype"`
		_isymb=`symbolname "$_itype"`
		_usymb=`symbolname "$_utype"`
		eval _mark="\$d_${_isymb}"
		eval _size="\$${_isymb}size"
		log "	checking $_utype/$_itype ($_size)"
		if [ "$_mark" == 'define' -a "$_size" == "$_rqsize" ]; then
			setvar ${_symboli}size $_size
			setvar ${_symboli}type $_itype
			setvar ${_symbolu}size $_size
			setvar ${_symbolu}type $_utype
			result "$_itype / $_utype"
			return 0
		fi
	done
	result "nothing suitable found"
	return 1
}

# unsigned of type -> unsigned-type
function unsignedof {
	case "$1" in
		int*_t) echo "u$1" ;;
		*) echo "unsigned $1" ;;
	esac
}

typeselect 1  i8  u8  int8_t 'char'
typeselect 2 i16 u16 int16_t 'short'
typeselect 4 i32 u32 int32_t 'int'
typeselect 8 i64 u64 int64_t 'long' 'long long'
typeselect 8 quad uquad int64_t 'long long' 'long' 'int'

log "Looking whether quad is defined ($quadtype)"
setvar d_quad 'define'
case "$quadtype" in 
	int64_t)	setvar quadkind QUAD_IS_INT64_T ;;
	long*long)	setvar quadkind QUAD_IS_LONG_LONG ;;
	long)		setvar quadkind QUAD_IS_LONG ;;
	int)		setvar quadkind QUAD_IS_INT ;;
	*)		setvar d_quad 'undef' ;;
esac

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

# typeorfallback base primary-type
# typeorfallback base primary-type fallback-type
function typeorfallback {
	isset "${1}type" && isset "${1}size" && return 0		

	mstart "Looking which type to use as ${1}type"
	_dst="$1"; shift
	for t in "$@"; do
		_sym=`symbolname "$t"`
		_def=`valueof "d_$_sym"`
		_size=`valueof "${_sym}size"`
		log "\tsym=$_sym def=$_def size=$_size"
		if [ "$_def" == 'define' ]; then
			setvar "${_dst}type" "$t"
			setvar "${_dst}size" "$_size"	
			result "$t"
			return 0
		fi
	done

	result "none found"
	fail "No $_dst type found"
	return 1
}

typeorfallback 'fpos' 'fpos_t' 'uint64_t' 'unsigned long'
typeorfallback 'gid' 'gid_t' 'int'
typeorfallback 'lseek' 'off_t' 'uint64_t' 'unsigned long'
typeorfallback 'size' 'size_t' 'uint64_t' 'unsigned long'
typeorfallback 'ssize' 'ssize_t' 'int64_t' 'long'
typeorfallback 'time' 'time_t' 'uint32_t' 'unsigned int'
typeorfallback 'uid' 'uid_t' 'int'
setvar uidsign '1'

# Configure checks for "bool" type but uses i_stdbool for the result
if [ "$i_stdbool" == 'define' -a "$d_bool" != "define" ]; then
	msg "Disabling <stdbool.h> because bool type wasn't usable"
	setvar i_stdbool undef
fi

failpoint
