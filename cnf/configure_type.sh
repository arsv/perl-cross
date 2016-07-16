# Check availability of some types, and possibly their size

# checktype name 'includes'
checktype() {
	_typename=`symbolname "$1"`
	
	mstart "Checking type $1"
	ifhintdefined "d_${_typename}" 'found' 'missing' && return 0

	try_start
	try_includes $2
	try_add "$1 foo;"
	if not try_compile; then
		result 'missing'
		return 1
	fi

	setvar "d_${_typename}" "define"
	result "found"
}

# XXX: this probably won't work on non-ELF hosts.
# TODO: add test for readelf usability, and switch
# to objdump if possible

# typesize name 'includes'
typesize() {
	_typename=`symbolname "$1"`

	mstart "Checking size of $1"
	ifhintsilent "d_${_typename}" && ifhint "${_typename}size" && return 0
	
	# Test d_type and typesize separately; this allows hinting typesize
	# even for types that may be unavailable
	try_start
	try_includes $2
	try_add "$1 foo;"
	if not try_compile; then
		result 'missing'
		return 1
	fi
	setvar "d_${_typename}" "define"

	# Avoid running fragile typesize test unless really necessary
	ifhint "${_typename}size" && return 0

	if not try_readelf -s > try.out 2>>$cfglog; then
		result 'unknown'
		fail "Can't determine sizeof($_typename), use -D{$_typename}size="
		return 1
	fi

	result=`grep foo try.out | sed -r -e 's/.*: [0-9]+ +//' -e 's/ .*//'`
	if [ -z "$result" -o "$result" -le 0 ]; then
		result "unknown"
		fail "Can't determine sizeof($_typename)"
		return 1
	fi

	setvar "${_typename}size" "$result"
	_bytes=`bytes "$result"`
	result "$result $_bytes"
}

typesize 'char'
typesize 'short'
typesize 'int'
typesize 'long'
typesize 'double'
typesize 'long double'
typesize 'long long'
typesize 'void*'
typesize int64_t 'stdint.h'
typesize int32_t 'stdint.h'
typesize int16_t 'stdint.h'
typesize int8_t 'stdint.h'

typesize 'off_t' sys/types.h
typesize 'size_t' sys/types.h
typesize 'ssize_t' sys/types.h
typesize 'uid_t' sys/types.h
typesize 'gid_t' sys/types.h
typesize 'fpos_t' stdio.h sys/types.h
failpoint

checktype 'time_t' time.h
checktype 'clock_t' 'sys/times.h'
checktype 'fd_set' 'sys/types.h' 
checktype 'fpos64_t' 'stdio.h'
checktype 'off64_t' 'sys/types.h'
checktype 'ptrdiff_t' 'stddef.h'
checktype 'struct cmsghdr' 'netinet/in.h'
checktype 'struct fs_data' 'sys/vfs.h'
checktype 'struct msghdr' 'sys/types.h sys/socket.h sys/uio.h'
checktype 'struct statfs' 'sys/types.h sys/param.h sys/mount.h sys/vfs.h sys/statfs.h'
checktype 'union semun' 'sys/types.h sys/ipc.h sys/sem.h'
checktype 'socklen_t' 'sys/types.h sys/socket.h'

# These checks are simplified compared to what Configure does.
checktype 'ip_mreq' 'sys/types.h sys/socket.h netinet/in.h'
checktype 'ip_mreq_source' 'sys/types.h sys/socket.h netinet/in.h'
checktype 'ipv6_mreq' 'sys/types.h sys/socket.h netinet/in.h'
checktype 'ipv6_mreq_source' 'sys/types.h sys/socket.h netinet/in.h'

checktype 'bool' 'stdio.h stdbool.h'
