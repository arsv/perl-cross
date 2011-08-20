#!/bin/bash

# Checking compiler's reaction to __attribute__s.
# Which basically boils down to compiling predefined
# fragments and watching for errors.

# checkattr attr <<END
#    test file goes here
# END
function checkattr {
	mstart "Checking if compiler supports __attribute__($1)"
	ifhintdefined "d_attribute_$1" "yes" "no" && return 0

	try_start
	try_cat
	if not try_compile_check_warnings; then
		result 'no'
		return 1
	fi

	setvar "d_attribute_$1" "define"
	result "yes"
}

# volatile check also here, it's quite similar to __attribute__ checks
# check_if_compiles tag "message" << END
#     test file goes here
# END
function check_if_compiles {
	mstart "Checking $2"
	ifhintdefined "d_$1" "yes" "no" && return 0

	try_start
	try_cat
	if not try_compile_check_warnings; then
		result 'no'
		return 1
	fi

	setvar "d_$1" "define"
	result "yes"
}

checkattr 'format' <<END
#include <stdio.h>
void my_special_printf(char* pat,...) __attribute__((__format__(__printf__,1,2)));
END

# TODO: check for empty format here

checkattr 'malloc' <<END
#include <stdio.h>
char *go_get_some_memory( int how_many_bytes ) __attribute__((malloc));
END

checkattr 'nonnull' <<END
#include <stdio.h>
void do_something (char *some_pointer,...) __attribute__((nonnull(1)));
END

checkattr 'noreturn' <<END
#include <stdio.h>
void fall_over_dead( void ) __attribute__((noreturn));
END

checkattr 'pure' <<END
#include <stdio.h>
int square( int n ) __attribute__((pure));
END

checkattr 'unused' <<END
#include <stdio.h>
int do_something( int dummy __attribute__((unused)), int n );
END

checkattr 'warn_unused_result' <<END
#include <stdio.h>
int I_will_not_be_ignored(void) __attribute__((warn_unused_result));
END

check_if_compiles 'volatile' 'to see if your C compiler knows about "volatile"' <<END
int main()
{
	typedef struct _goo_struct goo_struct;
	goo_struct * volatile goo = ((goo_struct *)0);
	struct _goo_struct {
		long long_int;
		int reg_int;
		char char_var;
	};
	typedef unsigned short foo_t;
	char *volatile foo;
	volatile int bar;
	volatile foo_t blech;
	foo = foo;
}
END
