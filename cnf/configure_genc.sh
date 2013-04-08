#!/bin/bash

# Missing variable in config.sh may result in syntactically incorrect
# config.h (or even more nasty things, if it's in the right part of #define)
# This file should write all possible variables to $config, either taking
# their values from environment, or using some defaults, or dying when value
# is not set.

# Except for directory- and typesize-related things put in front, all variables
# here are sorted alphabetically.

# Keep this file in sync with Glossary

if [ -z "$cleanonly" ]; then
	# do a real write to $config

	# default name value
	function default {
		v=`valueof "$1"`
		if [ -z "$v" ]; then
			putvar "$1" "$2"
		else
			putvar "$1" "$v"
		fi
	}

	function default_inst {
		if [ -n "$2" ]; then
			z="$2"
			s="$1"
		else
			z="$1"
			s="$1"
		fi
		v=`valueof "$s"`
		if [ -n "$v" -a "$v" != ' ' ]; then
			default "install$z" "$installprefix$v"
		else
			default "install$z" ''
		fi
	}

	# required name
	function required {
		v=`valueof "$1"`
		if [ -n "$v" ]; then
			putvar "$1" "$v"
		else
			fail "Required variable $1 not defined"
		fi
	}

	function const {
		putvar "$1" "$2"
	}

	test -n "$config" || die "Can't generate don't-know-what (no \$config set)"
	msg "Generating $config"
	echo -ne "#!/bin/sh\n\n" > $config
else 
	# clean up the environment

	function default { unset -v "$1"; }
	function default_inst { unset -v "$1"; }
	function required { unset -v "$1"; }
	function const { unset -v "$1"; }
fi

required archname
default package perl5
default version "$PERL_REVISION.$PERL_VERSION.$PERL_SUBVERSION"

default prefix "/usr"
default sharedir "$prefix/share"
default html1dir "$sharedir/doc/perl/html"
default html3dir "$sharedir/doc/perl/html"
default man1dir "$sharedir/man/man1"
default man1ext "1"
default man3dir "$sharedir/man/man3"
default man3ext "3"
default bin "$prefix/bin"
default scriptdir "$prefix/bin"
default otherlibdirs ' '
default libsdirs ' '
default privlib "$prefix/lib/$package"
default archlib "$prefix/lib/$package/$version/$archname"
default perlpath "$prefix/bin/perl"

default sitebin	"$prefix/bin"
default sitelib_stem "$prefix/lib/$package/site_perl"
default sitelib "$sitelib_stem/$version"
default siteprefix "$prefix"
default sitescript "$prefix/bin"
default sitearch "$sitelib_stem/$version/$archname"
default sitearchexp "$sitearch"

default sitebinexp "$sitebin"
default sitelibexp "$sitelib"
default siteprefixexp "$siteprefix"
default sitescriptexp "$sitescript"

default vendorman1dir "$man1dir"
default vendorman3dir "$man3dir"
default vendorhtml1dir "$html1dir"
default vendorhtml3dir "$html3dir"
default siteman1dir "$man1dir"
default siteman3dir "$man3dir"
default sitehtml1dir "$html1dir"
default sitehtml3dir "$html3dir"

default installprefix ''
default_inst html1dir
default_inst html3dir
default_inst man1dir
default_inst man1ext
default_inst man3dir
default_inst man3ext
default_inst scriptdir
default_inst otherlibdirs
default_inst libsdirs
default_inst archlib
default_inst bin
default_inst html1dir
default_inst html3dir
default_inst privlib
default_inst scriptdir script
default_inst sitearch
default_inst sitebin
default_inst sitehtml1dir 
default_inst sitehtml3dir
default_inst sitelib 
default_inst siteman1dir
default_inst siteman3dir
default_inst sitescriptdir sitescript
default_inst vendorarch
default_inst vendorbin
default_inst vendorhtml1dir
default_inst vendorhtml3dir
default_inst vendorlib
default_inst vendorman1dir
default_inst vendorman3dir
default_inst vendorscriptdir vendorscript
default installstyle lib/perl5
default installusrbinperl define

