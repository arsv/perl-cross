# We can't really check if header is there (gcc reports no errors for (some?) missing
# headers). And, in fact, we need not to. All we want to know is whether it's
# safe to include this header, i.e., that it won't break compilation.

checkhdr() {
	mstart "Checking whether to include <$2>"
	if not hinted "$1"; then
		try_start
		try_add "#include <$2>"
		try_compile
		resdef "$1" 'yes' 'no'
	fi
}

checkhdr i_stdio 'stdio.h'
test "$i_stdio" = 'define' ||\
	die "Can't include <stdio.h>, check compiler configuration"

checkhdr i_arpainet 'arpa/inet.h'
checkhdr i_assert 'assert.h'
checkhdr i_bfd 'bfd.h'
checkhdr i_bsdioctl 'sys/bsdioctl.h'
checkhdr i_crypt 'crypt.h'
checkhdr i_db 'db.h'
checkhdr i_dbm 'dbm.h'
checkhdr i_dirent 'dirent.h'
checkhdr i_dlfcn 'dlfcn.h'
checkhdr i_execinfo 'execinfo.h'
checkhdr i_fcntl 'fcntl.h'
checkhdr i_fenv 'fenv.h'
checkhdr i_float 'float.h'
checkhdr i_fp 'fp.h'
checkhdr i_fp_class 'fp_class.h'
checkhdr i_gdbm 'gdbm.h'
checkhdr i_gdbm_ndbm 'gdbm-ndbm.h'
checkhdr i_gdbmndbm 'gdbm/ndbm.h'
checkhdr i_grp 'grp.h'
checkhdr i_ieeefp 'ieeefp.h'
checkhdr i_inttypes 'inttypes.h'
checkhdr i_langinfo 'langinfo.h'
checkhdr i_libutil 'libutil.h'
checkhdr i_limits 'limits.h'
checkhdr i_locale 'locale.h'
checkhdr i_machcthr 'mach/cthreads.h'
checkhdr i_malloc 'malloc.h'
checkhdr i_mallocmalloc 'malloc/malloc.h'
checkhdr i_math 'math.h'
checkhdr i_memory 'memory.h'
checkhdr i_mntent 'mntent.h'
checkhdr i_ndbm 'ndbm.h'
checkhdr i_netdb 'netdb.h'
checkhdr i_neterrno 'net/errno.h'
checkhdr i_netinettcp 'netinet/tcp.h'
checkhdr i_niin 'netinet/in.h'
checkhdr i_netinet_ip 'netinet/ip.h'	 # cperl
checkhdr i_netinet_ip6 'netinet/ip6.h'	 # cperl
checkhdr i_netinet6_in6 'netinet6/in6.h' # cperl
checkhdr i_poll 'poll.h'
checkhdr i_prot 'prot.h'
checkhdr i_pthread 'pthread.h'
checkhdr i_pwd 'pwd.h'
checkhdr i_quadmath 'quadmath.h'
checkhdr i_rpcsvcdbm 'rpcsvc/dbm.h'
checkhdr i_sgtty 'sgtty.h'
checkhdr i_shadow 'shadow.h'
checkhdr i_socks 'socks.h'
# i_stdarg below
checkhdr i_stdbool 'stdbool.h'
checkhdr i_stddef 'stddef.h'
checkhdr i_stdint 'stdint.h'
checkhdr i_stdlib 'stdlib.h'
checkhdr i_string 'string.h'
checkhdr i_sunmath 'sunmath.h'
checkhdr i_sysaccess 'sys/access.h'
checkhdr i_sysdir 'sys/dir.h'
checkhdr i_sysfile 'sys/file.h'
checkhdr i_sysfilio 'sys/filio.h'
checkhdr i_sysin 'sys/in.h'
checkhdr i_sysioctl 'sys/ioctl.h'
checkhdr i_syslog 'syslog.h'
checkhdr i_sysmman 'sys/mman.h'
checkhdr i_sysmode 'sys/mode.h'
checkhdr i_sysmount 'sys/mount.h'
checkhdr i_sysndir 'sys/ndir.h'
checkhdr i_sysparam 'sys/param.h'
checkhdr i_syspoll 'sys/poll.h'
checkhdr i_sysresrc 'sys/resource.h'
checkhdr i_syssecrt 'sys/security.h'
checkhdr i_sysselct 'sys/select.h'
checkhdr i_syssockio 'sys/sockio.h'
checkhdr i_sysstat 'sys/stat.h'
checkhdr i_sysstatfs 'sys/statfs.h'
checkhdr i_sysstatvfs 'sys/statvfs.h'
checkhdr i_systime 'sys/time.h'
define i_systimek 'undef' # not a plain header check
checkhdr i_systimes 'sys/times.h'
checkhdr i_systypes 'sys/types.h'
checkhdr i_sysuio 'sys/uio.h'
checkhdr i_sysun 'sys/un.h'
checkhdr i_sysutsname 'sys/utsname.h'
checkhdr i_sysvfs 'sys/vfs.h'
checkhdr i_syswait 'sys/wait.h'
checkhdr i_termio 'termio.h'
checkhdr i_termios 'termios.h'
checkhdr i_time 'time.h'
checkhdr i_unistd 'unistd.h'
checkhdr i_ustat 'ustat.h'
checkhdr i_utime 'utime.h'
checkhdr i_values 'values.h'
# i_varargs is checked below
# i_varhdr is checked below
checkhdr i_vfork 'vfork.h'
checkhdr i_xlocale 'xlocale.h'

# These two are mutually exclusive
test "$i_varargs" != 'define' && checkhdr i_stdarg 'stdarg.h'
test "$i_stdarg"  != 'define' && checkhdr i_varargs 'varargs.h'

# simplified approach, compared to what Configure has.
# assume header is usable as long as it's there
mstart "Looking which header to use for varargs"
if [ "$i_stdarg" = 'define' ]; then
	define 'i_varargs' 'undef'
	define 'i_varhdr' 'stdarg.h'
	result '<stdarg.h>'	
elif [ "$i_varargs" = 'define' ]; then
	define 'i_stdarg' 'undef'
	define 'i_varhdr' 'varargs.h'
	result '<varargs.h>'
else
	define 'i_varhdr' ''
	result 'nothing found'
fi

# Set up largefile support, if needed.
# The limiting factor here is uClibc features.h, with raises error
# if FILE_OFFSET_BITS=64 is set but the library was built w/o LFS.
mstart "Checking whether to enable large file support"
if not hinted 'uselargefiles'; then
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
			resdef 'uselargefiles' "yes" "no"
	esac
fi
if [ "$uselargefiles" = 'define' ]; then
	append ccflags " -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64"
	log
fi

enddef ccflags # started in _tool
