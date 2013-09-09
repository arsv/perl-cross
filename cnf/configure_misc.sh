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

mstart "Checking whether ld supports scripts"
if not hinted 'ld_can_script'; then
	cat > try.c <<EOM
void foo() {}
void bar() {}
EOM
	cat > try.h <<EOM
LIBTEST_42 {
 global:
  foo;
 local: *;
 };
EOM
	log "try.c"
	try_dump
	log "try.h"
	try_dump_h
	rm -f a.out 2>/dev/null
	# Default values are set in _genc, but here we need one much earlier
	if [ ! -z "$lddlflags" ]; then
		_lddlflags="$lddlflags"
	else
		_lddlflags=' -shared'
	fi
	if run $cc $cccdlflags $ccdlflags $ccflags $ldflags $_lddlflags -o a.out try.c \
		-Wl,--version-script=try.h >/dev/null 2>&1 \
		&&  test -s a.out 
	then
		setvar ld_can_script 'define'
		result "yes"
	else
		setvar ld_can_script 'undef'
		result "no"
	fi
fi

if [ "$usethreads" == 'define' ]; then
	mstart 'Looking whether to use interpreter threads'
	if [ "$useithreads" == 'define' ]; then
		setvar 'useithreads' 'define'
		result 'yes, using ithreads'	
	elif [ "$use5005threads" == 'define' ]; then
		setvar 'useithreads' 'undef'
		result 'no, using 5.005 threads'
	else 
		setvar 'useithreads' 'define'
		result 'yes, using ithreads'	
	fi
	log
fi
