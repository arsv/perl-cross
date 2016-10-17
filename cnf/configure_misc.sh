# Misc settings we do not test for.

# Configured-by; disabled, no point in leaking usernames
define cf_by ''
define cf_email ''
define cf_time ''

# No need to leak these either
define perladmin 'nobody@nowhere.land'
define osvers 'current'
define myarchname ''
define mydomain ''
define myhostname ''
define myuname ''

define Author
define Date '$Date'
define Header
define Id '$Id'
define Locker
define Log '$Log'
define RCSfile '$RCSfile'
define Revision '$Revision'
define Source
define State

# "use MakeMaker direct LD Library Test"
# see cpan/ExtUtils-MakeMaker/lib/ExtUtils/MakeMaker/Liblist/Kid.pm
# and resp. patch for reasons
define usemmldlt 'define'

# Used by modules?
define dlext 'so'
define dlsrc 'dl_dlopen.xs'

# Required by lib/Config.t, and configpm may use these.
# Empty values pass tests but essentially disable the code
# in configpm, which is probably for good.
define ccflags_uselargefiles ''
define ldflags_uselargefiles ''
define libs_uselargefiles ''
define libswanted_uselargefiles ''

# These are sometimes used in perl-cross, and sometimes also affect modules
# Some *must* be "false" instead of "undef"! See configure_args.sh
define use64bitall 'undef'
define use64bitint 'undef'
define usecbacktrace 'undef'
define usecrosscompile 'undef'
define usedevel 'undef'
# define usedl 'define'            # set in configure_libs
define usedtrace 'undef'
define usefaststdio 'undef'
# define use5005threads 'undef'    # set in configure_thrd
# define useithreads 'undef'       # set in configure_thrd
define usekernprocpathname 'undef'
# define uselargefiles 'define'    # set in configure_hdrs
define uselongdouble 'undef'
define usemallocwrap 'define'
define usemorebits 'undef'
define usemultiplicity 'undef'
define usemymalloc 'n'
define usenm 'false'
define usensgetexecutablepath 'undef'
# define useopcode 'false'         # set in configure_mods
define useperlio 'define'
# define useposix 'true'           # set in configure_mods
define usequadmath 'undef'
define usereentrant 'undef'
define userelocatableinc 'undef'
define usesfio 'false'
define useshrplib 'false'
define usesitecustomize 'undef'
define usesocks 'undef'
define useversionedarchname 'undef'
define usevfork 'false'

# cperl-specific symbols
define d_libname_unique 'undef'
define d_vms_case_sensitive_symbols 'undef'
define dl_so_eq_ext 'define'
# tested for in several places (ext/Config/t/XSConfig.t, t/op/hashflood)
define hash_func 'FNV1A' # cperl
define c ''
define d_bsd 'undef'
define d_eunice 'undef'
define d_xenix 'undef'
define d_ftime 'undef'
define d_oldsock 'undef'
define extras ''

# These are important but we don't test them
define startsh '#!/bin/sh'
define spitshell 'cat'
define d_Gconvert 'sprintf((b),"%.*g",(n),(x))'
define d_modfl_pow32_bug 'undef'
define direntrytype 'struct dirent'
define drand01 'drand48()'
define fflushNULL 'define'
define fflushall 'undef'
define freetype 'void'
define malloctype 'void*'
define mmaptype 'void *'
define modetype 'mode_t'
define need_va_copy 'define'
define o_nonblock 'O_NONBLOCK'
define old_pthread_create_joinable 'PTHREAD_CREATE_JOINABLE'
define prototype 'define'
define rd_nodata -1
define sched_yield 'sched_yield()'
define socksizetype 'socklen_t'
define vaproto 'define'
define groupstype 'gid_t'
define h_fcntl 'false'
define h_sysfile 'true'
define ldlibpthname 'LD_LIBRARY_PATH'
define pidtype 'pid_t'
define selectminbits '32'
define selecttype 'fd_set *'
define shmattype 'void *'
define st_ino_sign 1
define st_ino_size 4
define d_open3 'define'
define d_safebcpy 'define'
define d_safemcpy 'undef'
define d_sanemcmp 'define'
define d_casti32 'undef'
define d_castneg 'define'
define d_static_inline 'undef'
define d_stdstdio 'undef'
define d_stdio_cnt_lval 'undef'
define d_stdio_ptr_lval 'undef'
define d_stdio_ptr_lval_nochange_cnt 'undef'
define d_stdio_ptr_lval_sets_cnt 'undef'
define d_stdiobase 'undef'
define d_charvspr 'undef'
define d_eofnblk 'define'
define d_printf_format_null 'define'
define d_const 'define'
define d_csh 'undef'
define d_suidsafe 'undef'
define d_dosuid 'undef'
define d_flexfnam 'define'
define d_phostname 'undef'
define d_bsdgetpgrp 'undef'
define d_bsdsetpgrp 'undef'
define d_shmatprototype 'define'
define d_mymalloc 'undef'
define d_strctcpy 'define'
define d_pseudofork 'undef'
define d_dlsymun 'undef'
define d_fcntl_can_lock 'undef'
define d_sprintf_returns_strlen 'define'
define d_u32align 'undef'
define d_dir_dd_fd 'undef'
define d_old_pthread_create_joinable 'undef'
define d_oldpthreads 'undef'
define d_nv_zero_is_allbits_zero 'define'
define d_stdio_stream_array 'undef'
define d_faststdio 'undef'
define d_libm_lib_version 'undef'
define d_localtime_r_needs_tzset 'define'
define signal_t 'void'
define d_portable 'define'
define d_voidtty 'define'
define d_semctl_semid_ds 'define'
define d_semctl_semun 'define'
define default_inc_excludes_dot 'undef'