const prefixexp "$prefix"
const installprefixexp "$installprefix"
const html1direxp "$html1dir"
const html3direxp "$html3dir"
const vendorman1direxp "$vendorman1dir"
const vendorman3direxp "$vendorman3dir"
const vendorhtml1direxp "$vendorhtml1dir"
const vendorhtml3direxp "$vendorhtml3dir"
const siteman1direxp "$siteman1dir"
const siteman3direxp "$siteman3dir"
const sitehtml1direxp "$sitehtml1dir"
const sitehtml3direxp "$sitehtml3dir"
const scriptdirexp "$scriptdir"
const man1direxp "$man1dir"
const man3direxp "$man3dir"
const archlibexp "$archlib"
const privlibexp "$privlib"
const binexp "$bin"

default libpth "/lib /usr/lib /usr/local/lib"
default glibpth "$libpth"
default plibpth

required PERL_API_REVISION
required PERL_API_SUBVERSION
required PERL_API_VERSION
required PERL_CONFIG_SH
required PERL_REVISION
required PERL_SUBVERSION
required PERL_VERSION
required api_revision
required api_subversion
required api_version
required api_versionstring
required doublesize
required i16size
required i16type
required i32size
required i32type
required i64size
required i64type
required i8size
required i8type
required intsize
required ivsize
required ivtype
required longdblsize
required longlongsize
required longsize
required nvsize
required nvtype
required u16size
required u16type
required u32size
required u32type
required u64size
required u64type
required u8size
required u8type
required uvsize
required uvtype

required cpp
required fpossize
required fpostype
required gidsize
required gidtype
required lseeksize
required lseektype
required shortsize

