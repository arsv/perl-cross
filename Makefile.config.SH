#!/bin/bash

if [ ! -f config.sh ]; then
	echo "config.sh not found" >&2
	exit -1
fi

disabledmods=''

. ./config.sh
echo -n > Makefile.config
if [ "$usecrosscompile" == 'define' ]; then
	unset cc
	unset ccflags
	unset ar
	unset ranlib
	unset libs
	if [ ! -f 'xconfig.sh' ]; then
		echo 'xconfig.sh not found' >&2
		exit -1
	fi
	
	. ./xconfig.sh
	hostcc="$cc"
	hostccflags="$ccflags"
	hostccdefines="$ccdefines"
	hostldflags="$ldflags"
	hostar="$ar"
	hostranlib="$ranlib"
	hostlibs="$libs"
	host_o="$_o"
	host_exe="$_exe"
	hostbin="$bin"
	hostprefix="$prefix"
	# it's "from host", not host-arch
	target_name="$target_name"
	target_arch="$target_arch"
	sysroot="$sysroot"

	. ./config.sh
fi

function ifprefixed() {
	val=`echo "$2" | sed -e "s/^$1//"`
	if [ "$1$val" == "$2" ]; then
		echo "\$(CROSS)$val"
	else
		echo "$2"
	fi
}

if [ "$usedl" == 'undef' ]; then
	dynaloader=''
else
	dynaloader="DynaLoader"
fi

cflags='-DPERL_CORE '
if [ "$usecrosscompile" == "define" ]; then
test -n "$toolsprefix" && cross="$toolsprefix" || cross="$target_name-"
cat >> Makefile.config <<END
CROSS = $cross
CC = `ifprefixed "$cross" "$cc"`
AR = `ifprefixed "$cross" "$ar"`
RANLIB = `ifprefixed "$cross" "$ranlib"`
CFLAGS = $cflags $ccflags $ccdefines $optimize
LDFLAGS = $ldflags
LIBS = $libs

HOSTCC = $hostcc
HOSTCFLAGS = $cflags -DUSE_CROSS_COMPILE $hostccflags $hostccdefines
HOSTCFMINI = \$(HOSTCFLAGS) -DPERL_EXTERNAL_GLOB
HOSTLDFLAGS = $hostldflags
HOSTLIBS = $hostlibs
hostbin = \$(DESTDIR)$hostbin
hostarch = \$(DESTDIR)$hostarch
hostprefix = \$(DESTDIR)$hostprefix
target_name = $target_name
target_arch = $target_arch
sysroot = $sysroot

# suffixes for static library, object and executable files
# lowercase for target platform or native build, uppercase
# for build platform.
a = $_a
o = $_o
x =
O = .host$host_o
X = $host_exe
so = $dlext

dynaloader = $dynaloader

extensions: xconfig-pm
END
else
cat >> Makefile.config <<END
CC = $cc
AR = $ar
RANLIB = $ranlib
CFLAGS = $cflags $ccflags $ccdefines $optimize
LDFLAGS = $ldflags
LIBS = $libs

HOSTCC = \$(CC)
HOSTCFLAGS = \$(CFLAGS)
HOSTCFMINI = \$(HOSTCFLAGS) -DPERL_EXTERNAL_GLOB
HOSTLDFLAGS = \$(LDFLAGS)
HOSTLIBS = \$(LIBS)

# suffixes for static library, object and executable files
# lowercase for target platform or native build, uppercase
# for build platform.
a = $_a
o = $_o
x = $_exe
O = $_o
X = $_exe

dynaloader = $dynaloader
END
fi


cat >> Makefile.config <<END

.SUFFIXES: .c \$o \$O

LNS = $lns

root = \$(DESTDIR)\$(sysroot)
bindir = \$(root)$installbin
scriptdir = \$(root)$installscript
privlib = \$(root)$installprivlib
archlib = \$(root)$installarchlib
man1dir = \$(root)$installman1dir
man3dir = \$(root)$installman3dir
man1ext = $installman1ext
man3ext = $installman3ext

dynamic_ext = $dynamic_ext
static_ext = $static_ext
nonxs_ext = $nonxs_ext
END

if [ "$disabledmods" == 'define' ]; then
	cat >> Makefile.config << END
disabled_dynamic_ext=$disabled_dynamic_ext
disabled_nonxs_ext=$disabled_nonxs_ext
END
fi
