#!/bin/bash

# hasfield name struct field 'includes'
function hasfield {
	mstart "Checking whether $2 has $3"
	ifhintdefined "$1" 'yes' 'no' && return 0
	
	try_start
	try_includes $4
	try_add 'void foo();'
	try_add 'void bar()'
        try_add "{"
	try_add "	$2 value;"
	try_add "	foo(value.$3);"
	try_add "}"
	if try_compile; then
		setvar "$1" "define"
		result "yes"
		return 0
	else
		setvar "$1" "undef"
		result 'no'
		return 1
	fi
}

check hasfield d_statfs_f_flags 'struct statfs' f_flags sys/vfs.h
check hasfield d_tm_tm_zone 'struct tm' tm_zone time.h
check hasfield d_tm_tm_gmtoff 'struct tm' tm_gmtoff time.h
check hasfield d_pwquota 'struct passwd' pw_quota pwd.h
check hasfield d_pwage 'struct passwd' pw_age pwd.h
check hasfield d_pwchange 'struct passwd' pw_change pwd.h
check hasfield d_pwclass 'struct passwd' pw_class pwd.h
check hasfield d_pwexpire 'struct passwd' pw_expire pwd.h
check hasfield d_pwcomment 'struct passwd' pw_comment pwd.h
check hasfield d_pwgecos 'struct passwd' pw_gecos pwd.h
check hasfield d_pwpasswd 'struct passwd' pw_passwd pwd.h
check hasfield d_statblks 'struct stat' st_blocks 'sys/types.h sys/stat.h'
check hasfield d_dirnamlen 'struct dirent' d_namelen 'sys/types.h'
check hasfield d_grpasswd 'struct group' gr_passwd grp.h
check hasfield d_sockaddr_sa_len 'struct sockaddr' sa_len 'sys/types.h sys/socket.h'
check hasfield d_sin6_scope_id 'struct sockaddr_in6' sin6_scope_id 'sys/types.h sys/socket.h netinet/in.h'
