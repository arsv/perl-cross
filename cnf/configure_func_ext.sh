# Some extra compile/link tests

# checkvar symbol name includes
# We use try_link here instead of try_compile to be sure we have the
# variable in question not only declared but also present somewhere in the libraries.
checkvar() {
	require 'cc'
	mstart "Checking for $2"
	if nothinted "$1"; then
		try_start
		try_includes $3
		try_add "void foo() { };"
		try_add "int main() { foo($2); return 0; }"
		try_link
		resdef 'found' 'not found' "$1"
	fi
}

checkintdefined() {
	mstart "Checking whether $2 is defined"
	if nothinted "$1"; then
		try_start
		try_includes $3
		try_add "int i = $2;"
		try_compile
		resdef 'yes' 'no' $1
	fi
}

checkvar d_syserrlst sys_errlist 'stdio.h'
checkvar d_tzname tzname 'time.h'

checkintdefined d_dbl_dig DBL_DIG 'limits.h float.h'
checkintdefined d_ldbl_dig LDBL_DIG 'limits.h float.h'

mstart "Checking whether closedir is void"
if [ "$d_closedir" = 'define' ]; then
	if nothinted "d_void_closedir"; then
		try_start
		try_includes 'sys/types.h' 'dirent.h'
		try_add "int main() { return $1($2); }"
		if try_compile; then
			setvar 'd_void_closedir' 'undef'
			result 'no'
		else
			setvar 'd_void_closedir' 'undef'
			result 'yes'
		fi
	fi
else
	setvar 'd_void_closedir' 'undef'
	result 'irrelevant'
fi

mstart "Checking whether prctl supports PR_SET_NAME"
if [ "$d_prctl" = 'define' ]; then
	if nothinted 'd_prctl_set_name'; then
		try_start
		try_includes 'sys/prctl.h'
		try_add "int main (int argc, char *argv[]) {"
		try_add "	return (prctl (PR_SET_NAME, \"Test\"));"
		try_add "}"
		try_compile
		resdef 'yes' 'no' 'd_prctl_set_name'
	fi
else
	setvar 'd_prctl_set_name' 'undef'
	result 'irrelevant'
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
