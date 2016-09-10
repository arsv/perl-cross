# Thread support

mstart 'Looking whether to enable threads'
# $usethreads gets decided in configure_libs
if [ "$usethreads" = 'define' ]; then
	if [ "$use5005threads" = 'define' ]; then
		define 'useithreads' 'undef'
		result 'yes, 5.005 threads'
	elif [ "$useithreads" = 'define' ]; then
		define 'use5005threads' 'undef'
		result 'yes, ithreads'
	else
		define 'useithreads' 'define'
		define 'use5005threads' 'undef'
		result 'yes, ithreads'
	fi
else
	define 'useithreads' 'undef'
	define 'use5005threads' 'undef'
	result 'no'
	msg "Disabling thread-related stuff"
fi

# Both presence *and* prototype for the function are checked here,
# with the prototype encoded the same way as the constants from config.h:
# 	[A-Za-z]_[A-Za-z]+
# Each letter mean one type; first, return type, then arguments
#	I_BBW	int foo(char*, char*, size_t)
#	V_HI	void bar(FILE*, int)
# Here's what each letter means:

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

# There are also four special letters:
free_type_letters='T S D R'
# Types for these are specified for each test separately (usually that's
# a pointer to some struct)

# The function is only usable if it links *and* the prototype is know.
# And if threads are disabled we still have to put all those symbols
# into config.sh, without testing them.
#
# Hinting anything here is not a good idea.
# Unless it's both d_func_r and func_r_proto.

# funcproto func_r \
#	includes \
#	'P_ROTO1 P_ROTO2 ...' \
#	'T=type_T' 'S=type_S' ...

funcproto() {
	fun=$1
	inc=$2
	shift 2

	fsym="d_${fun}"
	psym="${fun}_proto"

	if [ "$usethreads" != 'define' ]; then
		define $fsym 'undef'
		define $psym '0'
		return
	fi

	mstart "Checking for $fun"

	if not checkfuncr $fsym $fun "$inc"; then
		define $fsym 'undef'
		define $psym '0'
		result "missing"
	elif not checkproto $psym $fun "$inc" "$@"; then
		define $fsym 'undef'
		define $psym '0'
		result "unusable"
	else
		getenv proto "$psym"
		define $fsym 'define'
		define $psym "$proto"
		result "found, $proto"
	fi
}

checkfuncr() {
	if gethint $1 found; then
		test $found = 'define'
	else
		try_start
		try_add "extern void $2(void);"
		try_add "int main() { $2(); return 0; }"
		try_link
	fi
}

# The following "real" prototype checks may return false positives
# if none of included headers declares prototype for $w. Because of
# this, we must make sure there was at least one negative result.
#
# In case the first one we try succeeds, V_Z is used for a negative
# test. None of the functions below have that kind of prototype,
# so it must fail in all cases.

checkproto() {
	sym=$1
	fun=$2
	inc=$3
	pro=$4
	shift 4 # the rest are type assignments

	require 'cc'
	setfreetypes "$@"

	if gethint $sym proto; then
		test -n "$proto"
		return $?
	fi

	setenv $sym ''
	hadfailure='no'
	hadsuccess='no'
	for p in $pro; do
		if tryproto $fun "$inc" $p; then
			hadsuccess='yes'
			break
		else
			hadfailure='yes'
		fi
	done

	if [ "$hadsuccess" = 'no' ]; then
		return 1
	elif [ "$hadfailure" = 'yes' ]; then
		true
	elif tryproto $fun "$inc" 'V_Z'; then
		return 1
	fi

	setenv $sym "$p"
	return 0
}

