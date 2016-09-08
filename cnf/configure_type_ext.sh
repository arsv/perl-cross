# Check whether structure X has field Y.

# checkfield name struct field 'includes'
checkfield() {
	mstart "Checking whether $2 has $3"
	hinted "$1" && return # XXX reshint
	
	try_start
	try_includes $4
	try_add 'void foo();'
	try_add 'void bar()'
        try_add "{"
	try_add "	$2 value;"
	try_add "	foo(value.$3);"
	try_add "}"
	try_compile

	resdef $1 'yes' 'no'
}

checkfield d_statfs_f_flags 'struct statfs' f_flags sys/vfs.h
checkfield d_tm_tm_zone 'struct tm' tm_zone time.h
checkfield d_tm_tm_gmtoff 'struct tm' tm_gmtoff time.h
checkfield d_pwquota 'struct passwd' pw_quota pwd.h
checkfield d_pwage 'struct passwd' pw_age pwd.h
checkfield d_pwchange 'struct passwd' pw_change pwd.h
checkfield d_pwclass 'struct passwd' pw_class pwd.h
checkfield d_pwexpire 'struct passwd' pw_expire pwd.h
checkfield d_pwcomment 'struct passwd' pw_comment pwd.h
checkfield d_pwgecos 'struct passwd' pw_gecos pwd.h
checkfield d_pwpasswd 'struct passwd' pw_passwd pwd.h
checkfield d_statblks 'struct stat' st_blocks 'sys/types.h sys/stat.h'
checkfield d_dirnamlen 'struct dirent' d_namelen 'sys/types.h'
checkfield d_grpasswd 'struct group' gr_passwd grp.h
checkfield d_sockaddr_sa_len 'struct sockaddr' sa_len 'sys/types.h sys/socket.h'
checkfield d_sin6_scope_id 'struct sockaddr_in6' sin6_scope_id 'sys/types.h sys/socket.h netinet/in.h'

checkfield d_siginfo_si_errno 'siginfo_t' si_errno 'signal.h'
checkfield d_siginfo_si_pid 'siginfo_t' si_pid 'signal.h'
checkfield d_siginfo_si_uid 'siginfo_t' si_uid 'signal.h'
checkfield d_siginfo_si_addr 'siginfo_t' si_addr 'signal.h'
checkfield d_siginfo_si_band 'siginfo_t' si_band 'signal.h'
checkfield d_siginfo_si_value 'siginfo_t' si_value 'signal.h'
checkfield d_siginfo_si_fd 'siginfo_t' si_fd 'signal.h'
checkfield d_siginfo_si_addr 'siginfo_t' si_addr 'signal.h'
checkfield d_siginfo_si_status 'siginfo_t' si_status 'signal.h'
checkfield d_siginfo_si_band 'siginfo_t' si_band 'signal.h'
