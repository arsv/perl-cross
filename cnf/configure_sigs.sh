# Check which signals are defined.
# This may seem a little barbaric, but the whole procedure
# doesn't require running any compiled executables.

msg "Checking available signal names"

signals='ZERO'
siginit='"ZERO"'
signums='0'
signumi='0'
sigsize=1

for sig in HUP INT QUIT ILL TRAP ABRT BUS FPE KILL USR1\
	SEGV USR2 PIPE ALRM TERM STKFLT CHLD CONT STOP TSTP TTIN TTOU URG\
	XCPU XFSZ VTALRM PROF WINCH IO PWR SYS IOT CLD POLL UNUSED ; do
	try_start
	try_includes 'signal.h'

	# OH SHI--
	try_add "#if SIG$sig == 0"
	try_add "perl_cross_configure_sig_number 0"
	for num in `seq 1 100`; do
		try_add "#elif SIG$sig == $num"
		try_add "perl_cross_configure_sig_number $num"
	done
	try_add "#endif"

	if try_preproc; then
		num=`grep 'perl_cross_configure_sig_number ' try.out | sed -e 's/[^0-9]//g'`
		if [ -n "$num" -a "$num" != 0 ]; then
			msg "   got SIG$sig = $num" >&2
			signals="$signals $sig"
			siginit="$siginit, \"$sig\""
			signums="$signums $num"
			signumi="$signumi, $num"
			sigsize=$((sigsize+1))
		fi
	fi
done
[ -z "$siginit" ] || siginit="$siginit, 0"
[ -z "$signumi" ] || signumi="$signumi, 0"

define sig_name "$signals"
define sig_name_init "$siginit"
define sig_num "$signums"
define sig_num_init "$signumi"
define sig_size "$sigsize"

# try to get NSIG value
mstart "Checking NSIG value"
try_start
try_includes 'signal.h'
try_add 'configure check sig_count=NSIG'
try_dump
if try_preproc; then
	num=`grep 'configure check sig_count' try.out | sed -e 's/.*=//' -e 's/[^0-9]//g'`
	if [ -n "$num" ]; then
		define sig_count "$num"
		result "$num"
	else
		define sig_count "0"
		result "unknown"
	fi
else
	define sig_count "0"
	result "unknown"
fi
