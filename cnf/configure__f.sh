# General-purpose functions used by most of other modules

# Note: one-letter variables are "local"

die() {
	echo "ERROR: $*" >> $cfglog
	echo "ERROR: $*" >&2
	exit 255
}

log() {
	echo "$@" >> $cfglog
}

msg() {
	echo "$@" >> $cfglog
	echo "$@" >&2
}

mstart() {
	echo "$@" >> $cfglog
	echo -n "$* ... " >& 2
}

# note: setvar()s should preceede result() to produce a nice log
result() {
	echo "Result: $*" >> $cfglog
	echo >> $cfglog
	echo "$@" >&2
}

run() {
	echo "> $@" >> $cfglog
	"$@"
}

not() {
	if "$@"; then false; else true; fi;
}

setenv() {
	eval "$1='$2'"
}

getenv() {
	eval "$1=\$$2"
}


define() {
	getenv x "x_$1"
	getenv a "a_$1"
	getenv v "$1"

	if [ -n "$x" ]; then
		log "Skipping $1=$2 ($x: $v)"
		return
	fi

	if [ -n "$a" -a -n "$2" ]; then
		v="$2 $a"
	elif [ -n "$2" ]; then
		v="$2"
	elif [ -n "$a" ]; then
		v="$a"
	fi

	setenv "x_$1" "${3:-written}"
	setenv "$1" "$v"

	v=`echo "$2" | sed -e "s@'@'\"'\"'@g"`
	echo "$1='$v'" >> $config
}

predef() {
	getenv x "x_$1"
	test -n "$x" && return
	setenv "$1" "$2"
	setenv "x_$1" "predef"
}

enddef() {
	getenv x "x_$1"
	getenv v "$1"

	if [ -z "$x" -o "$x" = 'predef' ]; then
		setenv "$1" ''
		setenv "x_$1" ''
		define "$1" "$v"
	else
		log "Skipping $1 ($x: $v)"
	fi
}

append() {
	getenv x "x_$1"
	getenv v "$1"
	if [ "$x" != 'predef' ]; then
		log "Skipping $1 <= $2 ($x: $v)"
	elif [ -n "$v" -a -n "$2" ]; then
		setenv "$1" "$v $2"
	elif [ -z "$v" -a -n "$2" ]; then
		setenv "$1" "$2"
	fi
}

prepend() {
	getenv x "x_$1"
	getenv v "$1"
	if [ "$x" != 'predef' ]; then
		log "Skipping $1 >= $2 ($x: $v)"
	elif [ -n "$v" -a -n "$2" ]; then
		setenv "$1" "$2 $v"
	elif [ -z "$v" -a -n "$2" ]; then
		setenv "$1" "$2"
	fi
}

hinted() {
	setenv v "$1"
	setenv x "x_$1"

	test -n "$x" && return 1

	log "Using $1=$v ($x)"

	if [ -n "$3" -a "$v" = 'define' ]; then
		result "($x) $3"
	elif [ -n "$4" -a "$v" != 'define' ]; then
		result "($x) $4"
	else
		result "($x) $h"
	fi
}

# archlabel target targetarch -> label
archlabel() {
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

try_start() {
	echo -n > try.c
}

try_includes() {
	for i in "$@"; do
		echo "#include <${i##*:}>" >> try.c
	done
}

try_add() {
	echo "$@" >> try.c
}

try_cat() {
	cat "$@" >> try.c
}

try_dump() {
	cat try.c | sed -e 's/^/| /' >> $cfglog
}

try_dump_out() {
	cat try.out | sed -e 's/^/| /' >> $cfglog
}

try_dump_h() {
	cat try.h | sed -e 's/^/| /' >> $cfglog
}

try_preproc() {
	require 'cpp'
	run $cc $ccflags -E -P try.c > try.out 2>> $cfglog
}

try_compile() {
	require 'cc'
	require '_o'
	try_dump
	run $cc $ccflags "$@" -c -o try$_o try.c >> $cfglog 2>&1
}

# an equivalent of try_compile with -Werror, but without
# explicit use of -Werror (which may not be available for
# a given compiler)
try_compile_check_warnings() {
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

try_link_libs() {
	require 'cc'
	try_dump
	run $cc $ccflags -o try$_e try.c $* >> $cfglog 2>&1
}

try_link() {
	try_link_libs $libs $*
}

try_readelf() {
	require 'readelf'
	require '_o'
	run $readelf $* try$_o
}

try_objdump() {
	require 'objdump'
	require '_o'
	run $objdump $* try.o > try.out
}

bytes() {
	test "$1" = 1 && echo "byte" || echo "bytes"
}

resdef() {
	if [ $? = 0 ]; then
		define "$1" "define"
		result "$2"
		return 0
	else
		define "$1" 'undef'
		result "$3"
		return 1
	fi
}

modsymname() {
	echo "$1" | sed -r -e 's!^(ext|cpan|dist|lib)/!!' -e 's![:/-]!_!g' | tr A-Z a-z
}

require() {
	getenv v "$1"
	test -z "$v" && die "Requires $1 is not set"
}
