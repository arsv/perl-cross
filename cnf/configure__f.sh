#!/bin/bash

# General-purpose functions used by most of other modules

# Note: one-letter variables are "local"

function die {
	echo "ERROR: $*" >> $cfglog
	echo "ERROR: $*" >&2
	exit 255
}

# note: setvar()s should preceede result() to produce a nice log
function result {
	echo "Result: $*" >> $cfglog
	echo >> $cfglog
	echo "$@" >&2
}

function log {
	echo -e "$@" >> $cfglog
}

function msg {
	echo -e "$@" >> $cfglog
	echo -e "$@" >&2
}

function run {
	echo "> $@" >> $cfglog
	"$@"
}

# Let user see the whole bunch of errors instead of stopping on the first
function fail {
	echo "ERROR: $*" >& 2
	fail=1
}

function failpoint {
	if [ -n "$fail" ]; then
		exit 255
	fi
}

function mstart {
	echo -e "$@" >> $cfglog
	echo -ne "$* ... " >& 2
}

# setenv name value
# emulates (incorrect in sh) statement $$1="$2"
function setenv {
	eval $1="'$2'"
}

# setvar name value
# emulates (incorrect in sh) statement $$1="$2"
function setvar {
	_x=`valueof "$1"`
	if [ "$_x" != "$2" ]; then
		eval $1="'$2'"
		log "Set $1='$2'"
	fi
}

# setvar for user-defined variables
# additional care is taken here to allow setting
# variables *not* listed in _gencfg
# $uservars keeps the list of user-set variables
# $x_(varname) is set to track putvar() calls for this variable
uservars=''
function setvaru {
	if [ -n "$uservars" ]; then
		uservars="$uservars $1"
	else
		uservars="$1"
	fi
	setenv "$1" "$2"
	setenv "u_$1" "$2"
	if [ -n "$3" ]; then
		setenv "x_$1" "$3"
	else
		setenv "x_$1" 'user'
	fi
	log "Set user $1='$2'"
}


# putvar name value
# writes given variable to config, and checks it as
# "written" if necessary (i.e. for user variables)
function putvar {
	_x=`valueof "x_$1"`
	test -n "$_x" && setenv "x_$1" 'written'
	echo "$1='$2'" >> $config
	setvar "$1" "$2"
}

function setifndef {
	v=`valueof "$1"`
	if [ -z "$v" ]; then
		setvar "$1" "$2"
	fi
}

# archlabel target targetarch -> label
function archlabel {
	if [ -n "$1" -a -n "$2" ]; then
		echo "$1 ($2)"
	elif [ -n "$2" ]; then
		echo "$2"
	elif [ -n "$1" ]; then
		echo "$1"
	else
		echo "unknown"
	fi
}

function setvardefault {
	v=`valueof "$1"`
	if [ -z "$v" ]; then
		setvar "$1" "$2"
	else
		setvar "$1" "$v"
	fi
}

# Was more meaningful in the past, but now just a stub.
function check {
	"$@"
}

function not { if "$@"; then false; else true; fi; }

function require {
	v=`valueof "$1"`
	if [ -z "$v" ]; then
		die "Required $1 is not set"
	fi
}

function symbolname {
	echo "$1" | sed -e 's/^\(struct\|enum\|union\|unsigned\) /s_/'\
		-e 's/\*/ptr/g' -e 's/\.h$//' -e 's/[^A-Za-z0-9_]//' \
		-e 's/^s_\(.*\)/\1_s/' -e 's/_//g' |\
		tr 'A-Z' 'a-z'
}

function try_start {
	echo -n > try.c
}

function try_includes {
	for i in "$@"; do 
		s=i_`symbolname "$i"`
		v=`valueof "$s"`
		if [ "$v" == 'define' ]; then
			echo "#include <$i>" >> try.c
		else 
			echo "/* <$i> missing */" >> try.c
		fi
	done
}

function try_add {
	echo "$@" >> try.c
}

function try_cat {
	cat "$@" >> try.c
}

function try_dump {
	cat try.c | sed -e 's/^/| /' >> $cfglog
}

