# General-purpose functions used by most of other modules

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

not() {
	if "$@"; then false; else true; fi;
}

run() {
	echo "> $@" >> $cfglog
	"$@"
}

# Darwin (OSX) shell lacks echo -n. Pretty much nything running on Darwin
# should be expected to support printf though.

case "`uname -s`" in
	Darwin)
		nonl() { printf "%s" "$1"; }
		;;
	*)
		nonl() { echo -n "$1"; }
		;;
esac

# Each test starts with mstart and ends with a (possibly branched) result
#
#    mstart "Checking foo"
#    if check; then
#        result "yes"
#    else
#        result "no"
#
# To make nice logs, any define()s should precede result()s.

mstart() {
	echo "$@" >> $cfglog
	nonl "$* ... " >& 2
}

result() {
	echo "Result: $*" >> $cfglog
	echo >> $cfglog
	echo "$@" >&2
}

# Indirect variable access ($a= and $$a), invalid in generic POSIX shells

setenv() {
	eval "$1='$2'"
}

getenv() {
	eval "$1=\$$2"
}

# Config variables are written to config.sh exactly once.
# The first define for a given key locks it by setting x_$key.
# Any subsequent defines for the same key are ignored.
# Hints and command-line arguments call define early,
# preventing regular code from setting the hinted values.
#
#     define key val [source]
#
# Appends (-A, stored in a_$key) are applied here as well.
# All written values are also duplicated in current environment
# to allow $key references later.

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

	v=`echo "$v" | sed -e "s@'@'\"'\"'@g"`
	echo "$1='$v'" >> $config

	log "Setting $1=$v"
}

# There are few variables that cannot be set immediately.
# Instead, they have predef 'initial-value', some conditional
# appends, and enddef that writes the value to config.sh.

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

# There is no point in running tests for values that have been hinted
# as define will skip them anyway.
#
#     mstart "Checking foo"
#     if not hinted d_foo; then
#         check d_foo 'foo' ...
#     fi
#
# Like with resdef below, some define/undef variables need yes/no
# or found/missing results shown. That's why $3 and $4 are there.

hinted() {
	getenv v "$1"
	getenv x "x_$1"

	test -z "$x" && return 1

	log "Using $1=$v ($x)"

	if [ -n "$3" -a "$v" = 'define' ]; then
		result "($x) $3"
	elif [ -n "$4" -a "$v" != 'define' ]; then
		result "($x) $4"
	else
		result "($x) $v"
	fi
}

# Thread-safe func tests define two symbols per test, and need a way
# to check hints silently to avoid calling result() too early.

gethint() {
	getenv x "x_$1"
	test -z "$x" && return 1
	getenv $2 "$1"
}

# All compile/link tests operate on try.c. Typical sequence is try_start,
# try_add, try_add, ..., try_compile. The test code gets dumped to config.log,
# along with the command used to compile it.

try_start() {
	true > try.c
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
	run $cpp $cppflags try.c > try.out 2>> $cfglog
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

# Sanity check, make sure variables like $o and $cc are defined
# before doing stuff like rm try$o or $cc -o try$o

require() {
	getenv v "$1"
	test -z "$v" && die "Requires $1 is not set"
}

# Set symbols depending on the result of preceeding command.
# The values set are always define/undef but the results shown
# are sometimes yes/no or found/missing etc.

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

bytes() {
	test "$1" = 1 && echo "byte" || echo "bytes"
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

# Disabling e.g. ext/XS-Typemap is done by setting $disable_xs_typemap,
# which is then checked in configure_mods.

modsymname() {
	echo "$1" | sed -r -e 's!^(ext|cpan|dist|lib)/!!' -e 's![:/-]!_!g' | tr A-Z a-z
}
