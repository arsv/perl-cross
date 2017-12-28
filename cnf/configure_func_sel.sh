mstart "Checking whether you have the full shm*(2) library"
log "d_shmctl=$d_shmctl d_shmge=$d_shmget d_shmat=$d_shmat d_shmdt=$d_shmdt"
case ":$d_shmctl:$d_shmget:$d_shmat:$d_shmdt:" in
	*::*|*:undef:*)
		define d_shm 'undef'
		result 'no'
		;;
	*)
		define d_shm 'define'
		result 'yes'
		;;
esac

mstart "Checking whether you have the full sem*(2) library"
log "d_semctl=$d_semctl d_semget=$d_semget d_semop=$d_semop"
case ":$d_semctl:$d_semget:$d_semop:" in
	*::*|*:undef:*)
		define d_sem 'undef'
		result 'no'
		;;
	*)
		define d_sem 'define'
		result 'yes'
		;;
esac

mstart "Checking whether you have the full msg*(2) library"
log "d_msgctl=$d_msgctl d_msgget=$d_msgget d_msgsnd=$d_msgsnd d_msgrcv=$d_msgrcv"
case ":$d_msgctl:$d_msgget:$d_msgsnd:$d_msgrcv" in
	*::*|*:undef:*)
		define d_msg 'undef'
		result 'no'
		;;
	*)
		define d_msg 'define'
		result 'yes'
		;;
esac

mstart "Looking how to get error messages"
log "d_strerror=$d_strerror d_sys_errlist=$d_sys_errlist"
# Configure has quite a long piece on strerror, which basically means just this:
if [ "$d_strerror" = 'define' ]; then
	define d_strerrm 'strerror(e)'
	result 'strerror()'
elif [ "$d_sys_errlist" = 'define' ]; then
	define d_strerrm '((e)<0||(e)>=sys_nerr?"unknown":sys_errlist[e])'
	result 'sys_errlist[]'
else
	define d_strerrm 'unknown'
	result 'nothing found'
fi

mstart "Looking for a random number function"
log "d_drand=$d_drand48 d_random=$d_random d_rand=$d_rand"
if [ "$d_drand48" = 'define' ]; then
	define randfunc 'drand48'
	define seedfunc 'srand48'
	define randbits 48
	define randseedtype 'long'
	result 'good, found drand48()'
elif [ "$d_random" = 'define' ]; then
	define randfunc 'random'
	define seedfunc 'srandom'
	define randbits 31
	define randseedtype 'int'
	result 'ok, found random()'
elif [ "$d_rand" = 'define' ]; then
	define randfunc 'rand'
	define seedfunc 'srand'
	define randbits 15
	define randseedtype 'int'
	result 'yick, looks like I have to use rand()'
else
	define randfunc ''
	define seedfunc ''
	define randbits 0
	define randseedtype 'int'
	result 'none found'
fi

# It's a bit more complicated in original Configure, but let's
# assume that if there's clock_t defined then that's what times() returns.
mstart "Looking what times() may return"
log "d_times=$d_times d_clock_t=$d_clock_t"
if [ "$d_times" = 'define' ]; then
	if not hinted clocktype; then
		if [ "$d_clock_t" = 'define' ]; then
			define clocktype 'clock_t'
			result 'clock_t'
		else
			define clocktype 'long'
			result "it's not clock_t, assuming long"
		fi
	fi
else
	result "irrelevant"
fi

# Assume nl_langinfo_l is threadsafe if available
define d_thread_safe_nl_langinfo_l "$d_nl_langinfo_l"