function try_dump_out {
	cat try.out | sed -e 's/^/| /' >> $cfglog
}

function try_dump_h {
	cat try.h | sed -e 's/^/| /' >> $cfglog
}

function try_preproc {
	require 'cpp'
	#try_dump
	run $cpp $ccflags try.c > try.out 2>> $cfglog
}

function try_compile {
	require 'cc'
	require '_o'
	try_dump
	run $cc $ccflags "$@" -c -o try$_o try.c >> $cfglog 2>&1
}

# an equivalent of try_compile with -Werror, but without
# explicit use of -Werror (which may not be available for
# a given compiler)
function try_compile_check_warnings {
	require 'cc'
	require '_o'
	try_dump
	run $cc $ccflags -c -o try$_o try.c > try.out 2>&1
	_r=$?
	cat try.out >> $cfglog
	if [ $_r != 0 ]; then
		return 1;
	fi
	if grep -q -i 'warning' try.out; then
		return 1;
	fi
	return 0
}

function try_link_libs {
	require 'cc'
	try_dump
	run $cc $ccflags -o try$_e try.c $* >> $cfglog 2>&1
}

function try_link {
	try_link_libs $libs
}

function try_readelf {
	require 'readelf'
	require '_o'
	run $readelf $* try$_o
}

function try_objdump {
	require 'objdump'
	require '_o'
	run $objdump $* try.o > try.out
}

function isset {
	z=`valueof "$1"`
	if test -n "$z"; then
		log "Skipping check for $1, value already set ($z)"
		true
	else
		false
	fi
}

function bytes { if [ "$1" == 1 ]; then echo "byte"; else echo "bytes"; fi }

function valueof { eval echo "\"\$$1\""; }

# $1=$$2
function pullval {
	log "Setting $1 from $2"
	eval "$1=\"\$$2\""
}

function ifhint {
	h=`valueof "$1"`
	x=`valueof "x_$1"`
	test -z "$x" && x='preset'
	if test -n "$h"; then
		log "Value for $1: $h ($x)"
		result "($x) $h"
		return 0
	else
		return 1
	fi
}

function ifhintsilent {
	h=`valueof "$1"`
	x=`valueof "x_$1"`
	test -z "$x" && x='preset'
	if test -n "$h"; then
		log "Value for $1: $h ($x)"
		return 0
	else
		return 1
	fi
}

# just an alias for the above functions, to avoid awkward
# lines like "if ifhint"
function hinted {
	ifhint "$@"
}

function ifhintdefined {
	h=`valueof "$1"`
	x=`valueof "x_$1"`
	test -z "$x" && x='preset'
	if test -n "$h"; then
		if [ "$h" == 'define' ]; then
			log "Value for $1: $2 (yes, define) ($x)"
			result "($x) $2"
			__=0
		else
			log "Value for $1: $2 (no, undef) ($x)"
			result "($x) $3"
			__=1
		fi	
		return 0
	else
		return 1
	fi
}

# for use in if clauses
function nothinted { ifhint "$@" && return 1 || return 0; }
function nohintdefined { ifhintdefined "$@" && return 1 || return 0; }

# resdef result-yes result-no symbol symbol2
function resdef {
	if [ $? == 0 ]; then
		setvar "$3" "define"
		test -n "$4" && setvar "$4" 'define'
		result "$1"
		return 0
	else
		setvar "$3" 'undef'
		test -n "$4" && setvar "$4" 'undef'
		result "$2"
		return 1
	fi	
}

function modsymname {
	echo "$1" | sed -e 's!^\(ext\|cpan\|dist\|lib\)/!!' -e 's![:/-]!_!g' | tr A-Z a-z
}

# like source but avoid $PATH searches for simple file names
function sourcenopath {
	case "$1" in
		/*) source "$1" ;;
		*) source "./$1" ;;
	esac
}

# appendsvar vardst value-to-append
function appendvar {
	v=`valueof "$1"`
	if [ -n "$v" -a -n "$2" ]; then
		setvar "$1" "$v $2"
	elif [ -z "$v" -a -n "$2" ]; then
		setvar "$1" "$2"
	fi
}
