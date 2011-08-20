#!/bin/bash

# Names of some variables in original configure are shortened
# (e.g. i_niin for <netinet/in.h>), and it breaks strict pattern
# used here. To resolve this, we'll "link" new names to old shorter
# (pull possibly set value from one to another).

# It's possible to make has* functions set several variables at once,
# but this complicates hint/cache reporting and processing.

# linkvar old new
function linkvar {
	eval _v1="\"\$$1\""
	eval _v2="\"\$$2\""
	if [ -z "$_v1" ]; then
		setvar "$1" "$_v2"
	fi
}

linkvar longdblsize longdoublesize

linkvar i_sysresrc i_sysresource
linkvar i_sysselct i_sysselect
linkvar i_niin i_netinetin

linkvar d_endhent d_endhostent
linkvar d_endnent d_endnetent
linkvar d_endpent d_endprotoent
linkvar d_endsent d_endservent
linkvar d_getgrps d_getgroups
linkvar d_gethbyaddr d_gethostbyaddr
linkvar d_gethbyname d_gethostbyname
linkvar d_gethent d_gethostent
linkvar d_gethname d_gethostname
linkvar d_getnbyaddr d_getnetbyaddr
linkvar d_getnbyname d_getnetbyname
linkvar d_getnent d_getnetent
linkvar d_getpagsz d_getpagesize
linkvar d_getpbyaddr d_getprotobyaddr
linkvar d_getpbyname d_getprotobyname
linkvar d_getpbynumber d_getprotobynumber
linkvar d_getpent d_getprotoent
linkvar d_getprior d_getpriority
linkvar d_getsbyaddr d_getservbyaddr
linkvar d_getsbyname d_getservbyname
linkvar d_getsbyport d_getservbyport
linkvar d_getsent d_getservent
linkvar d_gettimeod d_gettimeofday
linkvar d_inetaton d_inet_aton
linkvar d_locconv d_localeconv
linkvar d_setgrps d_setgroups
linkvar d_sethent d_sethostent
linkvar d_setnent d_setnetent
linkvar d_setpent d_setprotoent
linkvar d_setprior d_setpriority
linkvar d_setsent d_setservent
linkvar d_sockpair d_socketpair
linkvar d_syserrlst d_sys_errlist

linkvar ptrsize voidptrsize
linkvar d_longdbl d_longdouble

# allow -DEBUGGING
linkvar DEBUGGING EBUGGING
