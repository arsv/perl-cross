#!/bin/sh

# We can't really check if header is there (gcc reports no errors for (some?) missing
# headers). And, in fact, we need not to. All we want to know is whether it's
# safe to include this header, i.e., won't it break compilation.

function hashdr {
	_hdrname=`symbolname "$1"`
	
	mstart "Checking whether to include <$1>"
	ifhintdefined "i_${_hdrname}" 'yes' 'no' && return $__
	try_start
	try_add "#include <$1>"
	try_compile
	resdef 'yes' 'no' "i_${_hdrname}"
}

check hashdr 'stdarg.h'
check hashdr 'stddef.h'
check hashdr 'stdio.h'
check hashdr 'stdlib.h'
check hashdr 'string.h'
check hashdr 'strings.h'
check hashdr 'stdint.h'
check hashdr 'unistd.h'
check hashdr 'limits.h'
check hashdr 'math.h'
check hashdr 'float.h'

check hashdr 'time.h'
check hashdr 'crypt.h'
check hashdr 'dirent.h'
check hashdr 'dlfcn.h'
check hashdr 'fcntl.h'
check hashdr 'grp.h'
check hashdr 'inttypes.h'
check hashdr 'locale.h'
check hashdr 'memory.h'
check hashdr 'pwd.h'
check hashdr 'setjmp.h'
check hashdr 'sfio.h'
check hashdr 'signal.h'
check hashdr 'sgtty.h'
check hashdr 'shadow.h'
check hashdr 'syslog.h'
check hashdr 'termio.h'
check hashdr 'termios.h'
check hashdr 'time.h'
check hashdr 'ustat.h'
check hashdr 'utime.h'
check hashdr 'values.h'
check hashdr 'varargs.h'
check hashdr 'vfork.h'

check hashdr 'sys/access.h'
check hashdr 'sys/dir.h'
check hashdr 'sys/file.h'
check hashdr 'sys/filio.h'
check hashdr 'sys/mode.h'
check hashdr 'sys/mount.h'
check hashdr 'sys/ndir.h'
check hashdr 'sys/param.h'
check hashdr 'sys/resource.h'
check hashdr 'sys/security.h'
check hashdr 'sys/select.h'
check hashdr 'sys/socket.h'
check hashdr 'sys/sockio.h'
check hashdr 'sys/stat.h'
check hashdr 'sys/statfs.h'
check hashdr 'sys/statvfs.h'
check hashdr 'sys/times.h'
check hashdr 'sys/types.h'
check hashdr 'sys/uio.h'
check hashdr 'sys/un.h'
check hashdr 'sys/utsname.h'
check hashdr 'sys/vfs.h'
check hashdr 'sys/wait.h'
check hashdr 'sys/time.h'

check hashdr 'dbm.h'
check hashdr 'gdbm.h'
check hashdr 'mach/cthreads.h'
check hashdr 'ndbm.h'
check hashdr 'net/errno.h'
check hashdr 'netdb.h'
check hashdr 'netinet/in.h'
check hashdr 'netinet/tcp.h'
check hashdr 'rpcsvc/dbm.h'

const i_systimek undef
