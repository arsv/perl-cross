#!/usr/bin/env sh

# Handle -DEBUGGING
mstart "Checking whether to enable -g"
case "$DEBUGGING" in
	-g|both|define)
   		case "$optimize" in
			*-g*)
				result "already enabled" ;;
			*)
				appendvar optimize "-g"
				result "yes" ;;
   		esac ;;
	none|undef)
		case "$optimize" in
			*-g*) setvar optimize "`echo $optimize | sed -e 's/-g ?//'`" ;;
   		esac
		result "no" ;;
	*)
		result "no" ;;
esac

mstart "Checking whether to use -DDEBUGGING"
case "$DEBUGGING" in
	both|define)
		case "$ccflags" in 
			*-DDEBUGGING*)
				result "already there" ;;
			*)
				appendvar ccflags '-DDEBUGGING'
				result "yes" ;;
		esac ;;
	*)
		result "no" ;;
esac
