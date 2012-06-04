#!/bin/bash

# Check availability of some types, and possibly their size

# hastype name 'includes'
function hastype {
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
function typesize {
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

	result=`grep foo try.out | sed -e 's/.*: [0-9]\+ \+//' -e 's/ .*//'`
	if [ -z "$result" -o "$result" -le 0 ]; then
		result "unknown"
		fail "Can't determine sizeof($_typename)"
		return 1
	fi

	setvar "${_typename}size" "$result"
	_bytes=`bytes "$result"`
	result "$result $_bytes"
}

check typesize 'char'
check typesize 'short'
check typesize 'int'
check typesize 'long'
check typesize 'double'
check typesize 'long double'
check typesize 'long long'
check typesize 'void*'
check typesize int64_t 'stdint.h'
check typesize int32_t 'stdint.h'
check typesize int16_t 'stdint.h'
check typesize int8_t 'stdint.h'

check typesize 'off_t' sys/types.h
check typesize 'size_t' sys/types.h
check typesize 'ssize_t' sys/types.h
check typesize 'uid_t' sys/types.h
check typesize 'gid_t' sys/types.h
check typesize 'fpos_t' stdio.h sys/types.h
failpoint

check hastype 'time_t' time.h
check hastype 'clock_t' 'sys/times.h'
check hastype 'fd_set' 'sys/types.h' 
check hastype 'fpos64_t' 'stdio.h'
check hastype 'off64_t' 'sys/types.h'
check hastype 'struct cmsghdr' 'netinet/in.h'
check hastype 'struct fs_data' 'sys/vfs.h'
check hastype 'struct msghdr' 'sys/types.h sys/socket.h sys/uio.h'
check hastype 'struct statfs' 'sys/types.h sys/param.h sys/mount.h sys/vfs.h sys/statfs.h'
check hastype 'union semun' 'sys/types.h sys/ipc.h sys/sem.h'
check hastype 'socklen_t' 'sys/types.h sys/socket.h'

check hastype 'bool' 'stdio.h stdbool.h'
