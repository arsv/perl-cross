#!/bin/bash

# hasfunc name args includes
# WARNING: some compilers do have built-in notions on how certain
# function should be called, and will produce errors if those functions
# are called in a "wrong" way. 
# So far looks like the safest option is to provide type-compatible arguments,
# i.e., "0" for ints, "NULL" for pointers etc.
function hasfunc {
	if [ -n "$4" ] ; then _s="$4"; else _s="d_$1"; fi

	require 'cc'
	mstart "Checking for $1"
	ifhintdefined "$_s" 'present' 'missing' && return $__

	try_start
	try_includes $3
	case "$2" in
		*NULL*) case "$3" in
			*stdlib.h*) ;;
			*) try_includes "stdlib.h"
		esac ;;
	esac
	try_add "int main(void) { $1($2); return 0; }"
	try_link
	resdef 'found' 'not found' "$_s"
}

# hasvar name includes [symbol]
# We use try_link here instead of try_compile to be sure we have the
# variable in question not only declared but also present in libraries we use.
function hasvar {
	if [ -n "$4" ] ; then _s="$4"; else _s="d_$1"; fi

	require 'cc'
	mstart "Checking for $1"
	ifhintdefined "$_s" 'present' 'missing' && return $__

	try_start
	try_includes $2
	try_add "void foo() { };"
	try_add "int main() { foo($1); return 0; }"
	try_link
	resdef 'found' 'not found' "$_s"
}

function isvoid {
	require 'cc'
	mstart "Checking whether $1 is void"
	ifhint "d_$1" && return

	try_start
	try_includes $3
	try_add "int main() { return $1($2); }"
	not try_compile
	resdef 'yes' 'no' "d_void_$1"
}

