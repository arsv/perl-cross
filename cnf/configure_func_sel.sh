mstart "Checking whether you have the full shm*(2) library"
log "d_shmctl=$d_shmctl d_shmge=$d_shmget d_shmat=$d_shmat d_shmdt=$d_shmdt"
case ":$d_shmctl:$d_shmget:$d_shmat:$d_shmdt:" in
	*::*|*:undef:*)
		setvar "d_shm" 'undef'
		result 'no'
		;;
	*)
		setvar 'd_shm' 'define'
		result 'yes'
		;;
esac

mstart "Checking whether you have the full sem*(2) library"
log "d_semctl=$d_semctl d_semget=$d_semget d_semop=$d_semop"
case ":$d_semctl:$d_semget:$d_semop:" in
	*::*|*:undef:*)
		setvar 'd_sem' 'undef'
		result 'no'
		;;
	*)
		setvar 'd_sem' 'define'
		result 'yes'
		;;
esac

mstart "Looking how to get error messages"
log "d_strerror=$d_strerror d_sys_errlist=$d_sys_errlist"
# Configure has quite a long piece on strerror, which basically means just this:
if [ "$d_strerror" = 'define' ]; then
	setvar 'd_strerrm' 'strerror(e)'
	result 'strerror()'
elif [ "$d_sys_errlist" = 'define' ]; then
	setvar 'd_strerrm' '((e)<0||(e)>=sys_nerr?"unknown":sys_errlist[e])'
	result 'sys_errlist[]'
else
	setvar 'd_strerrm' 'unknown'
	result 'nothing found'
fi

mstart "Looking for a random number function"
log "d_drand=$d_drand48 d_random=$d_random d_rand=$d_rand"
if [ "$d_drand48" = 'define' ]; then
	setvar 'randfunc' 'drand48'
	result 'good, found drand48()'
elif [ "$d_random" = 'define' ]; then
	setvar 'randfunc' 'random'
	result 'ok, found random()'
elif [ "$d_rand" = 'define' ]; then
	setvar 'randfunc' 'rand'
	result 'yick, looks like I have to use rand()'
else
	setvar 'randfunc' ''
	result 'none found'
fi

# It's a bit more complicated in original Configure, but let's
# assume that if there's clock_t defined then that's what times() returns.
if [ "$d_times" = 'define' ]; then
	mstart "Looking what times() may return"
	log "d_clock_t=$d_clock_t"
	if nothinted clocktype; then
		if [ "$d_clock_t" = 'define' ]; then
			setvar clocktype 'clock_t'
			result 'clock_t'
		else
			setvar clocktype 'long'
			result "it's not clock_t, assuming long"
		fi
	fi
fi
