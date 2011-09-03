#!/bin/bash

# Some guessing after we have all d_funcs ready

function logvars {
	for i in $*; do
		v=`valueof $i`
		log -n "$i=$v "
	done
	log ""
}

function alldefined {
	logvars $*
	for i in $*; do
		v=`valueof $i`
		if [ "$v" != 'define' ]; then
			return 1
		fi
	done
	return 0
}

mstart "Checking whether you have the full shm*(2) library"
if alldefined d_shmctl d_shmget d_shmat d_shmdt; then
	setvar 'd_shm' 'define'
	result 'yes'
else
	setvar "d_shm" 'undef'
	result 'no'
fi

mstart "Checking whether you have the full sem*(2) library"
if alldefined d_semctl d_semget d_semop i_syssem; then
	setvar 'd_sem' 'define'
	result 'yes'
else
	setvar 'd_sem' 'undef'
	result 'no'
fi

mstart "Looking how to get error messages"
# Configure has quite a long piece on strerror, which basically means just this:
logvars d_strerror d_sys_errlist
if [ "$d_strerror" == 'define' ]; then
	setvar 'd_strerrm' 'strerror(e)'
	result 'strerror()'
elif [ "$d_sys_errlist" == 'define' ]; then
	setvar 'd_strerrm' '((e)<0||(e)>=sys_nerr?"unknown":sys_errlist[e])'
	result 'sys_errlist[]'
else
	setvar 'd_strerrm' 'unknown'
	result 'nothing found'
fi

mstart "Looking for a random number function"
logvars d_drand48 d_random d_rand
if [ "$d_drand48" == 'define' ]; then
	setvar 'randfunc' 'drand48'
	result 'good, found drand48()'
elif [ "$d_random" == 'define' ]; then
	setvar 'randfunc' 'random'
	result 'ok, found random()'
elif [ "$d_rand" == 'define' ]; then
	setvar 'randfunc' 'rand'
	result 'yick, looks like I have to use rand()'
else
	setvar 'randfunc' ''
	result 'none found'
fi
	
# It's a bit more complicated in original Configure, but let's
# assume that if there's clock_t defined that's what times() returns.
if [ "$d_times" == 'define' ]; then
	mstart "Looking what times() may return"
	logvars d_clock_t
	if nothinted clocktype; then
		if [ "$d_clock_t" == 'define' ]; then
			setvar clocktype 'clock_t'
			result 'clock_t'
		else
			setvar clocktype 'long'
			result "it's not clock_t, assuming long"
		fi
	fi
fi

if [ "$d_prctl" == 'define' ]; then
	mstart "Checking whether prctl supports PR_SET_NAME"
	try_start
	try_includes 'sys/prctl.h'
	try_add "int main (int argc, char *argv[]) {"
	try_add "	return (prctl (PR_SET_NAME, \"Test\"));"
	try_add "}"
	try_compile
	resdef 'yes' 'no' 'd_prctl_set_name'
fi


# checkfpclass func D1 D2 D3 ....
function checkfpclass {
	f="$1"; shift
	v=`valueof "d_$f"`	
	if [ "$v" == 'define' ]; then
		mstart "Checking whether $f() constants are defined"
		if alldefined `echo $* | sed -e 's/\</d_/g'`; then
			result 'yes'
		else
			setvar "d_$f" 'undef'
			result "no, disabling $f()"
		fi
	fi
}

checkfpclass fpclassify FP_SNAN FP_QNAN FP_INFINITE FP_NORMAL FP_SUBNORMAL FP_ZERO
checkfpclass fpclass FP_SNAN FP_QNAN FP_NEG_INF FP_POS_INF FP_NEG_INF \
	FP_NEG_NORM FP_POS_NORM FP_NEG_NORM FP_NEG_DENORM FP_POS_DENORM \
	FP_NEG_DENORM FP_NEG_ZERO FP_POS_ZERO FP_NEG_ZERO
