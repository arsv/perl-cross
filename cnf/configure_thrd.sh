#!/bin/sh

# Thread support
# This is called only if $usethreads is set (which is not by default)

# Both presence *and* prototype for the function are checked here,
# with prototype encoded (almost) the same way relevant constants from
# config.h use:
# 	[A-Za-z]_[A-Za-z]+
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
type_E='int*'
type_U='unsigned long'
type_L='long int'
type_i='int*'
type_l='long*'
type_t='int32_t*'
type_s='socklen_t'
type_u='uint32_t'

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
	# first check if ostesibly incorrect prototype 'V_Z' will return false.
	# Note: it is assumed none of the functions being tested has V_Z prototype
	# (which is likely true, give the value of $type_Z)
	if hasfuncr_proto "$w" "$i" 'V_Z' "$@"; then
		msg "\toops, no function should have V_Z prototype"
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
	msg "\tfailed, assuming $w is unusable"
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
check hasfuncr getgrent_r 'sys/types.h stdio.h grp.h' 'I_SBWR I_SBIR S_SBW S_SBI I_SBI I_SBIH' \
	'struct group*' 'struct group**'
check hasfuncr endgrent_r 'sys/types.h stdio.h grp.h' 'I_H V_H'
check hasfuncr getgrgid_r 'sys/types.h stdio.h grp.h' 'I_TSBWR I_TSBIR I_TSBI S_TSBI' \
	'gid_t' 'struct group*' 'struct group**'
check hasfuncr getgrnam_r 'sys/types.h stdio.h grp.h' 'I_CSBWR I_CSBIR S_CBI I_CSBI S_CSBI' \
	'struct group*' 'struct group**'
check hasfuncr drand48_r 'sys/types.h stdio.h stdlib.h' 'I_ST' 'struct drand48_data*' 'double*'
check hasfuncr endhostent_r 'sys/types.h stdio.h netdb.h' 'I_D V_D' 'struct hostent_data*'
check hasfuncr endnetent_r 'sys/types.h stdio.h netdb.h' 'I_D V_D' 'struct netent_data*'
check hasfuncr endprotoent_r 'sys/types.h stdio.h netdb.h' 'I_D V_D' 'struct protoent_data*'
check hasfuncr endservent_r 'sys/types.h stdio.h netdb.h' 'I_D V_D' 'struct servent_data*'
check hasfuncr getgrent_r 'grp.h' 'I_SBWR I_SBIR S_SBW S_SBI I_SBI I_SBIH' 'struct group*' 'struct group**'
check hasfuncr getgrgid_r 'sys/types.h grp.h' 'I_TSBWR I_TSBIR I_TSBI S_TSBI' 'struct group*' 'struct group**'
check hasfuncr getgrnam_r 'sys/types.h grp.h' 'I_CSBWR I_CSBIR S_CBI I_CSBI S_CSBI' 'struct group*' 'struct group**'
check hasfuncr gethostbyaddr_r 'netdb.h' \
	'I_CWISBWRE S_CWISBWIE S_CWISBIE S_TWISBIE S_CIISBIE S_CSBIE S_TSBIE I_CWISD I_CIISD I_CII I_TsISBWRE' \
	'const void*' 'struct hostent*' 'struct hostent_data*' 'struct hostent**'
check hasfuncr gethostbyname_r 'netdb.h' 'I_CSBWRE S_CSBIE I_CSD' \
	'struct hostent*' 'struct hostent**' 'struct hostent_data*'
check hasfuncr gethostent_r 'netdb.h' 'I_SBWRE I_SBIE S_SBIE S_SBI I_SBI I_SD'\
	'struct hostent*' 'struct hostent**' 'struct hostent_data*'
check hasfuncr getlogin_r 'unistd.h' 'I_BW I_BI B_BW B_BI'
check hasfuncr getnetbyaddr_r 'netdb.h' \
	'I_UISBWRE I_LISBI S_TISBI S_LISBI I_TISD I_LISD I_IISD I_uISBWRE'\
	'in_addr_t' 'struct netent*' 'struct netent_data*' 'struct netent**'
