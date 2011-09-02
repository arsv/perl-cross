#!/bin/bash

# Some final tweaks that do not fit in any other file

# Use $ldflags as default value for $lddlflags, together with whatever
# hints provided, but avoid re-setting anyting specified in the command line
if [ -n "$ldflags" -a "$x_lddlflags" != "user" ]; then
	msg "Checking which flags from \$ldflags to move to \$lddlflags"
	for f in $ldflags; do 
		case "$f" in
			-L*|-R*|-Wl,-R*)
				msg "\tadded $f"
				appendvar 'lddlflags' "$f"
				;;
		esac
	done
fi

if not hinted 'uselargefiles'; then
	# Adding -D_FILE_OFFSET_BITS is mostly harmless, except
	# when dealing with uClibc that was compiled w/o largefile
	# support
	mstart "Checking whether it's ok to enable large file support"
	case "$ccflags" in
		*-D_FILE_OFFSET_BITS=*)
			result "already there"
			;;
		*)
			try_start
			try_includes "stdio.h"
			try_compile -D_FILE_OFFSET_BITS=64
			resdef "yes, enabling it" "no, it's disabled" 'uselargefiles' 
	esac
fi
if [ "$uselargefiles" == 'define' ]; then
	appendvar 'ccdefines' " -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64"
fi
if [ "$usedl" == 'undef' -a -z "$allstatic" ]; then
	msg "DynaLoader is disabled, making all modules static"
	setvar 'allstatic' 1
fi
