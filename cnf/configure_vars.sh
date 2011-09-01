#!/bin/bash

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

setfromvar cc CC
setfromvar ccflags CFLAGS
setfromvar cppflags CPPFLAGS
setfromvar ld LD
setfromvar ldflags LDFLAGS
setfromvar ar AR
setfromvar ranlib RANLIB
setfromvar objdump OBJDUMP
