# Some extra compile/link tests

# checkvar name includes [symbol]
# We use try_link here instead of try_compile to be sure we have the
# variable in question not only declared but also present somewhere in the libraries.
checkvar() {
	if [ -n "$4" ] ; then _s="$4"; else _s="d_$1"; fi

	require 'cc'
	mstart "Checking for $1"
	ifhintdefined "$_s" 'present' 'missing' && return $__

	try_start
	try_includes $2
	try_add "void foo() { };"
	try_add "int main() { foo($1); return 0; }"
	try_link
	resdef 'found' 'not found' "$_s"
}

isvoid() {
	require 'cc'
	mstart "Checking whether $1 is void"
	ifhint "d_$1" && return

	try_start
	try_includes $3
	try_add "int main() { return $1($2); }"
	not try_compile
	resdef 'yes' 'no' "d_void_$1"
}

checkintdefined() {
	k=`echo "$1" | tr A-Z a-z | sed -e 's/^/d_/'`
	mstart "Checking whether $1 is defined"
	ifhint "$k" && return 0
	try_start
	try_includes $2
	try_add "int i = $1;"
	try_compile
	resdef 'yes' 'no' $k
}

isvoid closedir "NULL" 'sys/types.h dirent.h'
checkvar sys_errlist 'stdio.h'
checkvar tzname 'time.h'

checkintdefined DBL_DIG 'limits.h float.h'
checkintdefined LDBL_DIG 'limits.h float.h'

if [ "$d_prctl" = 'define' ]; then
	mstart "Checking whether prctl supports PR_SET_NAME"
	try_start
	try_includes 'sys/prctl.h'
	try_add "int main (int argc, char *argv[]) {"
	try_add "	return (prctl (PR_SET_NAME, \"Test\"));"
	try_add "}"
	try_compile
	resdef 'yes' 'no' 'd_prctl_set_name'
fi

mstart "Checking if we're using GNU libc"
if nothinted 'd_gnulibc'; then
	try_start
	try_add '#include <stdio.h>'
	try_add "#ifndef __GLIBC__"
	try_add "#error here"
	try_add "#endif"
	try_compile
	resdef 'yes' 'no' d_gnulibc
fi

# Extended test for fpclassify. Linking alone is not enough apparently,
# the constants must be defined as well.

# checkfpclass d_func func 'includes' D1 D2 D3 ....
checkfpclass() {
	_sym=$1
	_fun=$2
	_inc=$3

	mstart "Checking whether $_fun() is usable"
	if nothinted $_sym; then
		try_start
		try_includes $_inc
		try_add "int main(void) { return $_fun(0.0); }"
		shift; shift; shift;

		for c in $*; do
			try_add "int v_$c = $c;"
		done

		if try_link; then
			setvar "$_sym" 'define'
			result 'yes'
		else
			setvar "$_sym" 'undef'
			result "no, disabling $_fun()"
		fi
	fi
}

checkfpclass d_fpclassify fpclassify 'math.h' \
	FP_NAN FP_INFINITE FP_NORMAL FP_SUBNORMAL FP_ZERO

checkfpclass d_fpclass fpclass 'math.h ieeefp.h' \
	FP_SNAN FP_QNAN FP_NEG_INF FP_POS_INF FP_NEG_INF \
	FP_NEG_NORM FP_POS_NORM FP_NEG_NORM FP_NEG_DENORM FP_POS_DENORM \
	FP_NEG_DENORM FP_NEG_ZERO FP_POS_ZERO FP_NEG_ZERO
