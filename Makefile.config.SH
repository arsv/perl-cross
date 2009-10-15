#!/bin/sh

if [ ! -f config.sh ]; then
	echo "config.sh not found" >&2
	exit -1
fi

. config.sh
echo -n > Makefile.config
if [ "$usecrosscompile" == 'define' ]; then
	unset cc
	unset cflags
	unset ar
	unset ranlib
	unset libs
	if [ ! -f 'xconfig.sh' ]; then
		echo 'xconfig.sh not found' >&2
		exit -1
	fi
	
	. xconfig.sh
	hostcc="$cc"
	hostcflags="$cflags"
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

	. config.sh
fi

cc="$cc"
cflags="$cflags"
ar="$ar"
ranlib="$ranlib"
libs="$libs"
 
dynamic_list=''
for f in $dynamic_ext; do
	base=`echo "$f" | sed 's/.*\///'`
	dynamic_list="${dynamic_list}lib/auto/$f/$base.$dlext "
done

static_list=''
for f in $static_ext; do
	base=`echo "$f" | sed 's/.*\///'`
	static_list="${static_list}lib/auto/$f/$base\$_a "
done

nonxs_list=''
for f in $nonxs_ext; do
    base=`echo "$f" | sed 's/.*\///'`
    nonxs_list="${nonxs_list}ext/$f/pm_to_blib "
done

function ifprefixed() {
	val=`echo "$2" | sed -e "s/^$1-//"`
	if [ "$1-$val" == "$2" ]; then
		echo "\$(CROSS)$val"
	else
		echo "$2"
	fi
}

cflags='-DPERL_CORE -std=c89 -W -ansi'
if [ "$usecrosscompile" == "define" ]; then
cat >> Makefile.config <<END
CROSS = $target_name-
CC = `ifprefixed "$target_name" "$cc"`
AR = `ifprefixed "$target_name" "$ar"`
RANLIB = `ifprefixed "$target_name" "$ranlib"`
CFLAGS = $cflags
LIBS = $libs

HOSTCC = $hostcc
HOSTCFLAGS = -DUSE_CROSS_COMPILE $cflags
HOSTCFMINI = \$(HOSTCFLAGS) -DPERL_EXTERNAL_GLOB
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

install: install.miniperl
extensions: xconfig-pm
END
else
cat >> Makefile.config <<END
CC = $cc
AR = $ar
RANLIB = $ranlib
CFLAGS = $cflags
LIBS = $libs

HOSTCC = \$(CC)
HOSTCFLAGS = \$(CFLAGS)
HOSTCFMINI = \$(HOSTCFLAGS) -DPERL_EXTERNAL_GLOB
HOSTLIBS = \$(LIBS)

# suffixes for static library, object and executable files
# lowercase for target platform or native build, uppercase
# for build platform.
a = $_a
o = $_o
x = $_exe
O = $_o
X = $_exe
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

dynamic_ext = $dynamic_list
static_ext = $static_list
nonxs_ext = $nonxs_list
END