define d_msg_ctrunc 'undef'
define d_msg_dontroute 'undef'
define d_msg_oob 'undef'
define d_msg_peek 'undef'
define d_msg_proxy 'undef'

define d_procselfexe 'undef'
define procselfexe '""'

define sGMTIME_max '2147483647'
define sGMTIME_min '-2147483648'
define sLOCALTIME_max '2147483647'
define sLOCALTIME_min '-2147483648'

# These should be in modules?
define netdb_hlen_type 'socklen_t'
define netdb_host_type 'const void *'
define netdb_name_type int
define netdb_net_type 'uint32_t'
define db_hashtype 'unsigned int'
define db_prefixtype 'size_t'
define db_version_major ''
define db_version_minor ''
define db_version_patch ''
define d_ndbm 'undef'
define d_ndbm_h_uses_prototypes 'define'
define d_gdbm_ndbm_h_uses_prototypes 'define'
define d_gdbmndbm_h_uses_prototypes 'define'

# These probably affect something in some cases but we don't test them
define afs 'false'
define afsroot '/afs'
define baserev 5.0
define bin_ELF 'define' # XXX safe default is 'undef'
define castflags 0
define ccsymbols ''
define charbits 8
define cpp_stuff 42
define cppccsymbols
define eagain 'EAGAIN'
define ebcdic 'undef'
define gccosandvers ''
define gnulibc_version '' # not tested for
define mips_type ''
define multiarch 'undef'
define perl_static_inline 'static'
define phostname hostname
define stdchar char
define stdio_base
define stdio_bufsiz
define stdio_cnt
define stdio_filbuf
define stdio_ptr
define stdio_stream_array
define d_lc_monetary_2008 'undef'

define sharpbang '#!'
define startperl "$sharpbang$perlpath"

# Non-toolchain commands; not used by perl-cross
define ansi2knr
define aphostname /bin/hostname
define awk awk
define bash bash
define bison bison
define byacc byacc
define cat cat
define chgrp chgrp
define chmod chmod
define chown chown
define comm comm
define contains grep
define cp cp
define cpio cpio
define csh '' # do keep this disabled
define date date
define dtrace
define echo echo
define egrep egrep
define emacs
define expr expr
define find
define flex
define full_ar ar
define full_csh csh
define full_sed sed
define gmake gmake
define grep grep
define groupcat 'cat /etc/group'
define gzip gzip
define hostcat 'cat /etc/hosts'
define inews # unused
define issymlink "test -h"
define ksh
define less less
define lint # unused
define ln 'ln'
define lns "$ln -s"
define lp
define lpr
define ls ls
define mail
define mailx
define make make
define mkdir mkdir # unused
define more more
define mv
define nroff nroff
define pager less
define passcat 'cat /etc/passwd'
define pg pg # unused
define pmake # unused
define pr # unused
define rm rm # unused
define rm_try # unused
define rmail # unused
define runnm false # unused
define sed sed # unused
define sendmail
define sh /bin/sh
define shar # unused
define sleep # unused
define smail # unused
define sort sort
define tail
define tar
define tee
define test test
define touch touch
define tr tr
define trnl '\n'
define troff
define uuname
define vi
define zcat
define zip zip
define tbl
define uname uname
define uniq uniq
define yacc yacc
define yaccflags ''

# These make sense in mainline perl build system but not in perl-cross
define archname64
define archobjs
define ccname
define compress
define cryptlib
define eunicefix ':'
define firstmakefile 'Makefile'
define from :
define gccansipedantic
define hint 'default'
define ignore_versioned_solibs
define incpath
define initialinstalllocation ''
define libc
define libsfiles
define libsfound
define libspath
define lkflags
define locincpth
define loclibpth
define make_set_make '#'
define mallocobj
define mallocsrc
define mistrustnm
define n '-n'
define orderlib
define perl
define perl5
define run 'false'
define shrpenv
define shsharp 'true'
define sockethdr
define socketlib
define src ''
define strings
define sysman ''
define targetsh "$sh"
define timeincl
define to ':'
define usrinc
define versiononly 'undef'
define xlibpth ''

# Deprecated symbols
define exe_ext ''
define obj_ext .o
define lib_ext .a
define path_sep ':'
define line
define submit
