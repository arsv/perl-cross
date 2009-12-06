#!/bin/sh

if [ "$mode" == "buildmini" ]; then
	V="HOST"
else
	V=''
fi

# setfromvar what SHELLVAR
function setfromvar {
	v=`valueof "$1"`
	w=`valueof "$V$2"`
	if [ -z "$v" -a -n "$w" ]; then
		log "Using $V$2 for $1"
		setvar "$1" "$w"
	fi
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


setfromvar cc CC
setfromvar cflags CFLAGS
setfromvar cppflags CPPFLAGS
setfromvar ld LD
setfromvar ldflags LDFLAGS
setfromvar ar AR
setfromvar ranlib RANLIB
setfromvar objdump OBJDUMP
appendvar cflags "$ccdefines"
appendvar ccflags "$cflags"
