# Perl version has to be extracted from patchlevel.h

# setverpart name NAME
verpart() {
	q=`grep '#define' patchlevel.h | grep "$2" | head -1 | sed -r -e "s/#define $2\s+//" -e "s/\s.*//"`
	define $1 "$q"
}

mstart "Checking perl version"
if [ -r patchlevel.h ]; then
	verpart revision PERL_REVISION
	verpart patchlevel PERL_VERSION
	verpart subversion PERL_SUBVERSION
	verpart api_revision PERL_API_REVISION
	verpart api_version PERL_API_VERSION
	verpart api_subversion PERL_API_SUBVERSION

	q=`egrep ',"(MAINT|SMOKE)[0-9][0-9]*"' patchlevel.h|tail -1|sed 's/[^0-9]//g'`
	define perl_patchlevel "$q"
else
	result "unknown"
	die "No patchlevel.h found, aborting"
fi

predef version_patchlevel_string "version $patchlevel subversion $subversion"
if [ "$perl_patchlevel" != '' -a "$perl_patchlevel" != '0' ]; then
	perl_patchlevel=`echo $perl_patchlevel | sed 's/.* //'`
	append version_patchlevel_string "patch $perl_patchlevel"
fi
enddef version_patchlevel_string

define PERL_CONFIG_SH true
define PERL_REVISION $revision
define PERL_VERSION $patchlevel
define PERL_SUBVERSION $subversion
define PERL_PATCHLEVEL $perl_patchlevel
define PERL_API_REVISION $api_revision
define PERL_API_VERSION $api_version
define PERL_API_SUBVERSION $api_subversion
define api_versionstring "$api_revision.$api_version.$api_subversion"

# Detect cperl to apply cperl-specific settings, here and in other files as well
# Note $base points to cnf/ not the top-level source dir.

if [ -f $base/../pod/perlcperl.pod ]; then
	define usecperl define
	define package 'cperl'
	define perlname 'cperl'
	define spackage 'cPerl'
else
	define package 'perl5'
	define perlname 'perl'
	define spackage 'Perl5'
fi

define version "$PERL_REVISION.$PERL_VERSION.$PERL_SUBVERSION"
packver="$package-$version"
result "$packver"

# Check for patches. Missing patchset indicates unsupported version,
# and almost certain build failure.

if [ ! -d "$base/diffs/$packver" ]; then
	msg "No patchset found for $packver in $base/diffs"
	msg "This perl version is probably not supported by perl-cross"
	exit 255
fi
