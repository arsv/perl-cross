# Some extra compile/link tests

# checkvar symbol name includes
# We use try_link here instead of try_compile to be sure we have the
# variable in question not only declared but also present somewhere in the libraries.
checkvar() {
	require 'cc'
	mstart "Checking for $2"
	if not hinted "$1" 'found' 'not found'; then
		try_start
		try_includes $3
		try_add "void foo() { };"
		try_add "int main() { foo($2); return 0; }"
		try_link
		resdef $1 'found' 'not found'
	fi
}

checkintdefined() {
	mstart "Checking whether $2 is defined"
	if not hinted "$1" 'yes' 'no'; then
		try_start
		try_includes $3
		try_add "int i = $2;"
		try_compile
		resdef $1 'yes' 'no'
	fi
}

checkvar d_syserrlst sys_errlist 'stdio.h'
checkvar d_sysernlst sys_errnolist 'stdio.h'
checkvar d_tzname tzname 'time.h'

checkintdefined d_dbl_dig DBL_DIG 'limits.h float.h'
checkintdefined d_ldbl_dig LDBL_DIG 'limits.h float.h'
checkintdefined d_scm_rights SCM_RIGHTS 'sys/socket.h sys/un.h'

mstart "Checking whether closedir is void"
if [ "$d_closedir" = 'define' ]; then
	if not hinted d_void_closedir 'yes' 'no'; then
		try_start
		try_includes 'sys/types.h' 'dirent.h'
		try_add "int main() { return $1($2); }"
		try_compile
		resdef d_void_closedir 'yes' 'no'
	fi
else
	define d_void_closedir 'undef'
	result 'irrelevant'
fi

mstart "Checking whether prctl supports PR_SET_NAME"
if [ "$d_prctl" = 'define' ]; then
	if not hinted d_prctl_set_name 'yes' 'no'; then
		try_start
		try_includes 'sys/prctl.h'
		try_add "int main (int argc, char *argv[]) {"
		try_add "	return (prctl (PR_SET_NAME, \"Test\"));"
		try_add "}"
		try_compile
		resdef d_prctl_set_name 'yes' 'no' 
	fi
else
	define 'd_prctl_set_name' 'undef'
	result 'irrelevant'
fi

mstart "Checking if we're using GNU libc"
if not hinted d_gnulibc 'yes' 'no'; then
	try_start
	try_add '#include <stdio.h>'
	try_add "#ifndef __GLIBC__"
	try_add "#error here"
	try_add "#endif"
	try_compile
	resdef d_gnulibc 'yes' 'no'
fi
