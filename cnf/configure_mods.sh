#!/bin/sh

#function log { echo "$@"; }
#function msg { echo -e "$@"; }
#function modsymname {
#	echo "$1" | sed -e 's![:/]!_!g' | tr A-Z a-z
#}
#function valueof { eval echo "\"\$$1\""; }

function extrec {
	for i in *; do
		if [ -f "$i/$i.c" -o -f "$i/$i.xs" ]; then
			extadd "xs" "$1$i"
		elif [ -f "$i/Makefile.PL" ]; then
			extadd "noxs" "$1$i"
		elif [ -d "$i" -a $# -lt 10 ]; then
			cd "$i" && extrec "$i/" "$@" && cd ..
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
		return
	fi
	d=`valueof "disable_$s"`
	if [ -n "$d" -a "$d" != "0" ]; then
		msg "\tdisabled $2"
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

function extonlyif {
	n="$1"; shift
	s=`modsymname "$n"`
	if [ "$@" ]; then
		return
	else
		log "pre-disabling $s"
		eval "disable_$s=1"
	fi

}

msg "Looking for extensions"

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

if [ -n "$onlyext" ]; then
	for e in $onlyext; do
		s=`modsymname "$e"`
		log "only-enabled $s"
		eval "only_$s=1"
	done
fi

log "recursive under ext/"
cd ext && extrec && cd ..

msg
