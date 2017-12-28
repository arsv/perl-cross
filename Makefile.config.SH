#!/bin/sh

if [ ! -f config.sh ]; then
	echo "config.sh not found" >&2
	exit -1
fi

disabledmods=''

. ./config.sh
echo -n > Makefile.config
if [ "$usecrosscompile" = 'define' ]; then
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
	hostccflags="$ccflags $optimize"
	hostldflags="$ldflags"
	hostar="$ar"
	hostranlib="$ranlib"
	hostlibs="$perllibs"
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

ifprefixed() {
	val=`echo "$2" | sed -e "s/^$1//"`
	if [ "$1$val" = "$2" ]; then
		echo "\$(CROSS)$val"
	else
		echo "$2"
	fi
}

if [ "$usedl" = 'undef' ]; then
	dynaloader=''
else
	dynaloader="DynaLoader"
fi

cflags="-DPERL_CORE $ccflags $optimize"
test "$useshrplib" = 'true' && cflags="$cflags $cccdlflags"

if [ "$usecrosscompile" = "define" ]; then
test -n "$toolsprefix" && cross="$toolsprefix" || cross="$target_name-"
cat >> Makefile.config <<END
CROSS = $cross
CC = `ifprefixed "$cross" "$cc"`
AR = `ifprefixed "$cross" "$ar"`
RANLIB = `ifprefixed "$cross" "$ranlib"`
CFLAGS = $cflags
LDFLAGS = $ldflags
LDDLFLAGS = $lddlflags
LIBS = $perllibs

HOSTCC = $hostcc
HOSTCFLAGS = -DPERL_CORE -DUSE_CROSS_COMPILE $hostccflags
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
l = .so
O = .host$host_o
X = $host_exe
so = $dlext
END
else
cat >> Makefile.config <<END
CC = $cc
AR = $ar
RANLIB = $ranlib
CFLAGS = $cflags
LDFLAGS = $ldflags
LDDLFLAGS = $lddlflags
LIBS = $perllibs

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
l = .so
O = $_o
X = $_exe
END
fi

cat >> Makefile.config <<END
package = $package
perlname = $perlname
version = $version
dynaloader = $dynaloader
useshrplib = $useshrplib
soname = $soname
patchset = $package-$version
installbin = $installbin

LIBPERL = $libperl

.SUFFIXES: .c \$o \$O

LNS = $lns

archlib = $archlib

dynamic_ext = $dynamic_ext
static_ext = $static_ext
nonxs_ext = $nonxs_ext
END

if [ "$disabledmods" = 'define' ]; then
	cat >> Makefile.config << END
disabled_dynamic_ext=$disabled_dynamic_ext
disabled_nonxs_ext=$disabled_nonxs_ext
END
fi

vertag=$PERL_REVISION$PERL_VERSION$PERL_SUBVERSION
echo >> Makefile.config
if [ "$package" = 'cperl' ]; then
	# The version they diverged from mainline perl? Yikes
	case "$version" in
		5.26.*) pcpver=5260 ;;
		*)      pcpver=5240 ;;
	esac
	cat >> Makefile.config << END
perlcdeltapod=perl${vertag}cdelta.pod
perldeltapod=perl${pcpver}delta.pod
END
else
	cat >> Makefile.config << END
perldeltapod=perl${vertag}delta.pod
END
fi

# Before 5.24, time64.c was included from pp_sys.c and could not be built
# separately. From 5.24 on, it's a regular standalone file. Ugly but there
# is probably no better way to handle this.
case "$version" in
	5.22.*) ;;
	*) echo "time64.c = time64.c" >> Makefile.config ;;
esac

# Before 5.27.7, PPPort was in cpan/. From that version on, it's in dist/
case "$version" in
	5.27.7) ppport="dist/Devel-PPPort" ;;
	*)      ppport="cpan/Devel-PPPort" ;;
esac
echo "ppport = $ppport" >> Makefile.config
