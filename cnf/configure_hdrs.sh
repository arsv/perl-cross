# We can't really check if header is there (gcc reports no errors for (some?) missing
# headers). And, in fact, we need not to. All we want to know is whether it's
# safe to include this header, i.e., that it won't break compilation.

checkhdr() {
	if [ -n "$2" ]; then
		_hdrname=$2
	else
		_hdrname=`symbolname "$1"`
	fi
	
	mstart "Checking whether to include <$1>"
	ifhintdefined "i_${_hdrname}" 'yes' 'no' && return $__
	try_start
	try_add "#include <$1>"
	try_compile
	resdef 'yes' 'no' "i_${_hdrname}"
}

checkhdr 'stdio.h'
test "$i_stdio" = 'define' ||\
	die "Can't include <stdio.h>, check compiler configuration"

checkhdr 'arpa/inet.h'
checkhdr 'assert.h'
checkhdr 'bfd.h'
checkhdr 'crypt.h'
checkhdr 'ctype.h'
checkhdr 'db.h'
checkhdr 'dbm.h'
checkhdr 'dirent.h'
checkhdr 'dlfcn.h'
checkhdr 'fcntl.h'
checkhdr 'fenv.h'
checkhdr 'float.h'
checkhdr 'execinfo.h'
checkhdr 'gdbm-ndbm.h'
checkhdr 'gdbm.h'
checkhdr 'gdbm/ndbm.h'
checkhdr 'grp.h'
checkhdr 'inttypes.h'
checkhdr 'langinfo.h'
checkhdr 'limits.h'
checkhdr 'locale.h'
checkhdr 'mach/cthreads.h'
checkhdr 'malloc.h'
checkhdr 'math.h'
checkhdr 'memory.h'
checkhdr 'mntent.h'
checkhdr 'ndbm.h'
checkhdr 'net/errno.h'
checkhdr 'netdb.h'
checkhdr 'netinet/in.h'
checkhdr 'netinet/tcp.h'
checkhdr 'netinet/ip.h' i_netinet_ip
checkhdr 'netinet/ip6.h' i_netinet_ip6
checkhdr 'netinet6/in6.h' i_netinet6_in6
checkhdr 'nlist.h'
checkhdr 'poll.h'
checkhdr 'pwd.h'
checkhdr 'quadmath.h'
checkhdr 'rpcsvc/dbm.h'
checkhdr 'setjmp.h'
checkhdr 'sfio.h'
checkhdr 'sgtty.h'
checkhdr 'shadow.h'
checkhdr 'signal.h'
checkhdr 'stdarg.h'
checkhdr 'stdbool.h'
checkhdr 'stddef.h'
checkhdr 'stdint.h'
checkhdr 'stdlib.h'
checkhdr 'string.h'
checkhdr 'strings.h'
checkhdr 'sys/access.h'
checkhdr 'sys/dir.h'
checkhdr 'sys/file.h'
checkhdr 'sys/filio.h'
checkhdr 'sys/ioctl.h'
checkhdr 'sys/mman.h'
checkhdr 'sys/mode.h'
checkhdr 'sys/mount.h'
checkhdr 'sys/ndir.h'
checkhdr 'sys/param.h'
checkhdr 'sys/poll.h'
checkhdr 'sys/prctl.h'
checkhdr 'sys/resource.h'
checkhdr 'sys/security.h'
checkhdr 'sys/select.h'
checkhdr 'sys/sem.h'
checkhdr 'sys/socket.h'
checkhdr 'sys/sockio.h'
checkhdr 'sys/stat.h'
checkhdr 'sys/statfs.h'
checkhdr 'sys/statvfs.h'
checkhdr 'sys/time.h'
checkhdr 'sys/times.h'
checkhdr 'sys/types.h'
checkhdr 'sys/uio.h'
checkhdr 'sys/un.h'
checkhdr 'sys/utsname.h'
checkhdr 'sys/vfs.h'
checkhdr 'sys/wait.h'
checkhdr 'syslog.h'
checkhdr 'termio.h'
checkhdr 'termios.h'
checkhdr 'time.h'
checkhdr 'unistd.h'
checkhdr 'ustat.h'
checkhdr 'utime.h'
checkhdr 'values.h'
checkhdr 'varargs.h'
checkhdr 'vfork.h'
checkhdr 'xlocale.h'

test "$usethreads" = 'define' && check checkhdr 'pthread.h'

# simplified approach, compared to what Configure has.
# assume header is usable as long as it's there
mstart "Looking which header to use for varargs"
if [ "$i_stdarg" = 'define' ]; then
	setvar 'i_varargs' 'undef'
	setvar 'i_varhdr' 'stdarg.h'
	result '<stdarg.h>'	
elif [ "$i_varargs" = 'define' ]; then
	setvar 'i_stdarg' 'undef'
	setvar 'i_varhdr' 'varargs.h'
	result '<varargs.h>'
else
	result 'nothing found'
fi

setvar i_systimek undef
# Set up largefile support, if needed.
# The limiting factor here is uClibc features.h, with raises error
# if FILE_OFFSET_BITS=64 is set but the library was built w/o LFS.
mstart "Checking whether it's ok to enable large file support"
if nothinted 'uselargefiles'; then
	# Adding -D_FILE_OFFSET_BITS is mostly harmless, except
	# when dealing with uClibc that was compiled w/o largefile
	# support
	case "$ccflags" in
		*-D_FILE_OFFSET_BITS=*)
			result "already there"
			;;
		*)
			try_start
			try_includes "stdio.h"
			try_compile -D_FILE_OFFSET_BITS=64
			resdef "yes, enabling it" "no, it's disabled" 'uselargefiles'
	esac
fi
if [ "$uselargefiles" = 'define' ]; then
	appendvar 'ccflags' " -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64"
	log
fi
