# Tests for libc functions availability.

checkfunc() {
	require 'cc'
	mstart "Checking for $2"
	if not hinted $1 'found' 'missing'; then
		try_start
		try_add '#define _GNU_SOURCE'
		funcincludes "$3" "$4" "$includes"
		try_add "int main(void) { $2($3); return 0; }"
		try_link -O0 -fno-builtin
		resdef $1 'found' 'missing'
	fi
}

funcincludes() {
	case "$1" in
		*NULL*) try_includes "stdlib.h" ;;
	esac

	test -n "$3" && try_includes $3
	test -n "$2" && try_includes $2
}

# The naming scheme looks regular but it isn't!

includes=''
checkfunc d__fwalk '_fwalk'
checkfunc d_accept4 'accept4' "0,NULL,NULL,0" 'sys/socket.h sys/types.h'
checkfunc d_access 'access' "NULL,0" 'unistd.h'
checkfunc d_accessx 'accessx'
checkfunc d_aintl 'aintl'
checkfunc d_alarm 'alarm' "0" 'unistd.h'
checkfunc d_asctime64 'asctime64' "NULL" 'time.h'
checkfunc d_atolf 'atolf'
checkfunc d_atoll 'atoll'
checkfunc d_backtrace 'backtrace' 'NULL, 0' 'execinfo.h'
checkfunc d_bcmp 'bcmp' "NULL,NULL,0" 'string.h'
checkfunc d_bcopy 'bcopy' "NULL,NULL,0" 'string.h'
checkfunc d_bzero 'bzero' "NULL,0" 'string.h'
checkfunc d_chown 'chown' "NULL,0,0" 'unistd.h'
checkfunc d_chroot 'chroot' "NULL" 'unistd.h'
checkfunc d_chsize 'chsize' "0,0"
checkfunc d_class 'class'
checkfunc d_clearenv 'clearenv' "" 'stdlib.h'
checkfunc d_closedir 'closedir' "NULL" 'dirent.h sys/types.h'
checkfunc d_crypt 'crypt' "NULL,NULL" 'crypt.h unistd.h'
checkfunc d_ctermid 'ctermid' "NULL" 'stdio.h'
checkfunc d_ctime64 'ctime64'
checkfunc d_cuserid 'cuserid' "NULL" 'stdio.h'
checkfunc d_difftime 'difftime' "0,0" 'time.h'
checkfunc d_difftime64 'difftime64' "0,0" 'time.h'
checkfunc d_dirfd 'dirfd' "NULL" 'dirent.h sys/types.h'
checkfunc d_dladdr 'dladdr' 'NULL, NULL' 'dlfcn.h'
checkfunc d_dlerror 'dlerror' "" 'dlfcn.h'
checkfunc d_dlopen 'dlopen' "NULL,0" "dlfcn.h"
checkfunc d_drand48 'drand48' "" 'stdlib.h'
checkfunc d_dup2 'dup2' "0,0" 'unistd.h'
checkfunc d_dup3 'dup3' "0,0,0" 'fcntl.h unistd.h'
checkfunc d_duplocale 'duplocale' '0' 'locale.h'
checkfunc d_eaccess 'eaccess' "NULL,0" 'unistd.h'
checkfunc d_endgrent 'endgrent' '' 'grp.h sys/types.h'
checkfunc d_endhent 'endhostent' "" 'netdb.h'
checkfunc d_endnent 'endnetent' "" 'netdb.h'
checkfunc d_endpent 'endprotoent' "" 'netdb.h'
checkfunc d_endpwent 'endpwent' "" 'sys/types.h pwd.h'
checkfunc d_endservent 'endservent' "" 'netdb.h'
checkfunc d_fchdir 'fchdir' "0" 'unistd.h'
checkfunc d_fchmod 'fchmod' "0,0" 'unistd.h sys/stat.h'
checkfunc d_fchmodat 'fchmodat' "0,NULL,0,0" 'unistd.h sys/stat.h'
checkfunc d_fchown 'fchown' "0,0,0" 'unistd.h'
checkfunc d_fcntl 'fcntl' "0,0" 'unistd.h fcntl.h'
checkfunc d_fdclose 'fdclose' "NULL,NULL" 'stdio.h'
checkfunc d_ffs 'ffs' "0" 'strings.h'
checkfunc d_ffsl 'ffsl' "0" 'strings.h'
checkfunc d_fgetpos 'fgetpos' "NULL, 0" 'stdio.h'
checkfunc d_flock 'flock' "0,0" 'sys/file.h'
checkfunc d_fork 'fork' "" 'unistd.h'
checkfunc d_fp_class 'fp_class'
checkfunc d_fpathconf 'fpathconf' "0,0" 'unistd.h'
checkfunc d_freelocale 'freelocale' "0" 'locale.h'
checkfunc d_fseeko 'fseeko' "NULL,0,0" 'stdio.h'
checkfunc d_fsetpos 'fsetpos' "NULL,0" 'stdio.h'
checkfunc d_fstatfs 'fstatfs' "0,NULL" 'sys/vfs.h'
checkfunc d_fstatvfs 'fstatvfs' "0,NULL" 'sys/statvfs.h'
checkfunc d_fsync 'fsync' "0" 'unistd.h'
checkfunc d_ftello 'ftello' "NULL" 'stdio.h'
checkfunc d_futimes 'futimes' '0,0' 'sys/time.h'
checkfunc d_gai_strerror 'gai_strerror' '0' 'sys/types.h sys/socket.h netdb.h'
checkfunc d_getaddrinfo 'getaddrinfo' "NULL,NULL,NULL,NULL" 'sys/types.h sys/socket.h netdb.h'
checkfunc d_get_current_dir_name 'get_current_dir_name' "" 'unistd.h'
checkfunc d_getcwd 'getcwd' 'NULL,0' 'unistd.h'
checkfunc d_getespwnam 'getespwnam'
checkfunc d_getfsstat 'getfsstat' "NULL,0,0" 'sys/types.h sys/mount.h'
checkfunc d_getgrent 'getgrent' "" 'sys/types.h grp.h'
checkfunc d_getgrps 'getgroups' "0,NULL" 'unistd.h'
checkfunc d_gethbyaddr 'gethostbyaddr' "NULL,0,0" 'netdb.h'
checkfunc d_gethbyname 'gethostbyname' "NULL" 'netdb.h'
checkfunc d_getnbyaddr 'getnetbyaddr' '0,0' 'netdb.h'
checkfunc d_getnbyname 'getnetbyname' 'NULL' 'netdb.h'
checkfunc d_gethent 'gethostent' "" 'netdb.h'
checkfunc d_gethname 'gethostname' "NULL,0" 'unistd.h'
checkfunc d_getitimer 'getitimer' "0,NULL" 'sys/time.h'
checkfunc d_getlogin 'getlogin' "" 'unistd.h'
checkfunc d_getmnt 'getmnt' "NULL,NULL,0,0,NULL" 'sys/types.h sys/param.h sys/mount.h'
checkfunc d_getmntent 'getmntent' "NULL" 'stdio.h mntent.h'
checkfunc d_getnameinfo 'getnameinfo' "NULL,0,NULL,0,NULL,0,0" 'sys/socket.h netdb.h'
checkfunc d_getnent 'getnetent' "" 'netdb.h'
checkfunc d_getnetbyaddr 'getnetbyaddr' "0,0" 'netdb.h'
checkfunc d_getnetbyname 'getnetbyname' "NULL" 'netdb.h'
checkfunc d_getpagsz 'getpagesize' "" 'unistd.h'
checkfunc d_getpbyaddr 'getprotobyaddr'
checkfunc d_getpbyname 'getprotobyname' "NULL" 'netdb.h'
checkfunc d_getpbynumber 'getprotobynumber' "0" 'netdb.h'
checkfunc d_getpent 'getprotoent' "" 'netdb.h'
checkfunc d_getpgid 'getpgid' "0" 'unistd.h'
checkfunc d_getpgrp 'getpgrp' "" 'unistd.h'
checkfunc d_getpgrp2 'getpgrp2'
checkfunc d_getppid 'getppid' "" 'unistd.h'
checkfunc d_getprior 'getpriority' "0,0" 'sys/time.h sys/resource.h'
checkfunc d_getprpwnam 'getprpwnam'
checkfunc d_getpwent 'getpwent' "" 'sys/types.h pwd.h'
checkfunc d_getsbyaddr 'getservbyaddr'
checkfunc d_getsbyname 'getservbyname' "NULL,NULL" 'netdb.h'
checkfunc d_getsbyport 'getservbyport' "0,NULL" 'netdb.h'
checkfunc d_getsent 'getservent' "" 'netdb.h'
checkfunc d_setsent 'setservent' "0" 'netdb.h'
checkfunc d_endsent 'endservent' "" 'netdb.h'
checkfunc d_getspnam 'getspnam' "NULL" 'shadow.h'
checkfunc d_gettimeod 'gettimeofday' 'NULL,NULL' 'sys/time.h'
checkfunc d_gmtime64 'gmtime64' "NULL" 'time.h'
checkfunc d_hasmntopt 'hasmntopt' "NULL,NULL" 'stdio.h mntent.h'
checkfunc d_htonl 'htonl' "0" 'stdio.h sys/types.h netinet/in.h arpa/inet.h'
checkfunc d_ilogbl 'ilogbl' "0.0" 'math.h'
checkfunc d_index 'index' "NULL,0" 'string.h strings.h'
checkfunc d_inetaton 'inet_aton' "NULL,NULL" 'sys/socket.h netinet/in.h arpa/inet.h'
checkfunc d_inetntop 'inet_ntop' "0,NULL,NULL,0" 'arpa/inet.h'
checkfunc d_inetpton 'inet_pton' "0,NULL,NULL" 'arpa/inet.h'
checkfunc d_isascii 'isascii' "'A'" 'stdio.h ctype.h'
checkfunc d_isblank 'isblank' "' '" 'stdio.h ctype.h'
checkfunc d_killpg 'killpg' "0,0" 'signal.h'
checkfunc d_lchown 'lchown' "NULL, 0, 0" 'unistd.h'
checkfunc d_link 'link' 'NULL,NULL' 'unistd.h'
checkfunc d_linkat 'linkat' '0,NULL,0,NULL,0' 'unistd.h'
checkfunc d_localtime64 'localtime64' "NULL" 'time.h'
checkfunc d_localeconv_l 'localeconv_l' 'NULL' 'locale.h'
checkfunc d_locconv 'localeconv' "" 'locale.h'
checkfunc d_lockf 'lockf' "0,0,0" 'unistd.h'
checkfunc d_lstat 'lstat' "NULL, NULL" 'sys/stat.h'
checkfunc d_madvise 'madvise' "NULL,0,0" 'sys/mman.h'
checkfunc d_malloc_good_size 'malloc_good_size'
checkfunc d_malloc_size 'malloc_size'
checkfunc d_mblen 'mblen' '"", 0' 'stdlib.h'
checkfunc d_mbstowcs 'mbstowcs' "NULL,NULL,0"
checkfunc d_mbtowc 'mbtowc' 'NULL, NULL, 0' 'stdlib.h'
checkfunc d_mbrlen 'mbrlen' 'NULL, 0, NULL' 'wchar.h'
checkfunc d_mbrtowc 'mbrtowc' 'NULL, NULL, 0, NULL' 'wchar.h'
checkfunc d_memchr 'memchr' "NULL, 0, 0" 'string.h'
checkfunc d_memcmp 'memcmp' "NULL, NULL, 0" 'string.h'
checkfunc d_memcpy 'memcpy' "NULL, NULL, 0" 'string.h'
checkfunc d_memmem 'memmem' "NULL, 0, NULL, 0" 'string.h'
checkfunc d_memmove 'memmove' "NULL, NULL, 0" 'string.h'
checkfunc d_memrchr 'memrchr' "NULL, 0, 0" 'string.h'
checkfunc d_memset 'memset' "NULL, 0, 0" 'string.h'
checkfunc d_mkdir 'mkdir' 'NULL, 0' 'sys/stat.h'
checkfunc d_mkdtemp 'mkdtemp' 'NULL' 'stdlib.h'
checkfunc d_mkfifo 'mkfifo' 'NULL,0' 'sys/types.h sys/stat.h'
checkfunc d_mkostemp 'mkostemp' 'NULL,0' 'stdlib.h'
checkfunc d_mkstemp 'mkstemp' 'NULL' 'stdlib.h'
checkfunc d_mkstemps 'mkstemps' 'NULL,0' 'stdlib.h'
checkfunc d_mktime 'mktime' 'NULL' 'time.h'
checkfunc d_mktime64 'mktime64' 'NULL' 'time.h'
checkfunc d_mmap 'mmap' 'NULL,0,0,0,0,0' 'sys/mman.h'
checkfunc d_mprotect 'mprotect' 'NULL,0,0' 'sys/mman.h'
checkfunc d_msgctl 'msgctl' '0,0,NULL' 'sys/msg.h'
checkfunc d_msgget 'msgget' '0,0' 'sys/msg.h'
checkfunc d_msgrcv 'msgrcv' '0,NULL,0,0,0' 'sys/msg.h'
checkfunc d_msgsnd 'msgsnd' '0,NULL,0,0' 'sys/msg.h'
checkfunc d_msync 'msync' 'NULL,0,0' 'sys/mman.h'
checkfunc d_munmap 'munmap' 'NULL,0' 'sys/mman.h'
checkfunc d_newlocale 'newlocale' '0,NULL,0' 'locale.h'
checkfunc d_nice 'nice' '0' 'unistd.h'
checkfunc d_nl_langinfo 'nl_langinfo' '0' 'langinfo.h'
checkfunc d_nl_langinfo_l 'nl_langinfo_l' '0,0' 'langinfo.h'
checkfunc d_open 'open' "NULL,0,0" 'sys/types.h sys/stat.h fcntl.h'
checkfunc d_openat 'openat' "0,NULL,0,0" 'sys/types.h sys/stat.h fcntl.h'
checkfunc d_pathconf 'pathconf' 'NULL,0' 'unistd.h'
checkfunc d_pause 'pause' '' 'unistd.h'
checkfunc d_pipe 'pipe' 'NULL' 'fcntl.h unistd.h'
checkfunc d_pipe2 'pipe' 'NULL,0' 'fcntl.h unistd.h'
checkfunc d_poll 'poll' 'NULL,0,0' 'poll.h'
checkfunc d_prctl 'prctl' '0,0,0,0,0' 'sys/prctl.h'
checkfunc d_pthread_atfork 'pthread_atfork' 'NULL,NULL,NULL' 'pthread.h'
checkfunc d_pthread_attr_setscope 'pthread_attr_setscope' 'NULL,0' 'pthread.h'
checkfunc d_pthread_yield 'pthread_yield' '' 'pthread.h'
checkfunc d_querylocale 'querylocale' '0,NULL' 'locale.h'
checkfunc d_qgcvt 'qgcvt' '1.0,1,NULL'
checkfunc d_rand 'rand' '' 'stdlib.h'
checkfunc d_random 'random' '' 'stdlib.h'
checkfunc d_re_comp 're_comp' 'NULL' 'sys/types.h regex.h'
checkfunc d_readdir 'readdir' 'NULL' 'dirent.h'
checkfunc d_readlink 'readlink' 'NULL,NULL,0' 'unistd.h'
checkfunc d_realpath 'realpath' 'NULL,NULL' 'limits.h stdlib.h'
checkfunc d_readv 'readv' '0,NULL,0' 'sys/uio.h'
checkfunc d_recvmsg 'recvmsg' '0,NULL,0' 'sys/socket.h'
checkfunc d_regcmp 'regcmp'
checkfunc d_regcomp 'regcomp' 'NULL,NULL,0' 'regex.h'
checkfunc d_rename 'rename' 'NULL,NULL' 'stdio.h'
checkfunc d_renameat 'renameat' '0,NULL,0,NULL' 'fcntl.h stdio.h'
checkfunc d_rewinddir 'rewinddir' 'NULL' 'sys/types.h dirent.h'
checkfunc d_rmdir 'rmdir' 'NULL' 'unistd.h'
checkfunc d_sched_yield 'sched_yield' '' 'sched.h'
checkfunc d_seekdir 'seekdir' 'NULL,0' 'dirent.h'
checkfunc d_select 'select' '0,NULL,NULL,NULL,NULL' 'sys/select.h'
checkfunc d_semctl 'semctl' '0,0,0, NULL' 'sys/sem.h'
checkfunc d_semget 'semget' '0,0,0' 'sys/sem.h'
checkfunc d_semop 'semop' '0,NULL,0' 'sys/sem.h'
checkfunc d_sendmsg 'sendmsg' '0,NULL,0' 'sys/socket.h'
checkfunc d_setegid 'setegid' '0' 'unistd.h'
checkfunc d_setent 'setservent' '0' 'netdb.h'
checkfunc d_setenv 'setenv' 'NULL,NULL,0'
checkfunc d_seteuid 'seteuid' '0' 'unistd.h'
checkfunc d_setgrent 'setgrent' '' 'sys/types.h grp.h'
checkfunc d_setgrps 'setgroups' '0,NULL' 'unistd.h grp.h'
checkfunc d_sethent 'sethostent' '0' 'netdb.h'
checkfunc d_setitimer 'setitimer' '0,NULL,NULL' 'sys/time.h'
checkfunc d_setlinebuf 'setlinebuf' 'NULL' 'stdio.h'
checkfunc d_setlocale 'setlocale' "0,NULL" 'locale.h'
checkfunc d_setnent 'setnetent' '0' 'netdb.h'
checkfunc d_setpent 'setprotoent' '0' 'netdb.h'
checkfunc d_setpgid 'setpgid' '0,0' 'unistd.h'
checkfunc d_setpgrp 'setpgrp' '' 'unistd.h'
checkfunc d_setpgrp2 'setpgrp2'
checkfunc d_setprior 'setpriority' '0,0,0' 'sys/resource.h'
checkfunc d_setproctitle 'setproctitle' 'NULL,NULL' 'sys/types.h unistd.h'
checkfunc d_setpwent 'setpwent' '' 'sys/types.h pwd.h'
checkfunc d_setregid 'setregid' '0,0' 'unistd.h'
checkfunc d_setresgid 'setresgid' '0,0,0' 'unistd.h'
checkfunc d_setresuid 'setresuid' '0,0,0' 'unistd.h'
checkfunc d_setreuid 'setreuid' '0,0' 'unistd.h'
checkfunc d_setrgid 'setrgid' ''
checkfunc d_setruid 'setruid'
checkfunc d_setsid 'setsid' '' 'unistd.h'
checkfunc d_setvbuf 'setvbuf' 'NULL,NULL,0,0' 'stdio.h'
checkfunc d_sfreserve 'sfreserve' "" 'sfio.h'
checkfunc d_shmat 'shmat' '0,NULL,0' 'sys/shm.h'
checkfunc d_shmctl 'shmctl' '0,0,NULL' 'sys/shm.h'
checkfunc d_shmdt 'shmdt' 'NULL' 'sys/shm.h'
checkfunc d_shmget 'shmget' '0,0,0' 'sys/shm.h'
checkfunc d_sigaction 'sigaction' '0,NULL,NULL' 'signal.h'
checkfunc d_sigprocmask 'sigprocmask' '0,NULL,NULL' 'signal.h'
checkfunc d_sigsetjmp 'sigsetjmp' "NULL,0" 'setjmp.h'
checkfunc d_snprintf 'snprintf' 'NULL,0,NULL' 'stdio.h'
checkfunc d_sockatmark 'sockatmark' '0' 'sys/socket.h'
checkfunc d_socket 'socket' "0,0,0" 'sys/types.h sys/socket.h'
checkfunc d_sockpair 'socketpair' '0,0,0,NULL' 'sys/socket.h'
checkfunc d_socks5_init 'socks5_init'
checkfunc d_stat 'stat' 'NULL,NULL' 'sys/stat.h'
checkfunc d_statvfs 'statvfs' 'NULL,NULL' 'sys/statvfs.h'
checkfunc d_strchr 'strchr' "NULL,0" 'string.h strings.h'
checkfunc d_strcoll 'strcoll' "NULL,NULL" 'string.h'
checkfunc d_strerror 'strerror' "0" 'string.h stdlib.h'
checkfunc d_strerror_l 'strerror_l' '0,NULL' 'string.h'
checkfunc d_strftime 'strftime' "NULL,0,NULL,NULL" 'time.h'
checkfunc d_strlcat 'strlcat' 'NULL,NULL,0' 'string.h'
checkfunc d_strlcpy 'strlcpy' 'NULL,NULL,0' 'string.h'
checkfunc d_strnlen 'strnlen' '"",0' 'string.h'
checkfunc d_strtod 'strtod' 'NULL,NULL' 'stdlib.h'
checkfunc d_strtod_l 'strtod_l' 'NULL,NULL,NULL' 'stdlib.h'
checkfunc d_strtol 'strtol' 'NULL,NULL,0' 'stdlib.h'
checkfunc d_strtold 'strtold' 'NULL,NULL' 'stdlib.h'
checkfunc d_strtold_l 'strtold_l' 'NULL,NULL,NULL' 'stdlib.h'
checkfunc d_strtoll 'strtoll' 'NULL,NULL,0'
checkfunc d_strtoq 'strtoq' 'NULL,NULL,0'
checkfunc d_strtoul 'strtoul' 'NULL,NULL,0'
checkfunc d_strtoull 'strtoull' 'NULL,NULL,0'
checkfunc d_strtouq 'strtouq' 'NULL,NULL,0'
checkfunc d_strxfrm 'strxfrm' 'NULL,NULL,0' 'string.h'
checkfunc d_strxfrm_l 'strxfrm_l' 'NULL,NULL,0,NULL' 'string.h'
checkfunc d_symlink 'symlink' 'NULL,NULL' 'unistd.h'
checkfunc d_syscall 'syscall' '0,NULL' 'sys/syscall.h unistd.h'
checkfunc d_sysconf 'sysconf' '0' 'unistd.h'
checkfunc d_system 'system' 'NULL' 'stdlib.h'
checkfunc d_tcgetpgrp 'tcgetpgrp' '0' 'unistd.h'
checkfunc d_tcsetpgrp 'tcsetpgrp' '0,0' 'unistd.h'
checkfunc d_telldir 'telldir' 'NULL' 'dirent.h'
checkfunc d_time 'time' 'NULL' 'time.h'
checkfunc d_timegm 'timegm' 'NULL' 'time.h'
checkfunc d_times 'times' 'NULL' 'sys/times.h'
checkfunc d_towlower 'towlower' '0' 'wctype.h'
checkfunc d_towupper 'towupper' '0' 'wctype.h'
checkfunc d_truncate 'truncate' 'NULL,0' 'unistd.h'
checkfunc d_ualarm 'ualarm' 'NULL,NULL' 'unistd.h'
checkfunc d_umask 'umask' '0' 'sys/stat.h'
checkfunc d_uname 'uname' 'NULL' 'sys/utsname.h'
checkfunc d_unlinkat 'unlinkat' '0,NULL,0' 'unistd.h fcntl.h'
checkfunc d_unordered 'unordered'
checkfunc d_unsetenv 'unsetenv' 'NULL'
checkfunc d_uselocale 'uselocale' '0' 'locale.h'
checkfunc d_usleep 'usleep' '0' 'unistd.h'
checkfunc d_ustat 'ustat' '0,NULL' 'sys/types.h unistd.h'
define d_vfork 'undef' # unnecessary
checkfunc d_vprintf 'vprintf' 'NULL,0' 'stdio.h'
checkfunc d_vsnprintf 'vsnprintf' 'NULL,0,NULL,NULL' 'stdio.h'
checkfunc d_wait4 'wait4' '0,NULL,0,NULL' 'sys/wait.h'
checkfunc d_waitpid 'waitpid' '0,NULL,0' 'sys/wait.h'
checkfunc d_wcrtomb 'wcrtomb' 'NULL,0,NULL' 'wchar.h'
checkfunc d_wcscmp 'wcscmp' 'NULL,NULL' 'wchar.h'
checkfunc d_wcstombs 'wcstombs' 'NULL,NULL,0' 'wchar.h'
checkfunc d_wcsxfrm 'wcsxfrm' 'NULL,NULL,0' 'wchar.h'
checkfunc d_wctomb 'wctomb' 'NULL,NULL' 'wchar.h'
checkfunc d_writev 'writev' '0,NULL,0' 'sys/uio.h'
unset includes
