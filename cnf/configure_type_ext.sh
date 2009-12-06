#!/bin/sh

# hasdef name 'includes'
function hasdef {
	_defname=`symbolname "$1"`
	mstart "Checking whether $1 is defined"
	ifhintdefined "d_${_defname}" 'yes' 'no' && return 0
	
	try_start
	try_includes $2
	try_add "#ifndef $1"
	try_add "#error $1 undefined"
	try_add "#endif"
	if try_compile; then
		setvar "d_${_defname}" "define"
		result "yes"
		return 0
	else
		setvar "d_${_defname}" "undef"
		result 'no'
		return 1
	fi
}

# hasfield name field 'includes'
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

check hasdef DBL_DIG 'float.h limits.h'
check hasdef LDBL_DIG 'float.h limits.h'

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
