# Thread support
# Called only if $usethreads is set (which is not by default)

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

# checkfuncr func_r includes 'P_ROTO1 P_ROTO2 ...' 'T=type_T' 'S=type_S' ...
checkfuncr() {
	w="$1"
	D="d_$w"
	i="pthread.h $2"
	P="$3"
	shift 3

	require 'cc'
	mstart "Checking for $w"

	__=13
	ifhintdefined "$D" 'present' 'missing' && test $__ != 0 && return $__

	if [ $__ = '13' ]; then
		try_start
		try_add "int main(void) { $w(); return 0; }"
		try_link
		resdef 'found' 'not found' "$D" || return $__
	fi

	msg "Checking which prototype $w has"
	checkfuncr_assign_types "$@"
	# The following "real" prototype checks may return false positives
	# if none of included headers declares prototype for $w. Because of
	# this, we must make sure there was at least one negative result.
	cz=''
	for p in $P; do
		if checkfuncr_proto "$w" "$i" "$p" "$@"; then
			setvar "${w}_proto" "$p"
			cz="${cz}y"
		elif [ -z "$cz" -o "$cz" = 'y' ]; then
			cz="${cz}n"
		fi
		if [ "$cz" = "yn" -o "$cz" = "ny" ]; then
			return 0;
		elif [ "$cz" = 'yy' ]; then
			msg "    double positive, $w has no declared prototype"
			break;
		fi
	done
	if [ "$cz" = "y" ]; then
		# There was only one prototype to test, so we take one more
		# to see if it will return negative result. V_Z is not among
		# prototypes these functions can have, so it should always
		# return negative.
		if checkfuncr_proto "$w" "$i" "V_Z" "$@"; then
			msg "    double positive, $w has no declared prototype"
		else
			return 0
		fi
	fi
	setvar "$D" 'undef'
	msg "    assuming $w is unusable"
	return 1
}

# checkfuncr_assign_types 'T=type_T' 'S=type_S' ...
checkfuncr_assign_types()
{
	for cl in $free_type_letters; do
		eval "type_$cl='undef'"
	done
	for cv in "$@"; do
		echo "$cv" | grep -q '=' || die "Bad free type specified \"$cv\" (missing =)"
		cl=`echo "$cv" | sed -e 's/=.*//'`
		ct=`echo "$cv" | sed -e 's/.=//'`
		test -n "$cl" -a -n "$ct" || die "Bad free type specified \"$cv\" (empty l- or rhs)"
		eval "type_$cl='$ct'"
		log "Setting type_$cl = '$ct'"
	done
}

# checkfuncr_proto func_r 'include.h' P_ROTO
checkfuncr_proto() {
	mstart "\tis it $3"
	try_start
	try_includes $2
	Q=`checkfuncr_proto_str "$1" "$3"`
	try_add "$Q"

	if try_compile; then
		result "yes"
		return 0
	else
		result "no"
		return 1
	fi
}

# checkfuncr_proto func_r P_ROTO -> "type_P func_r(type_R, type_O, type_T, type_O);"
checkfuncr_proto_str() {
	cf="$1"
	cP="$2"

	cr=`echo "$cP" | sed -e 's/_.*//'`
	cR=`valueof "type_$cr"`
	test -n "$cR" || die "BAD type letter $cr in $cP"

	ca=`echo "$cP" | sed -e 's/^._//' -e 's/\(.\)/\1 /g'`
	for cp in $ca; do
		cT=`valueof "type_$cp"`
		test -n "$cT" || msg -n "(BAD type letter $cp) "
		test "$cT" = "undef" && msg -n "(UNDEF free type letter $cp) "
		if [ -z "$cA" ]; then
			cA="$cT"
		else
			cA="$cA, $cT"
		fi
	done

	echo "$cR $cf($cA);"
}

checkfuncr asctime_r 'time.h' 'B_SB B_SBI I_SB I_SBI' 'S=const struct tm*'
checkfuncr crypt_r 'sys/types.h stdio.h crypt.h' 'B_CCS B_CCD' 'S=struct crypt_data*' 'D=CRYPTD*'
checkfuncr ctermid_r 'sys/types.h stdio.h' 'B_B'
checkfuncr endpwent_r 'sys/types.h stdio.h pwd.h' 'I_H V_H'
checkfuncr getgrent_r 'sys/types.h stdio.h grp.h' 'I_SBWR I_SBIR S_SBW S_SBI I_SBI I_SBIH' \
	'S=struct group*' 'R=struct group**'
checkfuncr endgrent_r 'sys/types.h stdio.h grp.h' 'I_H V_H'
checkfuncr getgrgid_r 'sys/types.h stdio.h grp.h' 'I_TSBWR I_TSBIR I_TSBI S_TSBI' \
	'T=gid_t' 'S=struct group*' 'R=struct group**'
checkfuncr getgrnam_r 'sys/types.h stdio.h grp.h' 'I_CSBWR I_CSBIR S_CBI I_CSBI S_CSBI' \
	'S=struct group*' 'R=struct group**'
checkfuncr drand48_r 'sys/types.h stdio.h stdlib.h' 'I_ST' 'S=struct drand48_data*' 'T=double*'
checkfuncr endhostent_r 'sys/types.h stdio.h netdb.h' 'I_D V_D' 'D=struct hostent_data*'
checkfuncr endnetent_r 'sys/types.h stdio.h netdb.h' 'I_D V_D' 'D=struct netent_data*'
checkfuncr endprotoent_r 'sys/types.h stdio.h netdb.h' 'I_D V_D' 'D=struct protoent_data*'
checkfuncr endservent_r 'sys/types.h stdio.h netdb.h' 'I_D V_D' 'D=struct servent_data*'
checkfuncr gethostbyaddr_r 'netdb.h' \
	'I_CWISBWRE S_CWISBWIE S_CWISBIE S_TWISBIE S_CIISBIE S_CSBIE S_TSBIE I_CWISD I_CIISD I_CII I_TsISBWRE' \
	'T=const void*' 'S=struct hostent*' 'D=struct hostent_data*' 'R=struct hostent**'