default Mcc Mcc
default PERL_PATCHLEVEL
default _a .a
default _exe
default _o .o
default afs false
default afsroot /afs
default alignbytes 8
default ansi2knr
default aphostname /bin/hostname
default ar ar
default archname64
default archobjs
default asctime_r_proto  0
default awk awk
default baserev 5.0
default bash
default bison bison
default byacc byacc
default byteorder
default c
default castflags 0
default cat cat
default cc cc
default cccdlflags '-fPIC'
default ccdlflags '-Wl,-E'
default ccflags '-fno-strict-aliasing -pipe'
default ccflags_uselargefiles ''
default ccdefines ''
default ccname
default ccsymbols
default ccversion
default charbits 8
default charsize 1
default cf_by unknown
default cf_email nobody@nowhere.land
default cf_time "`date`"
default chgrp
default chmod chmod
default chown
default clocktype
default comm comm
default compress
default config_arg0 ''
default config_argc 0
default config_args ''                                                        
default contains grep
default cp cp
default cpio
default cpp_stuff 42
default cppccsymbols
default cppflags
default cpplast -
default cppminus -
default cpprun "$cpp"
default cppstdin "$cpp"
default cppsymbols
default crypt_r_proto 0
default cryptlib
default csh ''
default ctermid_r_proto 0
default ctime_r_proto 0
default d_Gconvert 'sprintf((b),"%.*g",(n),(x))'
default d_PRIEUldbl undef
default d_PRIFUldbl undef
default d_PRIGUldbl undef
default d_PRIXU64 undef
default d_PRId64 undef
default d_PRIeldbl undef
default d_PRIfldbl undef
default d_PRIgldbl undef
default d_PRIi64 undef
default d_PRIo64 undef
default d_PRIu64 undef
default d_PRIx64 undef
default d_SCNfldbl undef
default d__fwalk undef
default d_access undef
default d_accessx undef
default d_aintl undef
default d_alarm undef
default d_archlib define
default d_asctime64 undef
default d_asctime_r undef
default d_atolf undef
default d_atoll undef
default d_attribute_deprecated undef
default d_attribute_format undef
default d_attribute_malloc undef
default d_attribute_nonnull undef
default d_attribute_noreturn undef
default d_attribute_pure undef
default d_attribute_unused undef
default d_attribute_warn_unused_result undef
default d_bcmp undef
default d_bcopy undef
default d_bsd undef
default d_bsdgetpgrp undef
default d_bsdsetpgrp undef
default d_builtin_choose_expr define
default d_builtin_expect undef
default d_bzero undef
default d_c99_variadic_macros define
default d_casti32 undef
default d_castneg define
default d_charvspr undef
default d_chown undef
default d_chroot undef
default d_chsize undef
default d_class undef
default d_clearenv undef
default d_closedir undef
default d_cmsghdr_s undef
default d_const define
default d_copysignl undef
default d_cplusplus undef
default d_crypt undef
default d_crypt_r undef
default d_csh undef
default d_ctermid undef
default d_ctermid_r undef
default d_ctime64 undef
default d_ctime_r undef
default d_cuserid undef
default d_dbl_dig undef
default d_dbminitproto define
default d_difftime undef
default d_difftime64 undef
default d_dir_dd_fd undef
default d_dirfd undef
default d_dirnamlen undef
default d_dlerror undef
default d_dlopen undef
default d_dlsymun undef
default d_dosuid undef
default d_drand48_r undef
default d_drand48proto define
default d_dup2 undef
default d_eaccess undef
default d_endgrent undef
default d_endgrent_r undef
default d_endhent undef
default d_endhostent_r undef
default d_endnent undef
default d_endnetent_r undef
default d_endpent undef
default d_endprotoent_r define
default d_endpwent undef
default d_endpwent_r undef
default d_endsent undef
default d_endservent_r undef
default d_eofnblk define
default d_eunice undef
default d_faststdio undef
default d_fchdir undef
default d_fchmod undef
default d_fchown undef
default d_fcntl undef
default d_fcntl_can_lock undef
default d_fd_macros undef
default d_fd_set undef
default d_fds_bits undef
default d_fgetpos undef
default d_finite undef
default d_finitel undef
default d_flexfnam define
default d_flock undef
default d_flockproto define
default d_fork undef
default d_fp_class undef
default d_fpathconf undef
default d_fpclass undef
default d_fpclassify undef
default d_fpclassl undef
default d_fpos64_t undef
default d_frexpl undef
default d_fs_data_s undef
default d_fseeko undef
default d_fsetpos undef
default d_fstatfs undef
default d_fstatvfs undef
default d_fsync undef
default d_ftello undef
default d_ftime undef
default d_futimes undef
default d_gdbm_ndbm_h_uses_prototypes define
default d_gdbm_ndbm_h_uses_prototypes undef
default d_gdbmndbm_h_uses_prototypes define
default d_gdbmndbm_h_uses_prototypes undef
default d_getaddrinfo undef
default d_getcwd undef
default d_getespwnam undef
default d_getfsstat undef
default d_getgrent undef
default d_getgrent_r undef
default d_getgrgid_r undef
default d_getgrnam_r undef
default d_getgrps undef
default d_gethbyaddr undef
default d_gethbyname undef
default d_gethent undef
default d_gethname undef
default d_gethostbyaddr_r undef
default d_gethostbyname_r undef
default d_gethostent_r undef
default d_gethostprotos define
default d_getitimer undef
default d_getlogin undef
default d_getlogin_r undef
default d_getmnt undef
default d_getmntent undef
default d_getnameinfo undef
default d_getnbyaddr undef
default d_getnbyname undef
default d_getnent undef
default d_getnetbyaddr_r undef
default d_getnetbyname_r undef
default d_getnetent_r undef
default d_getnetprotos define
default d_getpagsz undef
default d_getpbyname undef
default d_getpbynumber undef
default d_getpent undef
default d_getpgid undef
default d_getpgrp undef
default d_getpgrp2 undef
default d_getppid undef
default d_getprior undef
default d_getprotobyname_r define
default d_getprotobynumber_r define
default d_getprotoent_r define
default d_getprotoprotos define
default d_getprpwnam undef
default d_getpwent undef
default d_getpwent_r undef
default d_getpwnam_r undef
default d_getpwuid_r undef
default d_getsbyname undef
default d_getsbyport undef
default d_getsent undef
default d_getservbyname_r undef
default d_getservbyport_r undef
default d_getservent_r undef
default d_getservprotos define
default d_getspnam undef
default d_getspnam_r undef
default d_gettimeod undef
default d_gmtime64 undef
default d_gmtime_r undef
default d_gnulibc define
default d_grpasswd undef
default d_hasmntopt undef
default d_htonl undef
default d_ilogbl undef
default d_inc_version_list undef
default d_index undef
default d_inetaton undef
default d_inetntop undef
default d_inetpton undef
default d_int64_t undef
default d_ipv6_mreq undef
default d_isascii undef
default d_isblank undef
default d_isfinite undef
default d_isinf undef
default d_isnan undef
default d_isnanl undef
default d_killpg undef
default d_lchown undef
default d_ldbl_dig undef
default d_libm_lib_version undef
default d_link undef
default d_localtime64 undef
default d_localtime_r undef
default d_localtime_r_needs_tzset undef
default d_locconv undef
default d_lockf undef
default d_longdbl undef
default d_longlong undef
default d_lseekproto define
default d_lstat undef
default d_madvise undef
default d_malloc_good_size undef
default d_malloc_size undef
default d_mblen undef
default d_mbstowcs undef
default d_mbtowc undef
default d_memchr undef
default d_memcmp undef
default d_memcpy undef
default d_memmove undef
default d_memset undef
default d_mkdir undef
default d_mkdtemp undef
default d_mkfifo undef
default d_mkstemp undef
default d_mkstemps undef
default d_mktime undef
default d_mktime64 undef
default d_mmap undef
default d_modfl undef
default d_modfl_pow32_bug undef
default d_modflproto define
default d_mprotect undef
default d_msg undef
default d_msg_ctrunc undef
default d_msg_dontroute undef
default d_msg_oob undef
default d_msg_peek undef
default d_msg_proxy undef
default d_msgctl undef
default d_msgget undef
default d_msghdr_s undef
default d_msgrcv undef
default d_msgsnd undef
default d_msync undef
default d_munmap undef
default d_mymalloc undef
default d_ndbm_h_uses_prototypes
default d_ndbm_h_uses_prototypes define
default d_nice undef
default d_nl_langinfo undef
default d_nv_preserves_uv undef
default d_nv_zero_is_allbits_zero define
default d_off64_t undef
default d_old_pthread_create_joinable undef
default d_oldpthreads undef
default d_oldsock undef
default d_open3 undef
default d_pathconf undef
default d_pause undef
default d_perl_otherlibdirs undef
default d_phostname undef
default d_pipe undef
default d_poll undef
default d_portable undef
default d_prctl undef
default d_prctl_set_name undef
default d_printf_format_null define
default d_procselfexe undef
default d_pseudofork undef
default d_pthread_atfork undef
default d_pthread_attr_setscope undef
default d_pthread_yield undef
default d_pwage undef
default d_pwchange undef
default d_pwclass undef
default d_pwcomment undef
default d_pwexpire undef
default d_pwgecos undef
default d_pwpasswd undef
default d_pwquota undef
default d_qgcvt undef
default d_quad undef
default d_random_r undef
default d_readdir undef
default d_readdir64_r undef
default d_readdir_r undef
default d_readlink undef
default d_readv undef
default d_recvmsg undef
default d_rename undef
default d_rewinddir undef
default d_rmdir undef
default d_safebcpy undef
default d_safemcpy undef
default d_sanemcmp define
default d_sbrkproto define
default d_scalbnl undef
default d_sched_yield undef
default d_scm_rights undef
default d_sin6_scope_id undef
default d_sockaddr_sa_len undef
default d_sockaddr_in6 undef
default d_seekdir undef
default d_select undef
default d_sem undef
default d_semctl undef
default d_semctl_semid_ds undef
default d_semctl_semun undef
default d_semget undef
default d_semop undef
default d_sendmsg undef
default d_setegid undef
default d_seteuid undef
default d_setgrent undef
default d_setgrent_r undef
default d_setgrps undef
default d_sethent undef
default d_sethostent_r undef
default d_setitimer undef
default d_setlinebuf undef
default d_setlocale undef
default d_setlocale_r undef
default d_setnent undef
default d_setnetent_r undef
default d_setpent undef
default d_setpgid undef
default d_setpgrp undef
default d_setpgrp2 undef
default d_setprior undef
default d_setproctitle undef
default d_setprotoent_r define
default d_setpwent undef
default d_setpwent_r undef
default d_setregid undef
default d_setresgid undef
default d_setresuid undef
default d_setreuid undef
default d_setrgid undef
default d_setruid undef
default d_setsent undef
default d_setservent_r undef
default d_setsid undef
default d_setvbuf undef
default d_sfio undef
default d_shm undef
default d_shmat undef
default d_shmatprototype define
default d_shmctl undef
default d_shmdt undef
default d_shmget undef
default d_sigaction undef
default d_signbit undef
default d_sigprocmask undef
default d_sigsetjmp undef
default d_sitearch define
default d_snprintf undef
default d_sockatmark undef
default d_sockatmarkproto define
default d_socket undef
default d_socklen_t undef
default d_sockpair undef
default d_socks5_init undef
default d_sprintf_returns_strlen undef
default d_sqrtl undef
default d_srand48_r undef
default d_srandom_r undef
default d_sresgproto define
default d_sresuproto define
default d_statblks undef
default d_statfs_f_flags undef
default d_statfs_s undef
default d_static_inline undef
default perl_static_inline static
default d_statvfs undef
default d_stdio_cnt_lval undef
default d_stdio_ptr_lval undef
default d_stdio_ptr_lval_nochange_cnt undef
default d_stdio_ptr_lval_sets_cnt undef
default d_stdio_stream_array undef
default d_stdiobase undef
default d_stdstdio undef
default d_strchr undef
default d_strcoll undef
default d_strctcpy define
default d_strerrm 'strerror(e)'
default d_strerror undef
default d_strerror_r undef
default d_strftime undef
default d_strlcat undef
default d_strlcpy undef
default d_strtod undef
default d_strtol undef
default d_strtold undef
default d_strtoll undef
default d_strtoq undef
default d_strtoul undef
default d_strtoull undef
default d_strtouq undef
default d_strxfrm undef
default d_suidsafe undef
default d_symlink undef
default d_syscall undef
default d_syscallproto define
default d_sysconf undef
default d_sysernlst ''
default d_syserrlst undef
default d_system undef
default d_tcgetpgrp undef
default d_tcsetpgrp undef
default d_telldir undef
default d_telldirproto define
default d_time undef
default d_timegm undef
default d_times undef
default d_tm_tm_gmtoff undef
default d_tm_tm_zone undef
default d_tmpnam_r undef
default d_truncate undef
default d_ttyname_r undef
default d_tz_name 
default d_tzname undef
default d_u32align undef
default d_ualarm undef
default d_umask undef
default d_uname undef
default d_union_semun undef
default d_unordered undef
default d_unsetenv undef
default d_usleep undef
default d_usleepproto define
default d_ustat undef
default d_vendorarch undef
default d_vendorbin undef
default d_vendorlib undef
default d_vendorscript undef
default d_vfork undef
default d_void_closedir undef
default d_voidsig undef
default d_voidtty
default d_volatile undef
default d_vprintf undef
default d_vsnprintf undef
default d_wait4 undef
default d_waitpid undef
default d_wcstombs undef
default d_wctomb undef
default d_writev undef
default d_xenix undef
default date date
default db_hashtype 'unsigned int'
default db_prefixtype 'size_t'
default db_version_major
default db_version_minor
default db_version_patch
default defvoidused 15
default direntrytype 'struct dirent'
default dlext 'so'
default dlsrc 'dl_dlopen.xs'
default drand01 'drand48()'
default drand48_r_proto 0
default dtrace
default dynamic_ext
default eagain EAGAIN
default ebcdic undef
default echo echo
default egrep egrep
default emacs
default endgrent_r_proto 0
default endhostent_r_proto 0
default endnetent_r_proto 0
default endprotoent_r_proto 0
default endpwent_r_proto 0
default endservent_r_proto 0
default eunicefix ':'
default exe_ext
default expr
default expr expr
default extensions "$dynamic_ext$nonxs_ext"
default extras
default fflushNULL define
default fflushall undef
default find
default firstmakefile Makefile
default flex
default freetype void
default from :
default full_ar ar
default full_csh csh
default full_sed sed
default gccansipedantic
default gccosandvers
default gccversion
default getgrent_r_proto 0
default getgrgid_r_proto 0
default getgrnam_r_proto 0
default gethostbyaddr_r_proto 0
default gethostbyname_r_proto 0
default gethostent_r_proto 0
default getlogin_r_proto 0
default getnetbyaddr_r_proto 0
default getnetbyname_r_proto 0
default getnetent_r_proto 0
default getprotobyname_r_proto 0
default getprotobynumber_r_proto 0
default getprotoent_r_proto 0
default getpwent_r_proto 0
default getpwnam_r_proto 0
default getpwuid_r_proto 0
default getservbyname_r_proto 0
default getservbyport_r_proto 0
default getservent_r_proto 0
default getspnam_r_proto 0
default gidformat '"lu"'
default gidsign 1
default gmake gmake
default gmtime_r_proto 0
default gnulibc_version
default grep grep
default groupcat 'cat /etc/group'
default groupstype gid_t
default gzip gzip
default h_fcntl false
default h_sysfile true
default hint 'default'
default hostcat 'cat /etc/hosts'
default i_arpainet undef
default i_assert undef
default i_bsdioctl undef
default i_crypt undef
default i_db undef
default i_dbm undef
default i_dirent undef
default i_dld undef
default i_dlfcn undef
default i_fcntl undef
default i_float define
default i_fp undef
default i_fp_class undef
default i_gdbm undef
default i_gdbm_ndbm undef
default i_gdbmndbm undef
default i_grp undef
default i_ieeefp undef
default i_inttypes undef
default i_langinfo undef
default i_libutil undef
default i_limits define
default i_locale undef
default i_machcthr undef
default i_malloc undef
default i_mallocmalloc undef
default i_math undef
default i_memory undef
default i_mntent undef
default i_ndbm undef
default i_netdb undef
default i_neterrno undef
default i_netinettcp undef
default i_niin undef
default i_poll undef
default i_prot undef
default i_pthread undef
default i_pwd undef
default i_rpcsvcdbm undef
default i_sfio undef
default i_sgtty undef
default i_shadow undef
default i_socks undef
default i_stdarg undef
default i_stdbool undef
default i_stddef undef
default i_stdlib undef
default i_string undef
default i_sunmath undef
default i_sysaccess undef
default i_sysdir undef
default i_sysfile undef
default i_sysfilio undef
default i_sysin undef
default i_sysioctl undef
default i_syslog undef
default i_sysmman undef
default i_sysmode undef
default i_sysmount undef
default i_sysndir undef
default i_sysparam undef
default i_syspoll undef
default i_sysresrc undef
default i_syssecrt undef
default i_sysselct undef
default i_syssockio undef
default i_sysstat undef
default i_sysstatfs undef
default i_sysstatvfs undef
default i_systime undef
default i_systimek undef
default i_systimes undef
default i_systypes undef
default i_sysuio undef
default i_sysun undef
default i_sysutsname undef
default i_sysvfs undef
default i_syswait undef
default i_termio undef
default i_termios undef
default i_time undef
default i_unistd undef
default i_ustat undef
default i_utime undef
default i_values undef
default i_varargs undef
default i_varhdr undef
default i_vfork undef
default ignore_versioned_solibs
default inc_version_list
default inc_version_list_init
default incpath
default inews
default initialinstalllocation
default issymlink "test -h"
default ivdformat '"ld"'
default known_extensions
default ksh
default ld ld
default ld_can_script undef
default lddlflags '-shared '
default ldflags
default ldflags_uselargefiles
default ldlibpthname 'LD_LIBRARY_PATH'
default less less
default lib_ext .a
default libc
default libperl libperl.a
default libs
default libsfiles
default libsfound
default libspath
default libswanted
default libswanted_uselargefiles
default line
default lint
default lkflags
default ln 'ln'
default lns "$ln -s"
default localtime_r_proto 0
default locincpth
default loclibpth
default lp
default lpr
default ls ls
default mad undef
default madlyh
default madlyobj
default madlysrc
default mail
default mailx
default make make
default make_set_make '#'
default mallocobj
default mallocsrc
default malloctype 'void*'
default mips_type
default mistrustnm
default mkdir mkdir
default mmaptype 'void *'
default modetype mode_t
default more more
default multiarch undef
default mv
default myarchname
default mydomain
default myhostname
default myuname ${target}
default n 'XS/Typemap'
default n -n
default need_va_copy define
default netdb_hlen_type 'socklen_t'
default netdb_host_type 'const void *'
default netdb_name_type int
default netdb_net_type 'uint32_t'
default nm nm
default nm_opt
default nm_so_opt
default nonxs_ext
default nroff nroff
default nvEUformat '"E"'
default nvFUformat '"F"'
default nvGUformat '"G"'
default nv_overflows_integers_at '256.0*256.0*256.0*256.0*256.0*256.0*2.0*2.0*2.0*2.0*2.0'
default nv_preserves_uv_bits 0
default nveformat '"e"'
default nvfformat '"f"'
default nvgformat '"g"'
default o_nonblock O_NONBLOCK
default obj_ext .o
default objdump objdump
default old_pthread_create_joinable PTHREAD_CREATE_JOINABLE
default optimize
default orderlib
default osname linux
default osvers current
default pager less
default passcat 'cat /etc/passwd'
default patchlevel
default path_sep ':'
default perl
default perl5
default perl_patchlevel
default perladmin 'nobody@nowhere.land'
default perllibs "$libs"
default pg pg
default phostname hostname
default pidtype pid_t
default pmake
default pr
default procselfexe '"/proc/self/exe"'
default prototype define
default ptrsize
default quadkind
default quadtype
default randbits 48
default randfunc
default random_r_proto 0
default randseedtype long
default ranlib ranlib
default rd_nodata -1
default readdir64_r_proto 0
default readdir_r_proto 0
default rm rm
default rm_try
default rmail
default run
default runnm false
default sGMTIME_max '2147483647'
default sGMTIME_min '-2147483648'
default sLOCALTIME_max '2147483647'
default sLOCALTIME_min '-2147483648'
default sPRIEUldbl '"LE"'
default sPRIFUldbl '"LF"'
default sPRIGUldbl '"LG"'
default sPRIXU64 '"LX"'
default sPRId64 '"Ld"'
default sPRIeldbl '"Le"'
default sPRIfldbl '"Lf"'
default sPRIgldbl '"Lg"'
default sPRIi64 '"Li"'
default sPRIo64 '"Lo"'
default sPRIu64 '"Lu"'
default sPRIx64 '"Lx"'
default sSCNfldbl '"Lf"'
default sched_yield 'sched_yield()'
default sed sed
default seedfunc srand48
default selectminbits '32'
default selecttype 'fd_set *'
default sendmail
default setgrent_r_proto 0
default sethostent_r_proto 0
default setlocale_r_proto 0
default setnetent_r_proto 0
default setprotoent_r_proto 0
default setpwent_r_proto 0
default setservent_r_proto 0
default sh /bin/sh
default shar
default sharpbang '#!'
default shmattype 'void *'
default shrpenv
default shsharp true
default sig_count
default sig_name
default sig_name_init
default sig_num
default sig_num_init
default sig_size
default signal_t void
default sizesize
default sizetype
default sleep
default smail
default so so
default sockethdr
default socketlib
default socksizetype socklen_t
default sort sort
default spackage Perl5
default spitshell cat
default srand48_r_proto 0
default srandom_r_proto 0
default src `cd .. >/dev/null ; pwd`
default ssizetype
default st_ino_sign 1
default st_ino_size 4
default startperl "$sharpbang$perlpath"
default startsh '#!/bin/sh'
default static_ext
default stdchar char
default stdio_base
default stdio_bufsiz
default stdio_bufsize
default stdio_cnt
default stdio_filbuf
default stdio_ptr
default stdio_stream_array
default strerror_r_proto 0
default strings
default submit
default subversion
default sysman
default tail
default tar
default tbl
default tee
default test test
default timeincl
default timetype
default tmpnam_r_proto 0
default to :
default toolsprefix
default touch touch
default tr tr
default trnl '\n'
default troff
default ttyname_r_proto 0
default uidformat '"lu"'
default uidsign
default uidsize
default uidtype
default uname uname
default uniq uniq
default uquadtype
default use5005threads undef
default use64bitall undef
default use64bitint undef
default usecrosscompile undef
default usedevel undef
default usedl define
default usedtrace undef
default usefaststdio undef
default useithreads undef
default usekernprocpathname undef
default uselargefiles define
default uselongdouble undef
default usemallocwrap define
default usemorebits undef
default usemultiplicity undef
default usemymalloc n
default usenm false
default usensgetexecutablepath undef
default useopcode false
default useperlio define
default useposix true
default usereentrant undef
default userelocatableinc undef
default usesfio false
default useshrplib false
default usesitecustomize undef
default usesocks undef
default usethreads undef
default usevendorprefix undef
default usevfork false
default usrinc
default uuname
default uvXUformat '"lX"'
default uvoformat '"lo"'
default uvuformat '"lu"'
default uvxformat '"lx"'
default vaproto 'define'
default vendorarch
default vendorarchexp
default vendorbin
default vendorbinexp
default vendorlib
default vendorlib_stem
default vendorlibexp
default vendorprefix
default vendorprefixexp
default vendorscript
default vendorscriptexp
default version_patchlevel_string "version $PERL_VERSION subversion $PERL_SUBVERSION"
default versiononly undef
default vi
default voidflags 15
default xlibpth
default yacc yacc
default yaccflags
default zcat
default zip zip

# "use MakeMaker direct CC Library Test"
# see cpan/ExtUtils-MakeMaker/lib/ExtUtils/MakeMaker/Liblist/Kid.pm
# and resp. patch for reasons
default usemmcclt 'define'

if [ "$mode" == "buildmini" ]; then
	default target_name
	default target_arch
	default sysroot
fi

if [ "$disabledmods" == 'define' ]; then
	default disabledmods 'define'
	default disabled_dynamic_ext ''
	default disabled_nonxs_ext ''
fi

if [ -z "$cleanonly" ]; then
	for k in $uservars; do
		k=`echo "$k" | sed -e 's/[^A-Za-z0-9_-]//g' -e 's/-/_/g'`
		x=`valueof "x_$k"`
		if [ "$x" != "written" ]; then
			v=`valueof "$k"`
			log "Writing $x $k=$v to $config"
			putvar "$k" "$v"
		fi
	done

	failpoint
fi

unset -f default
unset -f default_inst
unset -f required
unset -f const