check hasfuncr getnetbyname_r 'netdb.h' 'I_CSBWRE I_CSBI S_CSBI I_CSD' \
	'struct netent*' 'struct netent**' 'struct netent_data*'
check hasfuncr getnetent_r 'netdb.h' 'I_SBWRE I_SBIE S_SBIE S_SBI I_SBI I_SD' \
	'struct netent*' 'struct netent**' 'struct netent_data*'
check hasfuncr getprotobyname_r 'netdb.h' 'I_CSBWR S_CSBI I_CSD' \
	'struct protoent*' 'struct protoent**' 'struct protoent_data*'
check hasfuncr getprotobynumber_r 'netdb.h' 'I_ISBWR S_ISBI I_ISD' \
	'struct protoent*' 'struct protoent**' 'struct protoent_data*'
check hasfuncr getprotoent_r 'netdb.h' 'I_SBWR I_SBI S_SBI I_SD' \
	'struct protoent*' 'struct protoent**' 'struct protoent_data*'
check hasfuncr getpwent_r 'pwd.h' 'I_SBWR I_SBIR S_SBW S_SBI I_SBI I_SBIH' \
	'struct passwd*' 'struct passwd**'
check hasfuncr getpwnam_r 'pwd.h' 'I_CSBWR I_CSBIR S_CSBI I_CSBI' \
	'struct passwd*' 'struct passwd**'
check hasfuncr getpwuid_r 'sys/types.h pwd.h' 'I_TSBWR I_TSBIR I_TSBI S_TSBI' \
	 'uid_t' 'struct passwd*' 'struct passwd**'
check hasfuncr getservbyname_r 'netdb.h' 'I_CCSBWR S_CCSBI I_CCSD' \
	'struct servent*' 'struct servent**' 'struct servent_data*'
check hasfuncr getservbyport_r 'netdb.h' 'I_ICSBWR S_ICSBI I_ICSD' \
	'struct servent*' 'struct servent**' 'struct servent_data*'
check hasfuncr getservent_r 'netdb.h' 'I_SBWR I_SBI S_SBI I_SD' \
	'struct servent*' 'struct servent**' 'struct servent_data*'
check hasfuncr getspnam_r 'shadow.h' 'I_CSBWR S_CSBI' 'struct spwd*' 'struct spwd**'
check hasfuncr gmtime_r 'time.h' 'S_TS I_TS' 'struct tm*' 'const time_t*'
check hasfuncr localtime_r 'time.h' 'S_TS I_TS' 'struct tm*' 'const time_t*'
check hasfuncr random_r 'stdlib.h' 'I_iS I_lS I_St' 'struct random_data*'
check hasfuncr readdir64_r 'stdio.h dirent.h' 'I_TSR I_TS' 'DIR*' 'struct dirent64*' 'struct dirent64**'
check hasfuncr readdir_r 'stdio.h dirent.h' 'I_TSR I_TS' 'DIR*' 'struct dirent*' 'struct dirent**'
check hasfuncr setgrent_r 'grp.h' 'I_SBWR I_SBIR S_SBW S_SBI I_SBI I_SBIH' 'struct group*' 'struct group**'
check hasfuncr sethostent_r 'netdb.h' 'I_ID V_ID' 'struct hostent_data*'
check hasfuncr setlocale_r 'locale.h' 'I_ICBI'
check hasfuncr setnetent_r 'netdb.h' 'I_ID V_ID' 'struct netent_data*'
check hasfuncr setprotoent_r 'netdb.h' 'I_ID V_ID' 'struct protoent_data*'
check hasfuncr setpwent_r 'pwd.h' 'I_H V_H'
check hasfuncr setservent_r 'netdb.h' 'I_ID V_ID' 'struct servent_data*'
check hasfuncr srand48_r 'stdlib.h' 'I_LS' 'struct drand48_data*'
check hasfuncr srandom_r 'stdlib.h' 'I_TS' '' 'struct random_data*'
check hasfuncr strerror_r 'string.h' 'I_IBW I_IBI B_IBW'
check hasfuncr tmpnam_r 'stdio.h' 'B_B'
check hasfuncr ttyname_r 'stdio.h unistd.h' 'I_IBW I_IBI B_IBI'