checkfuncr gethostbyname_r 'netdb.h' 'I_CSBWRE S_CSBIE I_CSD' \
	'S=struct hostent*' 'R=struct hostent**' 'D=struct hostent_data*'
checkfuncr gethostent_r 'netdb.h' 'I_SBWRE I_SBIE S_SBIE S_SBI I_SBI I_SD'\
	'S=struct hostent*' 'R=struct hostent**' 'D=struct hostent_data*'
checkfuncr getlogin_r 'unistd.h' 'I_BW I_BI B_BW B_BI'
checkfuncr getnetbyaddr_r 'netdb.h' \
	'I_UISBWRE I_LISBI S_TISBI S_LISBI I_TISD I_LISD I_IISD I_uISBWRE'\
	'T=in_addr_t' 'S=struct netent*' 'D=struct netent_data*' 'R=struct netent**'
checkfuncr getnetbyname_r 'netdb.h' 'I_CSBWRE I_CSBI S_CSBI I_CSD' \
	'S=struct netent*' 'R=struct netent**' 'D=struct netent_data*'
checkfuncr getnetent_r 'netdb.h' 'I_SBWRE I_SBIE S_SBIE S_SBI I_SBI I_SD' \
	'S=struct netent*' 'R=struct netent**' 'D=struct netent_data*'
checkfuncr getprotobyname_r 'netdb.h' 'I_CSBWR S_CSBI I_CSD' \
	'S=struct protoent*' 'R=struct protoent**' 'D=struct protoent_data*'
checkfuncr getprotobynumber_r 'netdb.h' 'I_ISBWR S_ISBI I_ISD' \
	'S=struct protoent*' 'R=struct protoent**' 'D=struct protoent_data*'
checkfuncr getprotoent_r 'netdb.h' 'I_SBWR I_SBI S_SBI I_SD' \
	'S=struct protoent*' 'R=struct protoent**' 'D=struct protoent_data*'
checkfuncr getpwent_r 'pwd.h' 'I_SBWR I_SBIR S_SBW S_SBI I_SBI I_SBIH' \
	'S=struct passwd*' 'R=struct passwd**'
checkfuncr getpwnam_r 'pwd.h' 'I_CSBWR I_CSBIR S_CSBI I_CSBI' \
	'S=struct passwd*' 'R=struct passwd**'
checkfuncr getpwuid_r 'sys/types.h pwd.h' 'I_TSBWR I_TSBIR I_TSBI S_TSBI' \
	 'T=uid_t' 'S=struct passwd*' 'R=struct passwd**'
checkfuncr getservbyname_r 'netdb.h' 'I_CCSBWR S_CCSBI I_CCSD' \
	'S=struct servent*' 'R=struct servent**' 'D=struct servent_data*'
checkfuncr getservbyport_r 'netdb.h' 'I_ICSBWR S_ICSBI I_ICSD' \
	'S=struct servent*' 'R=struct servent**' 'D=struct servent_data*'
checkfuncr getservent_r 'netdb.h' 'I_SBWR I_SBI S_SBI I_SD' \
	'S=struct servent*' 'R=struct servent**' 'D=struct servent_data*'
checkfuncr getspnam_r 'shadow.h' 'I_CSBWR S_CSBI' 'S=struct spwd*' 'R=struct spwd**'
checkfuncr gmtime_r 'time.h' 'S_TS I_TS' 'S=struct tm*' 'T=const time_t*'
checkfuncr localtime_r 'time.h' 'S_TS I_TS' 'S=struct tm*' 'T=const time_t*'
checkfuncr random_r 'stdlib.h' 'I_iS I_lS I_St' 'S=struct random_data*'
checkfuncr readdir64_r 'stdio.h dirent.h' 'I_TSR I_TS' 'T=DIR*' 'S=struct dirent64*' 'R=struct dirent64**'
checkfuncr readdir_r 'stdio.h dirent.h' 'I_TSR I_TS' 'T=DIR*' 'S=struct dirent*' 'R=struct dirent**'
checkfuncr setgrent_r 'grp.h' 'I_SBWR I_SBIR S_SBW S_SBI I_SBI I_SBIH' 'S=struct group*' 'R=struct group**'
checkfuncr sethostent_r 'netdb.h' 'I_ID V_ID' 'D=struct hostent_data*'
checkfuncr setlocale_r 'locale.h' 'I_ICBI'
checkfuncr setnetent_r 'netdb.h' 'I_ID V_ID' 'D=struct netent_data*'
checkfuncr setprotoent_r 'netdb.h' 'I_ID V_ID' 'D=struct protoent_data*'
checkfuncr setpwent_r 'pwd.h' 'I_H V_H'
checkfuncr setservent_r 'netdb.h' 'I_ID V_ID' 'D=struct servent_data*'
checkfuncr srand48_r 'stdlib.h' 'I_LS' 'S=struct drand48_data*'
checkfuncr srandom_r 'stdlib.h' 'I_TS' 'T=unsigned int' 'S=struct random_data*'
checkfuncr strerror_r 'string.h' 'I_IBW I_IBI B_IBW'
checkfuncr tmpnam_r 'stdio.h' 'B_B'
checkfuncr ttyname_r 'stdio.h unistd.h' 'I_IBW I_IBI B_IBI'
