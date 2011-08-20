#!/bin/bash

# Some guessing after we have all d_funcs ready

mstart "Checking whether you have the full shm*(2) library"
case "$d_shmctl$d_shmget$d_shmat$d_shmdt" in
	*undef*)
		result 'no'
		setvar "d_shm" 'undef'
		;;
	*)
		result 'yes'
		setvar 'd_shm' 'define'
		;;
esac

mstart "Looking how to get error messages"
# Configure has quite a long piece on strerror, which basically means just this:
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