setfreetypes() {
	for cl in $free_type_letters; do
		setenv "type_$cl" 'undef'
	done

	for cv in "$@"; do
		cl=${cv%=*}
		ct=${cv##*=}

		test -n "$cl" || die "Bad type spec $cv (lhs)"
		test -n "$ct" || die "Bad type spec $cv (rhs)"

		setenv "type_$cl" "$ct"
	done
}

tryproto() {
	try_start
	try_includes $2

	fun=$1
	pro=$3

	# P_ROTO -> P
	key=${pro%_*}
	getenv ret "type_$key"
	test -n "$ret" || die "Bad type letter $key in $fun($pro)"

	# P_ROTO -> R O T O
	keys=`echo "$pro" | sed -e 's/^._//' -e 's/\(.\)/\1 /g'`
	args=''
	for key in $keys; do
		getenv arg "type_$key"
		if [ -z "$arg" ]; then
			die "Bad type letter $argkey in $fun($pro)"
		elif [ "$argtype" = "undef" ]; then
			die "Undef free type letter $argkey in $fun($pro)"
		elif [ -z "$args" ]; then
			args="$arg"
		else
			args="$args, $arg"
		fi
	done

	try_add "$ret $fun($args);"
	try_compile
}

funcproto asctime_r \
	'time.h' \
	'B_SB B_SBI I_SB I_SBI' \
	'S=const struct tm*'

funcproto ctime_r \
	'time.h' \
	'B_SB B_SBI I_SB I_SBI' \
	'S=const time_t*'

funcproto crypt_r \
	'sys/types.h stdio.h crypt.h' \
	'B_CCS B_CCD' \
	'S=struct crypt_data*' 'D=CRYPTD*'

funcproto ctermid_r \
	'sys/types.h stdio.h' \
	'B_B'

funcproto endpwent_r \
	'sys/types.h stdio.h pwd.h' \
	'I_H V_H'

funcproto getgrent_r \
	'sys/types.h stdio.h grp.h'\
	'I_SBWR I_SBIR S_SBW S_SBI I_SBI I_SBIH'\
	'S=struct group*' 'R=struct group**'

funcproto endgrent_r \
	'sys/types.h stdio.h grp.h' \
	'I_H V_H'

funcproto getgrgid_r \
	'sys/types.h stdio.h grp.h' \
	'I_TSBWR I_TSBIR I_TSBI S_TSBI' \
	'T=gid_t' 'S=struct group*' 'R=struct group**'

funcproto getgrnam_r \
	'sys/types.h stdio.h grp.h' \
	'I_CSBWR I_CSBIR S_CBI I_CSBI S_CSBI' \
	'S=struct group*' 'R=struct group**'

funcproto drand48_r \
	'sys/types.h stdio.h stdlib.h' \
	'I_ST' \
	'S=struct drand48_data*' 'T=double*'

funcproto endhostent_r \
	'sys/types.h stdio.h netdb.h' \
	'I_D V_D' \
	'D=struct hostent_data*'

funcproto endnetent_r \
	'sys/types.h stdio.h netdb.h' \
	'I_D V_D' \
	'D=struct netent_data*'

funcproto endprotoent_r \
	'sys/types.h stdio.h netdb.h' \
	'I_D V_D' \
	'D=struct protoent_data*'

funcproto endservent_r \
	'sys/types.h stdio.h netdb.h' \
	'I_D V_D' \
	'D=struct servent_data*'

funcproto gethostbyaddr_r \
	'netdb.h' \
	'I_CWISBWRE S_CWISBWIE S_CWISBIE S_TWISBIE S_CIISBIE S_CSBIE S_TSBIE I_CWISD I_CIISD I_CII I_TsISBWRE' \
	'T=const void*' 'S=struct hostent*' 'D=struct hostent_data*' 'R=struct hostent**'

funcproto gethostbyname_r \
	'netdb.h' \
	'I_CSBWRE S_CSBIE I_CSD' \
	'S=struct hostent*' 'R=struct hostent**' 'D=struct hostent_data*'

funcproto gethostent_r \
	'netdb.h' \
	'I_SBWRE I_SBIE S_SBIE S_SBI I_SBI I_SD'\
	'S=struct hostent*' 'R=struct hostent**' 'D=struct hostent_data*'

funcproto getlogin_r \
	'unistd.h' \
	'I_BW I_BI B_BW B_BI'

funcproto getnetbyaddr_r \
	'netdb.h' \
	'I_UISBWRE I_LISBI S_TISBI S_LISBI I_TISD I_LISD I_IISD I_uISBWRE'\
	'T=in_addr_t' 'S=struct netent*' 'D=struct netent_data*' 'R=struct netent**'

funcproto getnetbyname_r \
	'netdb.h' \
	'I_CSBWRE I_CSBI S_CSBI I_CSD' \
	'S=struct netent*' 'R=struct netent**' 'D=struct netent_data*'

funcproto getnetent_r \
	'netdb.h' \
	'I_SBWRE I_SBIE S_SBIE S_SBI I_SBI I_SD' \
	'S=struct netent*' 'R=struct netent**' 'D=struct netent_data*'

funcproto getprotobyname_r \
	'netdb.h' \
	'I_CSBWR S_CSBI I_CSD' \
	'S=struct protoent*' 'R=struct protoent**' 'D=struct protoent_data*'

funcproto getprotobynumber_r \
	'netdb.h' \
	'I_ISBWR S_ISBI I_ISD' \
	'S=struct protoent*' 'R=struct protoent**' 'D=struct protoent_data*'

funcproto getprotoent_r \
	'netdb.h' \
	'I_SBWR I_SBI S_SBI I_SD' \
	'S=struct protoent*' 'R=struct protoent**' 'D=struct protoent_data*'

funcproto getpwent_r \
	'pwd.h' \
	'I_SBWR I_SBIR S_SBW S_SBI I_SBI I_SBIH' \
	'S=struct passwd*' 'R=struct passwd**'

funcproto getpwnam_r \
	'pwd.h' \
	'I_CSBWR I_CSBIR S_CSBI I_CSBI' \
	'S=struct passwd*' 'R=struct passwd**'

funcproto getpwuid_r \
	'sys/types.h pwd.h' \
	'I_TSBWR I_TSBIR I_TSBI S_TSBI' \
	 'T=uid_t' 'S=struct passwd*' 'R=struct passwd**'

funcproto getservbyname_r \
	'netdb.h' \
	'I_CCSBWR S_CCSBI I_CCSD' \
	'S=struct servent*' 'R=struct servent**' 'D=struct servent_data*'

funcproto getservbyport_r \
	'netdb.h' \
	'I_ICSBWR S_ICSBI I_ICSD' \
	'S=struct servent*' 'R=struct servent**' 'D=struct servent_data*'

funcproto getservent_r \
	'netdb.h' \
	'I_SBWR I_SBI S_SBI I_SD' \
	'S=struct servent*' 'R=struct servent**' 'D=struct servent_data*'

funcproto getspnam_r \
	'shadow.h' \
	'I_CSBWR S_CSBI' \
	'S=struct spwd*' 'R=struct spwd**'

funcproto gmtime_r \
	'time.h' \
	'S_TS I_TS' \
	'S=struct tm*' 'T=const time_t*'

funcproto localtime_r \
	'time.h' \
	'S_TS I_TS' \
	'S=struct tm*' 'T=const time_t*'

funcproto random_r \
	'stdlib.h' \
	'I_iS I_lS I_St' \
	'S=struct random_data*'

funcproto readdir64_r \
	'stdio.h dirent.h' \
	'I_TSR I_TS' \
	'T=DIR*' 'S=struct dirent64*' 'R=struct dirent64**'

funcproto readdir_r \
	'stdio.h dirent.h' \
	'I_TSR I_TS' \
	'T=DIR*' 'S=struct dirent*' 'R=struct dirent**'

funcproto setgrent_r \
	'grp.h' \
	'I_SBWR I_SBIR S_SBW S_SBI I_SBI I_SBIH' \
	'S=struct group*' 'R=struct group**'

funcproto sethostent_r \
	'netdb.h' \
	'I_ID V_ID' \
	'D=struct hostent_data*'

funcproto setlocale_r \
	'locale.h' \
	'I_ICBI'

funcproto setnetent_r \
	'netdb.h' \
	'I_ID V_ID' \
	'D=struct netent_data*'

funcproto setprotoent_r \
	'netdb.h' \
	'I_ID V_ID' \
	'D=struct protoent_data*'

funcproto setpwent_r \
	'pwd.h' \
	'I_H V_H'

funcproto setservent_r \
	'netdb.h' \
	'I_ID V_ID' \
	'D=struct servent_data*'

funcproto srand48_r \
	'stdlib.h' \
	'I_LS' \
	'S=struct drand48_data*'

funcproto srandom_r \
	'stdlib.h' \
	'I_TS' \
	'T=unsigned int' 'S=struct random_data*'

funcproto strerror_r \
	'string.h' \
	'I_IBW I_IBI B_IBW'

funcproto tmpnam_r \
	'stdio.h' \
	'B_B'

funcproto ttyname_r \
	'stdio.h unistd.h' \
	'I_IBW I_IBI B_IBI'
