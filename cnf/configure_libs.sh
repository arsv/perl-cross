#!/bin/bash

mstart "Deciding whether to use DynaLoader"
if [ "$usedl" == 'undef' -a -z "$allstatic" ]; then
	setvar 'usedl' 'undef'
	result "no"
	msg "DynaLoader is disabled, making all modules static"
	setvar 'allstatic' 1
else
	setvar 'usedl' 'define'
	result 'yes'
fi

mstart "Checking which libraries are available"
if not hinted 'libs'; then
	require 'cc'
	try_start
	try_add "int main(void) { return 0; }"
	try_dump

	_libs=""
	shift
	for l in $libswanted; do
		if try_link_libs -l$l; then
			_libs="$_libs -l$l"
		fi
	done

	setvar 'libs' "$_libs"
	result "$_libs"
fi

# We need to know whether we're trying to build threads support to make decision about -lpthreads
if [ "$usethreads" == 'define' -o "$useithreads" == 'define' -o "$use5005threads" == 'define' ]; then
	test "$usethreads" == 'define' || setvar 'usethreads' 'define'
else
	test "$usethreads" == 'define' || setvar 'usethreads' 'undef'
fi

mstart "Checking which libs to use for perl"
if not hinted 'perllibs'; then
	# $libs lists available libs; $perllibs lists libs that the perl executable
	# should be linked with.
	# The whole idea is wrong, wrong, wrong, but it's tied to MakeMaker.
	# Unlike Configure, we're picking libs presumably needed for perl
	# (Configure uses all except for those it know are not needed)
	# This allows adding anything to $libswanted without introducing unnecessary perl
	# dependencies. When perl itself needs something unusual, $perllibs value should be hinted.
	_libs=''
	for i in $libs; do
		case "$i" in 
			-lm|-lcrypt)
				appendvar '_libs' "$i" ;;
			-ldl)
				test "$usedl" != 'undef' && appendvar '_libs' "$i" ;;
			-lpthreads)
				test "$usethreads" != 'undef' && appendvar '_libs' "$i" ;;
			# For a static build, -lgdbm and friends are assumed to be in ext.libs
		esac
	done
	setvar perllibs "$_libs"
	result "$_libs"
fi
