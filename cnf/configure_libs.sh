# Deciding which libraries to use

mstart "Deciding whether to use DynaLoader"
if not hinted "$usedl"; then
	test "$i_dlfcn" = 'define' -o "$i_nlist" = 'define'
	resdef 'usedl' 'yes' 'no'
fi

if [ "$usedl" = 'undef' -a -z "$allstatic" ]; then
	msg "DynaLoader is disabled, making all modules static"
	define 'allstatic' 1
fi

mstart "Checking which libraries are available"
if not hinted 'libs'; then
	require 'cc'
	try_start
	try_add "int main(void) { return 0; }"
	try_dump

	_libs=""
	for l in $libswanted; do
		if try_link_libs -l$l; then
			_libs="$_libs -l$l"
		fi
	done

	define 'libs' "$_libs"
	result "$_libs"
fi

# We need to know whether we're trying to use threads early
# to decide whether to test for -lpthread
case "$usethreads:$useithreads:$use5005threads" in
	*define*) define 'usethreads' 'define' ;;
	*)        define 'usethreads' 'undef'  ;;
esac

mstart "Checking which libs to use for perl"
if not hinted 'perllibs'; then
	# $libs lists available libs; $perllibs lists libs that the perl executable
	# should be linked with.
	# The whole idea is wrong, wrong, wrong, but it's tied to MakeMaker.
	# Unlike Configure, we're picking libs presumably needed for perl
	# (Configure uses all except for those it knows are not needed)
	# This allows adding anything to $libswanted without introducing unnecessary perl dependencies.
	# When perl itself needs something unusual, $perllibs value should be hinted.
	predef perllibs ''
	for i in $libs; do
		case "$i" in 
			-lm|-lcrypt)
				append perllibs "$i" ;;
			-ldl)
				test "$usedl" != 'undef' && \
					append perllibs "$i"
				;;
			-lpthread)
				test "$usethreads" != 'undef' && \
					append perllibs "$i"
				;;
			# For a static build, -lgdbm and friends are assumed to be in ext.libs
		esac
	done
	enddef perllibs
	result "$perllibs"
fi

if [ "$usesoname" = "define" ]; then
	define 'soname' "libperl.so.$PERL_API_REVISION.$PERL_API_VERSION"
fi

mstart "Deciding how to name libperl"
if not hinted libperl; then
	if [ -n "$soname" ]; then
		define libperl "libperl.so.$PERL_API_REVISION.$PERL_API_VERSION.$PERL_API_SUBVERSION"
		define "useshrplib" 'true'
		result "$libperl (SONAME $soname, dynamic)"
	elif [ "$useshrplib" = 'true' ]; then
		define libperl "libperl.so"
		result "$libperl (dynamic)"
	else
		define libperl "libperl.a"
		result "$libperl (static)"
	fi
fi
