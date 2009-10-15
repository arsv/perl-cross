#!/bin/sh

# General-purpose functions used by most of other modules

# Note: one-letter variables are "local"

function die {
	echo "ERROR: $*" >> $cfglog
	echo "ERROR: $*" >&2
	exit -1
}

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
		exit -1
	fi
}

function mstart {
	echo "$@" >> $cfglog
	echo -n "$* ... " >& 2
}

# setvar name value
# emulates (incorrect in sh) statement $$1="$2"
function setvar {
	eval $1="'$2'"
	log "Set $1='$2'"
}

# putvar name value
# just writes given variable to config
function putvar {
	echo "$1='$2'" >> $config
	setvar "$1" "$2"
}

function setifndef {
	v=`valueof "$1"`
	if [ -z "$v" ]; then
		setvar "$1" "$2"
	fi
}

# default name value
function default {
	v=`valueof "$1"`
	if [ -z "$v" ]; then
		putvar "$1" "$2"
	else
		putvar "$1" "$v"
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
	echo "$1" | sed -e 's/^\(struct|enum|union|unsigned\) /s_/'\
		-e 's/\*/ptr/g' -e 's/\.h$//' -e 's/[^A-Za-z0-9_]//' |\
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

function try_dump {
	cat try.c | sed -e 's/^/| /' >> $cfglog
}

function try_dump_out {
	cat try.out | sed -e 's/^/| /' >> $cfglog
}

function try_preproc {
	require 'cpp'
	#try_dump
	run $cpp $cflags try.c > try.out 2>> $cfglog
}

function try_compile {
	require 'cc'
	require '_o'
	try_dump
	run $cc $cflags -c -o try$_o try.c >> $cfglog 2>&1
}

function try_link_libs {
	require 'cc'
	try_dump
	run $cc $cflags -o try$_e try.c $* >> $cfglog 2>&1
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
	if test -n "$h"; then
		log "Hint for $1: $h"
		result "(hinted) $h"
		return 0
	else
		return -1
	fi
}

function ifhintdefined {
	h=`valueof "$1"`
	if test -n "$h"; then
		log "Hint for $1: $h"
		if [ "$h" == 'define' ]; then
			log "Hint for $1: $2 (yes, define)"
			result "(hinted) $2"
			__=0
		else
			log "Hint for $1: $2 (no, undef)"
			result "(hinted) $3"
			__=-1
		fi	
		return 0
	else
		return -1
	fi
}

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
		return -1
	fi	
}

function modsymname {
	echo "$1" | sed -e 's![:/]!_!g' | tr A-Z a-z
}
