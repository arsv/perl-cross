# Prototype checks. We supply a clearly bogus prototype,
# and check whether the compiler throws an error.

# It's probably safe to assume declared prototypes in all cases,
# systems with K&R compilers are not likely to run perl-cross.

hasproto() {
	mstart "Checking $2 prototype"
	if not hinted "$1" 'declared' 'missing'; then
		try_start
		try_add '#define _GNU_SOURCE'
		try_includes $3
		try_add 'struct foo;'
		try_add "void* $2(struct foo* ptr);"
		not try_compile
		resdef $1 'declared' 'missing'
	fi
}

hasproto d_dbminitproto 'dbminit' 'gdbm.h' # XXX
hasproto d_drand48proto 'drand48' 'stdlib.h'
hasproto d_flockproto 'flock' 'sys/file.h'
hasproto d_lseekproto 'lseek' 'sys/types.h unistd.h'
hasproto d_modflproto 'modfl' 'math.h'
hasproto d_sbrkproto 'sbrk' 'unistd.h'
hasproto d_sockatmarkproto 'sockatmark' 'sys/socket.h'
hasproto d_sresgproto 'setresgid' 'unistd.h'
hasproto d_sresuproto 'setresuid' 'unistd.h'
hasproto d_syscallproto 'syscall' 'unistd.h sys/syscall.h'
hasproto d_telldirproto 'telldir' 'dirent.h'
hasproto d_usleepproto 'usleep' 'unistd.h'

hasproto d_gethostprotos 'gethostbyaddr' 'netdb.h sys/socket.h'
hasproto d_getservprotos 'getservbyport' 'netdb.h sys/socket.h'
hasproto d_getnetprotos 'getnetbyaddr' 'netdb.h'
hasproto d_getprotoprotos 'getprotobynumber' 'netdb.h'
