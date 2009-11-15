#!/bin/sh

# Some shared memory tweaks.
# d_shm* must be defined at this point, probably by configure_func

mstart "Checking whether you have the full shm*(2) library ... "
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
