# Checking compiler's reaction to __attribute__s.
# Which basically boils down to compiling predefined
# fragments and watching for errors.

# checkattr attr <<END
#    test file goes here
# END
checkattr() {
	mstart "Checking if compiler supports __attribute__($2)"
	hinted $1 "yes" "no" && return

	try_start
	try_cat
	try_compile_check_warnings

	resdef $1 'yes' 'no'
}


checkattr d_attribute_format 'format' <<END
#include <stdio.h>
void my_special_printf(char* pat,...) __attribute__((__format__(__printf__,1,2)));
END

# TODO: check for empty format here

checkattr d_attribute_malloc 'malloc' <<END
#include <stdio.h>
char *go_get_some_memory( int how_many_bytes ) __attribute__((malloc));
END

checkattr d_attribute_nonnull 'nonnull' <<END
#include <stdio.h>
void do_something (char *some_pointer,...) __attribute__((nonnull(1)));
END

checkattr d_attribute_noreturn 'noreturn' <<END
#include <stdio.h>
void fall_over_dead( void ) __attribute__((noreturn));
END

checkattr d_attribute_pure 'pure' <<END
#include <stdio.h>
int square( int n ) __attribute__((pure));
END

checkattr d_attribute_unused 'unused' <<END
#include <stdio.h>
int do_something( int dummy __attribute__((unused)), int n );
END

checkattr d_attribute_used 'used' <<END
#include <stdio.h>
int used_somewhere(void) __attribute__((used));
END

checkattr d_attribute_deprecated 'deprecated' <<END
#include <stdio.h>
int deprecated(void) __attribute__((deprecated));
END

checkattr d_attribute_warn_unused_result 'warn_unused_result' <<END
#include <stdio.h>
int I_will_not_be_ignored(void) __attribute__((warn_unused_result));
END

# volatile check also here, it's quite similar to __attribute__ checks

mstart "Checking to see if your C compiler knows about volatile"
if not hinted d_volatile 'yes' 'no'; then
	try_start
	try_cat << END
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
	try_compile_check_warnings
	resdef d_volatile 'yes' 'no'
fi

mstart "Checking C99 variadic macros"
if not hinted d_c99_variadic_macros 'supported' 'missing'; then
	try_start
	try_add '#include <stdio.h>'
	try_add '#define foo(fmt, ...) printf(fmt, __VA_ARGS__)'
	try_add 'int main(void) { foo("%i\n", 1234); return 0; }'
	try_compile
	resdef d_c99_variadic_macros 'supported' 'missing'
fi

# Compiler builtins. Should be gcc/clang only, but it's not like we support
# any other compilers atm.
define d_builtin_arith_overflow 'define'
define d_builtin_choose_expr 'define'
define d_builtin_ctz 'define'
define d_builtin_expect 'define'
define d_builtin_prefetch 'define'
