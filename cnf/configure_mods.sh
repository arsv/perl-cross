#!/bin/bash

# Since 5.10.1 the module dirs are flat, so there's no need
# for recursive search etc.
function extdir {
	for i in $1/*; do
		L=`basename "$i" | sed -e 's!.*-!!'`
		if [ "$L" == "DynaLoader" ]; then
			# do nothing, it's DynaLoader
			true
		elif [ -f "$i/$L.c" -o -f "$i/$L.xs" ]; then
			extadd "xs" "$i"
		elif [ -f "$i/Makefile.PL" -o -f "$i/Makefile" -o -d "$i/lib" ]; then
			extadd "noxs" "$i"
		fi
	done
}

function extadd {
	s=`modsymname "$2"`
	if [ "$s" == "dynaloader" ]; then
		msg "\tskipping $2"
		return
	fi
	o=`valueof "only_$s"`
	if [ -n "$onlyext" -a -z "$o" ]; then
		msg "\tskipping $2"
		extadddisabled "$1" "$2"
		return
	fi
	d=`valueof "disable_$s"`
	if [ -n "$d" -a "$d" != "0" ]; then
		msg "\tdisabled $2"
		extadddisabled "$1" "$2"
		return
	fi
	t=`valueof "static_$s"`
	if [ "$1" == "xs" -a -n "$t" -a "$t" != "0" ]; then
		msg "\tstatic $2"
		static_ext="$static_ext$2 "
	elif [ "$1" == "xs" ]; then
		msg "\tdynamic $2"
		dynamic_ext="$dynamic_ext$2 "
	else 
		msg "\tnon-xs $2"
		nonxs_ext="$nonxs_ext$2 "
	fi
}

function extadddisabled {
	s=`modsymname "$2"`
	if [ "$1" == "xs" ]; then
		disabled_dynamic_ext="$disabled_dynamic_ext$2 "
	else
		disabled_nonxs_ext="$disabled_nonxs_ext$2 "
	fi
}

function extonlyif {
	n="$1"; shift
	s=`modsymname "$n"`
	if [ "$@" ]; then
		return
	else
		log "pre-disabling $s"
		msg "\tpre-disabling $s"
		eval "disable_$s=1"
	fi

}

msg "Looking which extensions should be disabled"

extonlyif DB_File "$i_db" == 'define'
extonlyif GDBM_File "$i_gdbm" == 'define'
extonlyif NDBM_File "$i_ndbm" == 'define'
extonlyif ODBM_File "$i_odbm" == 'define'
extonlyif I18N/Langinfo "$i_langinfo" == 'define' -a "$d_nl_langinfo" == 'define'
extonlyif IPC/SysV "$i_msg" == 'define' -o "$i_shm" == 'define' -o "$d_sem" == 'define'
extonlyif Opcode "$useopcode" == 'define'
extonlyif POSIX "$useposix" == 'true'
extonlyif Socket "$d_socket" == 'define'
extonlyif Sys/Syslog "$d_socket" == 'define'
extonlyif Thread "$usethreads" == 'define'
extonlyif XS/APItest "$usedl" == 'define'
extonlyif XS/Typemap "$usedl" == 'define'
extonlyif VMS-DCLsym "$osname" == "vms"		# XXX: is it correct?
extonlyif VMS-Stdio "$osname" == "vms"
extonlyif Sys-Hostname "true" == "false"	# XXX: MakeMaker fails here

for d in ext cpan dist; do
	msg "Looking for extensions recursively under $d/"
	extdir $d
done

msg
msg "Static modules: $static_ext"
msg "Non-XS modules: $nonxs_ext"
msg "Dynamic modules: $dynamic_ext"

if [ -z "$disabledmods" ]; then
	# see configure_args on how to undef it
	# see configure_genc for its only effect within configure
	disabledmods='define'
fi
