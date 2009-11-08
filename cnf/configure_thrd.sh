#!/bin/sh

# Thread support
# This is called only if $usethreads is set (which is not by default)

# Both presence *and* prototype for the function are checked here,
# with prototype encoded (almost) the same way relevant constants from
# config.h use:
# 	[A-Z]_[A-Z]+
# Each letter mean one type; first, return type, then arguments
#	I_BBW	int foo(char*, char*, size_t)
#	V_HI	void bar(FILE*, int)
# Here's what each letter mean:

type_I='int'
type_B='char*'
type_C='const char*'
type_V='void'
type_H='FILE*'
type_W='size_t'
type_Z='double'

# There are also four special letters: T S D and R. Types for these are
# specified for each test separately (usually that's pointer to some struct)

# hasfuncr name args includes 'protodef1 protodef2 ...' 'type_T type_S ...'
function hasfuncr {
	w="$1"
	D="d_$w"
	i="pthread.h $2"
	P="$3"
	shift 3

	require 'cc'
	mstart "Checking for $w"

	__=13
	ifhintdefined "$D" 'present' 'missing' && test $__ != 0 && return $__

	if [ $__ == '13' ]; then
		try_start
		#try_includes $i
		try_add "int main(void) { $w(); return 0; }"
		try_link
		resdef 'found' 'not found' "$D" || return $__
	fi

	msg "Checking which prototype $w has"
	# The following "real" prototype checks may return false positives
	# if none of included headers declares prototype for $w. To mend this, we
	# first check if ostesibly incorrect prototype 'D_Z' will return false.
	# Note: it is assumed none of the functions being tested has D_Z prototype
	# (which is likely true, give the value of $type_Z)
	if hasfuncr_proto "$w" "$i" 'D_Z' "$@"; then
		msg "\toops, no function should have D_Z prototype"
		msg "\tassuming there's none defined and the function is not usable"
		setvar "$D" 'undef'
		return 1;
	fi
	for p in $P; do
		if hasfuncr_proto "$w" "$i" "$p" "$@"; then
			setvar "${w}_proto" "$p"
			return 0;
		fi
	done
	msg "\tfailed, assuming $w in unusable"
	setvar "$D" 'undef'
	return 1
}

function hasfuncr_proto {
	mstart "\tis it $3"
	try_start
	try_includes $2
	q="$1"
	shift 2
	Q=`hasfuncr_proto_str "$q" "$@"`	
	try_add "$Q"

	if try_compile; then
		result "yes"
		return 0
	else
		result "no"
		return 1
	fi
}

function hasfuncr_proto_str {
	cf="$1"
	cP="$2"
	shift 2
	for cl in T S D R; do 
		eval "type_$cl='undef'"
	done
	for cl in `echo "$cP" | sed -e 's/[^TSDR]//g' -e 's/\(.\)/\1 /g'`; do
		cv=`valueof "type_$cl"`
		log "got undefined type $cl ($cv, $1)"
		if [ "$cv" == 'undef' -a -n "$1" ]; then
			eval "type_$cl='$1'"
			log "set type_$cl = '$1'"
			shift
		fi
	done

	cr=`echo "$cP" | sed -e 's/_.*//'`
	cR=`valueof "type_$cr"`
	test -n "$cR" || die "BAD type letter $cr in $cP"

	ca=`echo "$cP" | sed -e 's/^._//' -e 's/\(.\)/\1 /g'`
	for cp in $ca; do
		cT=`valueof "type_$cp"`
		test -n "$cT" || die "BAD type letter $cp in $cP"
		if [ -z "$cA" ]; then
			cA="$cT"
		else
			cA="$cA, $cT"
		fi
	done

	echo "$cR $cf($cA);"
}

check hasfuncr asctime_r 'time.h' 'B_SB B_SBI I_SB I_SBI' 'const struct tm*'
check hasfuncr crypt_r 'sys/types.h stdio.h crypt.h' 'B_CCS B_CCD' 'struct crypt_data*'
check hasfuncr ctermid_r 'sys/types.h stdio.h' 'B_B'
check hasfuncr endpwent_r 'sys/types.h stdio.h pwd.h' 'I_H V_H'
check hasfuncr getgrent_r 'sys/types.h stdio.h grp.h' 'I_SBWR I_SBIR S_SBW S_SBI I_SBI I_SBIH' 'struct group*' 'struct group**'
check hasfuncr endgrent_r 'sys/types.h stdio.h grp.h' 'I_H V_H'
check hasfuncr getgrgid_r 'sys/types.h stdio.h grp.h' 'I_TSBWR I_TSBIR I_TSBI S_TSBI' 'gid_t' 'struct group*' 'struct group**'
check hasfuncr getgrnam_r 'sys/types.h stdio.h grp.h' 'I_CSBWR I_CSBIR S_CBI I_CSBI S_CSBI' 'struct group*' 'struct group**'
check hasfuncr drand48_r 'sys/types.h stdio.h stdlib.h' 'I_ST' 'struct drand48_data*' 'double*'
check hasfuncr endhostent_r 'sys/types.h stdio.h netdb.h' 'I_D V_D' 'struct hostent_data*'
check hasfuncr endnetent_r 'sys/types.h stdio.h netdb.h' 'I_D V_D' 'struct netent_data*'
check hasfuncr endprotoent_r 'sys/types.h stdio.h netdb.h' 'I_D V_D' 'struct protoent_data*'
check hasfuncr endservent_r 'sys/types.h stdio.h netdb.h' 'I_D V_D' 'struct servent_data*'