check hasfunc _fwalk
check hasfunc access "NULL,0" 'stdlib.h unistd.h'
check hasfunc accessx
check hasfunc aintl
check hasfunc alarm "0" 'unistd.h'
check hasfunc asctime64
check hasfunc atolf
check hasfunc atoll
check hasfunc bcmp "NULL,NULL,0" 'stdlib.h string.h'
check hasfunc bcopy "NULL,NULL,0" 'stdlib.h string.h'
check hasfunc bzero "NULL,0" 'stdlib.h string.h'
check hasfunc chown "NULL,0,0" 'stdlib.h unistd.h'
check hasfunc chroot "NULL" 'unistd.h'
check hasfunc chsize "0,0"
check hasfunc class
check hasfunc clearenv "" 'stdlib.h'
check hasfunc closedir "NULL" 'stdlib.h'
check hasfunc copysignl "0.0,0.0" 'math.h'
check hasfunc crypt
check hasfunc ctermid
check hasfunc ctime64
check hasfunc cuserid
check hasfunc difftime "0,0"
check hasfunc difftime64
check hasfunc dirfd
check hasfunc dlopen
check hasfunc dlerror
check hasfunc drand48
check hasfunc dup2 "0,0"
check hasfunc eaccess
check hasfunc endgrent
check hasfunc endhostent
check hasfunc endnetent
check hasfunc endprotoent
check hasfunc endpwent
check hasfunc endservent
check hasfunc fchdir "0" 'unistd.h'
check hasfunc fchmod "0,0" 'unistd.h'
check hasfunc fchown "0,0,0" 'unistd.h'
check hasfunc fcntl "0,0" 'unistd.h fcntl.h'
check hasfunc fgetpos "NULL, 0" 'stdlib.h stdio.h'
check hasfunc finite "0.0" 'math.h'
check hasfunc finitel "0.0" 'math.h'
check hasfunc flock "0,0" 'unistd.h sys/file.h'
check hasfunc fork "" 'unistd.h'
check hasfunc fp_class
check hasfunc fpathconf "0,0" 'unistd.h'
check hasfunc fpclass
check hasfunc fpclassify
check hasfunc fpclassl
check hasfunc frexpl '0,NULL' 'stdlib.h math.h'
check hasfunc fseeko 'NULL,0,0'
check hasfunc fsetpos 'NULL,0'
check hasfunc fstatfs
check hasfunc fstatvfs
check hasfunc fsync
check hasfunc ftello
check hasfunc futimes
check hasfunc getaddrinfo
check hasfunc getcwd 'NULL,0'
check hasfunc getespwnam
check hasfunc getfsstat
check hasfunc getgrent
check hasfunc getgroups
check hasfunc gethostbyaddr
check hasfunc gethostbyname
check hasfunc gethostent
check hasfunc gethostname
check hasfunc getitimer
check hasfunc getlogin
check hasfunc getmnt
check hasfunc getmntent
check hasfunc getnameinfo
check hasfunc getnetbyaddr
check hasfunc getnetbyname
check hasfunc getnetent
check hasfunc getpagesize
check hasfunc getpgid
check hasfunc getpgrp "" 'unistd.h'
check hasfunc getpgrp2
check hasfunc getppid
check hasfunc getpriority "0,0" 'sys/time.h sys/resource.h'
check hasfunc getprotobyaddr
check hasfunc getprotobyname
check hasfunc getprotobynumber
check hasfunc getprotoent
check hasfunc getprpwnam
check hasfunc getpwent
check hasfunc getservbyaddr
check hasfunc getservbyname
check hasfunc getservbyport
check hasfunc getservent
check hasfunc getspnam
check hasfunc gettimeofday 'NULL,NULL'
check hasfunc gmtime64
check hasfunc hasmntopt
check hasfunc htonl "0" 'stdio.h sys/types.h netinet/in.h arpa/inet.h'
check hasfunc ilogbl
check hasfunc index "NULL,0" 'stdlib.h string.h strings.h'
check hasfunc inet_aton
check hasfunc inetntop
check hasfunc inetpton
check hasfunc isascii "'A'" 'stdio.h stdlib.h ctype.h'
check hasfunc isblank "' '" 'stdio.h stdlib.h ctype.h'
check hasfunc isfinite "0.0" 'math.h'
check hasfunc isinf "0.0" 'math.h'
check hasfunc isnan "0.0" 'math.h'
check hasfunc isnanl "0.0" 'math.h'
check hasfunc killpg
check hasfunc lchown "NULL, 0, 0" 'stdlib.h unistd.h'
check hasfunc link 'NULL,NULL' 'stdlib.h'
check hasfunc localeconv
check hasfunc localtime64
check hasfunc lockf
check hasfunc lstat
check hasfunc madvise
check hasfunc malloc_good_size
check hasfunc malloc_size
check hasfunc mblen
check hasfunc mbstowcs
check hasfunc mbtowc
check hasfunc memchr "NULL, 0, 0" 'stdlib.h string.h'
check hasfunc memcmp "NULL, NULL, 0" 'stdlib.h string.h'
check hasfunc memcpy "NULL, NULL, 0" 'stdlib.h string.h'
check hasfunc memmove "NULL, NULL, 0" 'stdlib.h string.h'
check hasfunc memset "NULL, 0, 0" 'stdlib.h string.h'
check hasfunc mkdir 'NULL, 0' 'stdlib.h'
check hasfunc mkdtemp
check hasfunc mkfifo
check hasfunc mkstemp 'NULL' 'stdlib.h'
check hasfunc mkstemps
check hasfunc mktime 'NULL' 'stdlib.h'
check hasfunc mktime64
check hasfunc mmap
check hasfunc modfl "0.0,NULL" 'stdlib.h math.h'
check hasfunc mprotect
check hasfunc msgctl
check hasfunc msgget
check hasfunc msgrcv
check hasfunc msgsnd
check hasfunc msync
check hasfunc munmap
check hasfunc nice '0'
check hasfunc nl_langinfo
check hasfunc open "NULL,0,0" 'stdlib.h sys/types.h sys/stat.h fcntl.h' d_open3
check hasfunc pathconf
check hasfunc pause
check hasfunc pipe 'NULL'
check hasfunc poll
check hasfunc pthread_atfork
check hasfunc pthread_attr_setscope
check hasfunc pthread_yield
check hasfunc prctl
check hasfunc rand
check hasfunc random
check hasfunc readdir 'NULL'
check hasfunc readlink
check hasfunc readv
check hasfunc recvmsg
check hasfunc rename 'NULL,NULL'
check hasfunc rewinddir
check hasfunc rmdir 'NULL'
check hasfunc scalbnl "0.0,0" 'math.h'
check hasfunc sched_yield
check hasfunc seekdir
check hasfunc select '0,NULL,NULL,NULL,NULL'
check hasfunc semctl
check hasfunc semget
check hasfunc semop
check hasfunc sendmsg
check hasfunc setegid
check hasfunc seteuid
check hasfunc setgrent
check hasfunc setgroups
check hasfunc sethostent
check hasfunc setitimer
check hasfunc setlinebuf
check hasfunc setlocale "0,NULL" 'stdlib.h locale.h'
check hasfunc setnetent
check hasfunc setpgid
check hasfunc setpgrp
check hasfunc setpgrp2
check hasfunc setpriority
check hasfunc setproctitle
check hasfunc setprotoent
check hasfunc setpwent
check hasfunc setregid
check hasfunc setresgid
check hasfunc setresuid
check hasfunc setreuid
check hasfunc setrgid
check hasfunc setruid
check hasfunc setservent
check hasfunc setsid
check hasfunc setvbuf 'NULL,NULL,0,0'
check hasfunc sfreserve "" 'sfio.h'
check hasfunc shmat
check hasfunc shmctl
check hasfunc shmdt
check hasfunc shmget
check hasfunc sigaction
check hasfunc signbit '.0' 'math.h'
check hasfunc sigprocmask
check hasfunc sigsetjmp "NULL,0" 'stdlib.h setjmp.h'
check hasfunc snprintf
check hasfunc sockatmark
check hasfunc socket "0,0,0" 'sys/types.h sys/socket.h'
check hasfunc socketpair
check hasfunc socks5_init
check hasfunc sqrtl "0.0" 'math.h'
check hasfunc statvfs
check hasfunc strchr "NULL,0" 'stdlib.h string.h strings.h'
check hasfunc strcoll "NULL,NULL" 'stdlib.h string.h'
check hasfunc strerror "0" 'string.h stdlib.h'
check hasfunc strftime "NULL,0,NULL,NULL" 'stdlib.h time.h'
check hasfunc strlcat
check hasfunc strlcpy
check hasfunc strtod 'NULL,NULL'
check hasfunc strtol 'NULL,NULL,0'
check hasfunc strtold
check hasfunc strtoll
check hasfunc strtoq
check hasfunc strtoul 'NULL,NULL,0'
check hasfunc strtoull 'NULL,NULL,0'
check hasfunc strtouq
check hasfunc strxfrm
check hasfunc symlink
check hasfunc syscall
check hasfunc sysconf '0'
check hasfunc system 'NULL'
check hasfunc tcgetpgrp
check hasfunc tcsetpgrp
check hasfunc telldir
check hasfunc time 'NULL'
check hasfunc timegm
check hasfunc times 'NULL'
check hasfunc truncate 'NULL,0'
check hasfunc ualarm
check hasfunc umask '0'
check hasfunc uname
check hasfunc unordered
check hasfunc unsetenv
check hasfunc usleep
check hasfunc ustat
##check hasfunc vfork
check hasfunc vprintf 'NULL,0'
check hasfunc vsnprintf
check hasfunc wait4
check hasfunc waitpid '0,NULL,0'
check hasfunc wcstombs 'NULL,NULL,0'
check hasfunc wctomb
check hasfunc writev

check isvoid closedir "NULL" 'sys/types.h dirent.h'
check hasvar sys_errlist 'stdio.h'
check hasvar tzname 'time.h'
