#!/bin/bash

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

check hashdr 'stdio.h'
test "$i_stdio" == 'define' ||\
	die "Can't include <stdio.h>, check compiler configuration"

check hashdr 'arpa/inet.h'
check hashdr 'assert.h'
check hashdr 'crypt.h'
check hashdr 'ctype.h'
check hashdr 'dbm.h'
check hashdr 'dirent.h'
check hashdr 'dlfcn.h'
check hashdr 'fcntl.h'
check hashdr 'float.h'
check hashdr 'gdbm-ndbm.h'
check hashdr 'gdbm.h'
check hashdr 'gdbm/ndbm.h'
check hashdr 'grp.h'
check hashdr 'inttypes.h'
check hashdr 'langinfo.h'
check hashdr 'limits.h'
check hashdr 'locale.h'
check hashdr 'mach/cthreads.h'
check hashdr 'malloc.h'
check hashdr 'math.h'
check hashdr 'memory.h'
check hashdr 'mntent.h'
check hashdr 'ndbm.h'
check hashdr 'net/errno.h'
check hashdr 'netdb.h'
check hashdr 'netinet/in.h'
check hashdr 'netinet/tcp.h'
check hashdr 'poll.h'
check hashdr 'pwd.h'
check hashdr 'rpcsvc/dbm.h'
check hashdr 'setjmp.h'
check hashdr 'sfio.h'
check hashdr 'sgtty.h'
check hashdr 'shadow.h'
check hashdr 'signal.h'
check hashdr 'stdarg.h'
check hashdr 'stdbool.h'
check hashdr 'stddef.h'
check hashdr 'stdint.h'
check hashdr 'stdlib.h'
check hashdr 'string.h'
check hashdr 'strings.h'
check hashdr 'sys/access.h'
check hashdr 'sys/dir.h'
check hashdr 'sys/file.h'
check hashdr 'sys/filio.h'
check hashdr 'sys/ioctl.h'
check hashdr 'sys/mman.h'
check hashdr 'sys/mode.h'
check hashdr 'sys/mount.h'
check hashdr 'sys/ndir.h'
check hashdr 'sys/param.h'
check hashdr 'sys/poll.h'
check hashdr 'sys/prctl.h'
check hashdr 'sys/resource.h'
check hashdr 'sys/security.h'
check hashdr 'sys/select.h'
check hashdr 'sys/sem.h'
check hashdr 'sys/socket.h'
check hashdr 'sys/sockio.h'
check hashdr 'sys/stat.h'
check hashdr 'sys/statfs.h'
check hashdr 'sys/statvfs.h'
check hashdr 'sys/time.h'
check hashdr 'sys/times.h'
check hashdr 'sys/types.h'
check hashdr 'sys/uio.h'
check hashdr 'sys/un.h'
check hashdr 'sys/utsname.h'
check hashdr 'sys/vfs.h'
check hashdr 'sys/wait.h'
check hashdr 'syslog.h'
check hashdr 'termio.h'
check hashdr 'termios.h'
check hashdr 'time.h'
check hashdr 'unistd.h'
check hashdr 'ustat.h'
check hashdr 'utime.h'
check hashdr 'values.h'
check hashdr 'varargs.h'
check hashdr 'vfork.h'

if [ "$usethreads" == 'define' ]; then
	check hashdr 'pthread.h'
fi

# simplified approach, compared to what Configure has.
# assume header is usable as long as it's there
mstart "Looking which header to use for varargs"
if [ "$i_stdarg" == 'define' ]; then
	setvar 'i_varargs' 'undef'
	setvar 'i_varhdr' 'stdarg.h'
	result '<stdarg.h>'	
elif [ "$i_varargs" == 'define' ]; then
	setvar 'i_stdarg' 'undef'
	setvar 'i_varhdr' 'varargs.h'
	result '<varargs.h>'
else
	result 'nothing found'
fi

setvar i_systimek undef
