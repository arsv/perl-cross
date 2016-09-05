# Tests for availability of libc functions.

# checkfunc name args includes
# WARNING: some compilers do have built-in notions on how certain
# function should be called, and will produce errors if those functions
# are called in a "wrong" way. 
# So far it looks like the safest option is to provide type-compatible arguments,
# i.e., "0" for ints, "NULL" for pointers etc.
checkfunc() {
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
	try_link -O0 -fno-builtin
	resdef 'found' 'not found' "$_s"
}

# checkvar name includes [symbol]
# We use try_link here instead of try_compile to be sure we have the
# variable in question not only declared but also present somewhere in the libraries.
checkvar() {
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

isvoid() {
	require 'cc'
	mstart "Checking whether $1 is void"
	ifhint "d_$1" && return

	try_start
	try_includes $3
	try_add "int main() { return $1($2); }"
	not try_compile
	resdef 'yes' 'no' "d_void_$1"
}

checkfunc _fwalk
checkfunc access "NULL,0" 'stdlib.h unistd.h'
checkfunc accessx
checkfunc aintl
checkfunc alarm "0" 'unistd.h'
checkfunc asctime64
checkfunc atolf
checkfunc atoll
checkfunc bcmp "NULL,NULL,0" 'stdlib.h string.h'
checkfunc bcopy "NULL,NULL,0" 'stdlib.h string.h'
checkfunc bzero "NULL,0" 'stdlib.h string.h'
checkfunc chown "NULL,0,0" 'stdlib.h unistd.h'
checkfunc chroot "NULL" 'unistd.h'
checkfunc chsize "0,0"
checkfunc class
checkfunc clearenv "" 'stdlib.h'
checkfunc closedir "NULL" 'stdlib.h'
checkfunc copysignl "0.0,0.0" 'math.h'
checkfunc crypt
checkfunc ctermid
checkfunc ctime64
checkfunc cuserid
checkfunc difftime "0,0"
checkfunc difftime64
checkfunc dirfd
checkfunc dlopen
checkfunc dlerror
checkfunc drand48
checkfunc dup2 "0,0"
checkfunc eaccess
checkfunc endgrent
checkfunc endhostent
checkfunc endnetent
checkfunc endprotoent
checkfunc endpwent
checkfunc endservent
checkfunc fchdir "0" 'unistd.h'
checkfunc fchmod "0,0" 'unistd.h'
checkfunc fchown "0,0,0" 'unistd.h'
checkfunc fcntl "0,0" 'unistd.h fcntl.h'
checkfunc fdclose
checkfunc fgetpos "NULL, 0" 'stdlib.h stdio.h'
checkfunc finite "0.0" 'math.h'
checkfunc finitel "0.0" 'math.h'
checkfunc flock "0,0" 'unistd.h sys/file.h'
checkfunc fork "" 'unistd.h'
checkfunc fp_class
checkfunc fpathconf "0,0" 'unistd.h'
checkfunc fpclass "1.0" 'math.h ieeefp.h'
checkfunc fpclassify "1.0" 'math.h'
checkfunc fpclassl "1.0" 'math.h ieeefp.h'
checkfunc frexpl '0,NULL' 'stdlib.h math.h'
checkfunc fseeko 'NULL,0,0'
checkfunc fsetpos 'NULL,0'
checkfunc fstatfs
checkfunc fstatvfs
checkfunc fsync
checkfunc ftello
checkfunc futimes
checkfunc getaddrinfo
checkfunc getcwd 'NULL,0'
checkfunc getespwnam
checkfunc getfsstat
checkfunc getgrent
checkfunc getgroups
checkfunc gethostbyaddr
checkfunc gethostbyname
checkfunc gethostent
checkfunc gethostname
checkfunc getitimer
checkfunc getlogin
checkfunc getmnt
checkfunc getmntent
checkfunc getnameinfo
checkfunc getnetbyaddr
checkfunc getnetbyname
checkfunc getnetent
checkfunc getpagesize
checkfunc getpgid
checkfunc getpgrp "" 'unistd.h'
checkfunc getpgrp2
checkfunc getppid
checkfunc getpriority "0,0" 'sys/time.h sys/resource.h'
checkfunc getprotobyaddr
checkfunc getprotobyname
checkfunc getprotobynumber
checkfunc getprotoent
checkfunc getprpwnam
checkfunc getpwent
checkfunc getservbyaddr
checkfunc getservbyname
checkfunc getservbyport
checkfunc getservent
checkfunc getspnam
checkfunc gettimeofday 'NULL,NULL'
checkfunc gmtime64
checkfunc hasmntopt
checkfunc htonl "0" 'stdio.h sys/types.h netinet/in.h arpa/inet.h'
checkfunc ilogbl
checkfunc index "NULL,0" 'stdlib.h string.h strings.h'
checkfunc inet_aton
checkfunc inet_ntop
checkfunc inet_pton
checkfunc isascii "'A'" 'stdio.h stdlib.h ctype.h'
checkfunc isblank "' '" 'stdio.h stdlib.h ctype.h'
checkfunc isfinite "0.0" 'math.h'
checkfunc isinf "0.0" 'math.h'
checkfunc isnan "0.0" 'math.h'
checkfunc isnanl "0.0" 'math.h'
checkfunc killpg
checkfunc lchown "NULL, 0, 0" 'stdlib.h unistd.h'
checkfunc link 'NULL,NULL' 'stdlib.h'
checkfunc localeconv
checkfunc localtime64
checkfunc lockf
checkfunc lstat
checkfunc madvise
checkfunc malloc_good_size
checkfunc malloc_size
checkfunc mblen
checkfunc mbstowcs
checkfunc mbtowc
checkfunc memchr "NULL, 0, 0" 'stdlib.h string.h'
checkfunc memcmp "NULL, NULL, 0" 'stdlib.h string.h'
checkfunc memcpy "NULL, NULL, 0" 'stdlib.h string.h'
checkfunc memmem "NULL, 0, NULL, 0" 'stdlib.h string.h'
checkfunc memmove "NULL, NULL, 0" 'stdlib.h string.h'
checkfunc memset "NULL, 0, 0" 'stdlib.h string.h'
checkfunc mkdir 'NULL, 0' 'stdlib.h'
checkfunc mkdtemp
checkfunc mkfifo
checkfunc mkstemp 'NULL' 'stdlib.h'
checkfunc mkstemps
checkfunc mktime 'NULL' 'stdlib.h'
checkfunc mktime64
checkfunc mmap
checkfunc modfl "0.0,NULL" 'stdlib.h math.h'
checkfunc mprotect
checkfunc msgctl
checkfunc msgget
checkfunc msgrcv
checkfunc msgsnd
checkfunc msync
checkfunc munmap
checkfunc nice '0'
checkfunc nl_langinfo
checkfunc open "NULL,0,0" 'stdlib.h sys/types.h sys/stat.h fcntl.h' d_open3
checkfunc pathconf
checkfunc pause
checkfunc pipe 'NULL'
checkfunc poll
checkfunc pthread_atfork
checkfunc pthread_attr_setscope
checkfunc pthread_yield
checkfunc prctl
checkfunc querylocale
checkfunc rand
checkfunc random
checkfunc re_comp
checkfunc readdir 'NULL'
checkfunc readlink
checkfunc readv
checkfunc recvmsg
checkfunc regcmp
checkfunc regcomp
checkfunc rename 'NULL,NULL'
checkfunc rewinddir
checkfunc rmdir 'NULL'
checkfunc scalbnl "0.0,0" 'math.h'
checkfunc sched_yield
checkfunc seekdir
checkfunc select '0,NULL,NULL,NULL,NULL'
checkfunc semctl
checkfunc semget
checkfunc semop
checkfunc sendmsg
checkfunc setegid
checkfunc seteuid
checkfunc setgrent
checkfunc setgroups
checkfunc sethostent
checkfunc setitimer
checkfunc setlinebuf
checkfunc setlocale "0,NULL" 'stdlib.h locale.h'
checkfunc setnetent
checkfunc setpgid
checkfunc setpgrp
checkfunc setpgrp2
checkfunc setpriority
checkfunc setproctitle
checkfunc setprotoent
checkfunc setpwent
checkfunc setregid
checkfunc setresgid
checkfunc setresuid
checkfunc setreuid
checkfunc setrgid
checkfunc setruid
checkfunc setservent
checkfunc setsid
checkfunc setvbuf 'NULL,NULL,0,0'
checkfunc sfreserve "" 'sfio.h'
checkfunc shmat
checkfunc shmctl
checkfunc shmdt
checkfunc shmget
checkfunc sigaction
checkfunc signbit '.0' 'math.h'
checkfunc sigprocmask
checkfunc sigsetjmp "NULL,0" 'stdlib.h setjmp.h'
checkfunc snprintf
checkfunc sockatmark
checkfunc socket "0,0,0" 'sys/types.h sys/socket.h'
checkfunc socketpair
checkfunc socks5_init
checkfunc sqrtl "0.0" 'math.h'
checkfunc stat
checkfunc statvfs
checkfunc strchr "NULL,0" 'stdlib.h string.h strings.h'
checkfunc strcoll "NULL,NULL" 'stdlib.h string.h'
checkfunc strerror "0" 'string.h stdlib.h'
checkfunc strftime "NULL,0,NULL,NULL" 'stdlib.h time.h'
checkfunc strlcat
checkfunc strlcpy
checkfunc strtod 'NULL,NULL'
checkfunc strtol 'NULL,NULL,0'
checkfunc strtold
checkfunc strtoll
checkfunc strtoq
checkfunc strtoul 'NULL,NULL,0'
checkfunc strtoull 'NULL,NULL,0'
checkfunc strtouq
checkfunc strxfrm
checkfunc symlink
checkfunc syscall
checkfunc sysconf '0'
checkfunc system 'NULL'
checkfunc tcgetpgrp
checkfunc tcsetpgrp
checkfunc telldir
checkfunc time 'NULL'
checkfunc timegm
checkfunc times 'NULL'
checkfunc truncate 'NULL,0'
checkfunc ualarm
checkfunc umask '0'
checkfunc uname
checkfunc unordered
checkfunc unsetenv
checkfunc usleep
checkfunc ustat
##checkfunc vfork
checkfunc vprintf 'NULL,0'
checkfunc vsnprintf
checkfunc wait4
checkfunc waitpid '0,NULL,0'
checkfunc wcscmp
checkfunc wcstombs 'NULL,NULL,0'
checkfunc wcsxfrm
checkfunc wctomb
checkfunc writev

checkfunc acosh '0.0' 'math.h'
checkfunc asinh '0.0' 'math.h'
checkfunc atanh '0.0' 'math.h'
checkfunc cbrt '0.0' 'math.h'
checkfunc copysign '0.0, 0.0' 'math.h'
checkfunc erf '0.0' 'math.h'
checkfunc erfc '0.0' 'math.h'
checkfunc exp2 '0.0' 'math.h'
checkfunc expm1 '0.0' 'math.h'
checkfunc fdim '0.0, 0.0' 'math.h'
checkfunc fegetround '' 'fenv.h'
checkfunc fma '0.0, 0.0, 0.0' 'math.h'
checkfunc fmax '0.0, 0.0' 'math.h'
checkfunc fmin '0.0, 0.0' 'math.h'
checkfunc fp_classify '0.0' 'math.h'
checkfunc fp_classl '0.0' 'math.h'
checkfunc fpgetround '' 'fenv.h'
checkfunc hypot '0.0, 0.0' 'math.h'
checkfunc ilogb '0.0' 'math.h'
checkfunc isfinitel '0.0' 'math.h'
checkfunc isinfl '0.0' 'math.h'
checkfunc isless '0.0, 0.0' 'math.h'
checkfunc isnormal '0.0' 'math.h'
checkfunc j0 '0.0' 'math.h'
checkfunc j0l '0.0' 'math.h'
checkfunc ldexpl '0.0, 0' 'math.h'
checkfunc lgamma '0.0' 'math.h'
checkfunc lgamma_r '0.0, NULL' 'math.h'
checkfunc llrint '0.0' 'math.h'
checkfunc llrintl '0.0' 'math.h'
checkfunc llround '0.0' 'math.h'
checkfunc llroundl '0.0' 'math.h'
checkfunc log1p '0.0' 'math.h'
checkfunc log2 '0.0' 'math.h'
checkfunc logb '0.0' 'math.h'
checkfunc lrint '0.0' 'math.h'
checkfunc lrintl '0.0' 'math.h'
checkfunc lround '0.0' 'math.h'
checkfunc lroundl '0.0' 'math.h'
checkfunc nan 'NULL' 'math.h'
checkfunc nearbyint '0.0' 'math.h'
checkfunc nextafter '0.0, 0.0' 'math.h'
checkfunc nexttoward '0.0, 0.0' 'math.h'
checkfunc remainder '0.0, 0.0' 'math.h'
checkfunc remquo '0.0, 0.0, NULL' 'math.h'
checkfunc rint '0.0' 'math.h'
checkfunc round '0.0' 'math.h'
checkfunc scalbn '0.0, 0' 'math.h'
checkfunc tgamma '0.0' 'math.h'
checkfunc trunc '0.0' 'math.h'
checkfunc truncl '0.0' 'math.h'

checkfunc backtrace 'NULL, 0' 'execinfo.h'
checkfunc dladdr 'NULL, NULL' 'dlfcn.h'

isvoid closedir "NULL" 'sys/types.h dirent.h'
checkvar sys_errlist 'stdio.h'
checkvar tzname 'time.h'

checkfunc newlocale '0,NULL,0' 'stdlib.h locale.h'
checkfunc freelocale '0' 'locale.h'
checkfunc uselocale '0' 'locale.h'
checkfunc duplocale '0' 'locale.h'
