# In-tree perl modules discovery.

# Some of the tests use $Config{'extensions'} to decide whether to do their
# thing or not. The original Configure uses weird old format for module names,
# "File/Glob" for what should have been either File::Glob or ext/File-Glob.
#
# We have to keep those for compatibility, but we also need directory names
# to use in makefiles. The code below builds both kinds of module lists at
# once, the perl-compatible set (extensions, known_extensions, static_ext etc)
# and the set the Makefiles will use (fullpath_*_ext and disabled_*_ext).

test "$mode" = 'buildmini' && return

# See also: modsymname in configure__f.sh

modvarname() {
	echo "$1" | sed -r -e 's!^(ext|cpan|dist|lib)/!!' -e 's!-!/!g'
}

# Since 5.10.1 the module dirs are flat, so there's no need
# for recursive search etc.
extdir() {
	for i in $1/*; do
		L=`echo ${i##*/} | sed -e 's!.*-!!'`
		if [ "$L" = "DynaLoader" ]; then
			# do nothing, it's DynaLoader
			true
		# just checking $i/$L.xs is NOT enough, since some extensions
		# like cpan/List-Util have .xs files with different names
		elif ls "$i" | grep -qE '.(xs|c)$'; then
			extadd "xs" "$i"
		elif [ -f "$i/Makefile.PL" -o -f "$i/Makefile" -o -d "$i/lib" -o -f "$i/$L.pm" ]; then
			extadd "noxs" "$i"
		fi
	done
}

extadddisabled() {
	if [ "$1" = "xs" ]; then
		disabled_dynamic_ext="$disabled_dynamic_ext$2 "
	else
		disabled_nonxs_ext="$disabled_nonxs_ext$2 "
	fi
}

extadd() {
	s=`modsymname "$2"`
	n=`modvarname "$2"`

	if [ "$s" = "dynaloader" ]; then
		msg "    skipping $2"
		return
	fi

	known_extensions="$known_extensions$n "

	getenv o "only_$s"
	if [ -n "$onlyext" -a -z "$o" ]; then
		msg "    skipping $2"
		extadddisabled "$1" "$2"
		return
	fi

	getenv d "disable_$s"
	if [ -n "$d" -a "$d" != "0" ]; then
		msg "    disabled $2"
		extadddisabled "$1" "$2"
		return
	fi

	extensions="$extensions$n "

	getenv t "static_$s"
	if [ "$1" = "xs" -a -n "$t" -a "$t" != "0" ]; then
		msg "    static $2"
		static_ext="$static_ext$n "
		fullpath_static_ext="$fullpath_static_ext$2 "
	elif [ "$1" = "xs" -a -n "$allstatic" ]; then
		msg "    static $2"
		static_ext="$static_ext$n "
		fullpath_static_ext="$fullpath_static_ext$2 "
	elif [ "$1" = "xs" ]; then
		msg "    dynamic $2"
		dynamic_ext="$dynamic_ext$n "
		fullpath_dynamic_ext="$fullpath_dynamic_ext$2 "
	else 
		msg "    non-xs $2"
		nonxs_ext="$nonxs_ext$n "
		fullpath_nonxs_ext="$fullpath_nonxs_ext$2 "
	fi
	# See also: findext.patch
	if [ "$2" = "cpan/Scalar-List-Utils" ]; then
		shadow_ext="${shadow_ext}cpan/List-Util "
	fi
}

extonlyif() {
	m="$1"; shift
	s=`modsymname "$m"`
	if [ "$@" ]; then
		return
	else
		log "pre-disabling $s"
		msg "    pre-disabling $s"
		eval "disable_$s=1"
	fi

}

definetrimspaces() {
	v=`echo "$2" | sed -r -e 's/\s+/ /g' -e 's/^\s+//' -e 's/\s+$//'`
	define $1 "$v"
}

msg "Looking which extensions should be disabled"

# These are on unless hinted otherwise
define useposix 'true'
define useopcode 'true'

extonlyif Devel-NYTProf "$i_zlib" = 'define'
extonlyif DB_File "$i_db" = 'define'
extonlyif GDBM_File "$i_gdbm" = 'define'
extonlyif NDBM_File "$i_ndbm" = 'define'
extonlyif ODBM_File "$i_odbm" = 'define'
extonlyif I18N/Langinfo "$i_langinfo" = 'define' -a "$d_nl_langinfo" = 'define'
extonlyif IPC/SysV "$i_msg" = 'define' -o "$i_shm" = 'define' -o "$d_sem" = 'define'
extonlyif Opcode "$useopcode" = 'true'
extonlyif POSIX "$useposix" = 'true'
extonlyif Socket "$d_socket" = 'define'
extonlyif Sys/Syslog "$d_socket" = 'define'
extonlyif cpan/List-Util "$usedl" != 'undef'
extonlyif XS/APItest "$usedl" = 'define'
extonlyif XS/Typemap "$usedl" = 'define'
extonlyif VMS-DCLsym "$osname" = "vms"		# XXX: is it correct?
extonlyif VMS-Stdio "$osname" = "vms"
extonlyif VMS-Filespec "$osname" = "vms"
extonlyif Amiga-ARexx "$osname" = "amiga"
extonlyif Amiga-Exec "$osname" = "amiga"
extonlyif Win32 "$osname" = 'win32'		# XXX: or is it mingw32?
extonlyif Win32API-File "$osname" = 'win32'
extonlyif Win32CORE "$osname" = 'win32'

extonlyif Thread "$usethreads" = 'define'

unset extensions known_extensions
unset nonxs_ext static_ext dynamic_ext shadow_ext
unset fullpath_nonxs_ext fullpath_dynamic_ext fullpath_static_ext
unset disabled_nonxs_ext disabled_dynamic_ext

for d in ext cpan dist; do
	msg "Looking for extensions recursively under $d/"
	extdir $d
done

msg
msg "Static modules: $static_ext"
msg "Non-XS modules: $nonxs_ext"
msg "Dynamic modules: $dynamic_ext"

definetrimspaces static_ext "$static_ext"
definetrimspaces nonxs_ext "$nonxs_ext"
definetrimspaces dynamic_ext "$dynamic_ext"
definetrimspaces known_extensions "$known_extensions"

definetrimspaces fullpath_static_ext "$fullpath_static_ext"
definetrimspaces fullpath_nonxs_ext "$fullpath_nonxs_ext"
definetrimspaces fullpath_dynamic_ext "$fullpath_dynamic_ext"

definetrimspaces disabled_dynamic_ext "$disabled_dynamic_ext"
definetrimspaces disabled_nonxs_ext "$disabled_nonxs_ext"

definetrimspaces extensions "$extensions"
