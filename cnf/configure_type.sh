# Check availability of some types, and possibly their size

# useinttype namesym type sizesym size
useitype() {
	setvar $1 "$2"
	setvar $3 "$4"
}

# checktype symbol type 'includes'
checktype() {
	mstart "Checking type $2"
	ifhintdefined $1 'found' 'missing' && return 0

	try_start
	try_includes $3
	try_add "$2 foo;"
	if not try_compile; then
		result 'missing'
		return 1
	fi

	setvar $1 "define"
	result "found"
}

# XXX: this probably won't work on non-ELF hosts.
# TODO: add test for readelf usability, and switch
# to objdump if possible

# checksize symbol type includes
checksize() {
	mstart "Checking size of $2"
	ifhint $1 && return 0
	
	try_start
	try_includes $3
	try_add "$2 foo;"
	if not try_compile; then
		result 'missing'
		return 1
	fi

	if not try_readelf -s > try.out 2>>$cfglog; then
		result 'unknown'
		fail "Cannot determine sizeof($2), use -D${1}size="
		return 1
	fi

	result=`grep foo try.out | sed -r -e 's/.*: [0-9]+ +//' -e 's/ .*//'`
	if [ -z "$result" -o "$result" -le 0 ]; then
		result "unknown"
		fail "Cannot determine sizeof($2)"
		return 1
	fi

	setvar $1 "$result"
	result $result\ `bytes $result`
}

# usetypesize typesym sizesym type 'includes'
usetypesize() {
	mstart "Checking $1"
	if nothinted $1; then
		result "$3"
		setvar $1 $3
		checksize $2 $3 "$4"
	else
		checksize $2 "`valueof $1`" "$4"
	fi
}

# Mainline perl Configure implements/-ed a kind of crude stdint.h
# replacement in case the header is not available. No point in hinting
# any of these either.

test "$i_stdint" = 'define' || fail "Cannot proceed without <stdint.h>"

useitype  u8type  uint8_t  u8size 1
useitype u16type uint16_t u16size 2
useitype u32type uint32_t u32size 4
useitype u64type uint64_t u64size 8

useitype  i8type  int8_t  i8size 1
useitype i16type int16_t i16size 2
useitype i32type int32_t i32size 4
useitype i64type int64_t i64size 8

setvar d_quad define
setvar quadtype int64_t
setvar uquadtype uint64_t
setvar quadkind QUAD_IS_INT64_t

checktype d_longdbl 'long double'
checktype d_longlong 'long long'

checksize charsize 'char'
checksize shortsize 'short'
checksize intsize 'int'
checksize longsize 'long'
checksize doublesize 'double'
checksize ptrsize 'void*'
test "$d_longdbl" == 'define'  && checksize longdblsize 'long double'
test "$d_longlong" == 'define' && checksize longlongsize 'long long'

checktype d_fd_set 'fd_set' 'sys/types.h'
checktype d_fpos64_t 'fpos64_t' 'stdio.h'
checktype d_off64_t 'off64_t' 'sys/types.h'
checktype d_ptrdiff_t 'ptrdiff_t' 'stddef.h'
checktype d_cmsghdr_s 'struct cmsghdr' 'netinet/in.h'
checktype d_fs_data_s 'struct fs_data' 'sys/vfs.h'
checktype d_msghdr_s 'struct msghdr' 'sys/types.h sys/socket.h sys/uio.h'
checktype d_statfs_s 'struct statfs' \
	'sys/types.h sys/param.h sys/mount.h sys/vfs.h sys/statfs.h'
checktype d_union_semun 'union semun' 'sys/types.h sys/ipc.h sys/sem.h'
checktype d_socklen_t 'socklen_t' 'sys/types.h sys/socket.h'
checktype d_sockaddr_in6 'struct sockaddr_in6' 'sys/socket.h netinet/in.h'

# These checks are simplified compared to what Configure does.
checktype d_ip_mreq 'struct ip_mreq' \
	'sys/types.h sys/socket.h netinet/in.h'
checktype d_ip_mreq_source 'struct ip_mreq_source' \
	'sys/types.h sys/socket.h netinet/in.h'
checktype d_ipv6_mreq 'struct ipv6_mreq' \
	'sys/types.h sys/socket.h netinet/in.h'

# For these mainline perl does some guessing like int64_t instead
# of possibly missing off_t, but we won't do that.
# We do still need to check type sizes.

usetypesize sizetype sizesize 'size_t' 'sys/types.h'
usetypesize fpostype fpossize 'fpos_t' 'stdio.h sys/types.h'
usetypesize lseektype lseeksize 'off_t' 'unistd.h'
usetypesize uidtype uidsize 'uid_t' 'sys/types.h'
usetypesize gidtype gidsize 'gid_t' 'sys/types.h'
usetypesize timetype timesize 'time_t' 'sys/types.h'
setvar ssizetype 'ssize_t'
setvar uidsign '1'
