# Perl version has to be extracted from patchlevel.h

# setverpart name NAME
setverpart() {
	_v=`grep '#define' patchlevel.h | grep "$2" | head -1 | sed -r -e "s/#define $2\s+//" -e "s/\s.*//"`
	msg "	$1=$_v"
	setvar $1 "$_v"
}

msg "Getting the current patchlevel..."
setifndef package 'perl5'
if [ -r patchlevel.h ]; then
	setverpart revision PERL_REVISION
	setverpart patchlevel PERL_VERSION
	setverpart subversion PERL_SUBVERSION
	setverpart api_revision PERL_API_REVISION
	setverpart api_version PERL_API_VERSION
	setverpart api_subversion PERL_API_SUBVERSION

	v=`egrep ',"(MAINT|SMOKE)[0-9][0-9]*"' patchlevel.h|tail -1|sed 's/[^0-9]//g'`
	msg "	patchlevel=$v"
	setvar perl_patchlevel "$v"
else
	die "No patchlevel.h found, aborting"
fi

# Define a handy string here to avoid duplication in myconfig.SH and configpm.
version_patchlevel_string="version $patchlevel subversion $subversion"
if [ "$perl_patchlevel" != '' -a "$perl_patchlevel" != '0' ]; then
	perl_patchlevel=`echo $perl_patchlevel | sed 's/.* //'`
	version_patchlevel_string="$version_patchlevel_string patch $perl_patchlevel"
fi

msg "	You have $package $version_patchlevel_string"

setvar PERL_CONFIG_SH true
setvar PERL_REVISION $revision
setvar PERL_VERSION $patchlevel
setvar PERL_SUBVERSION $subversion
setvar PERL_PATCHLEVEL $perl_patchlevel
setvar PERL_API_REVISION $api_revision
setvar PERL_API_VERSION $api_version
setvar PERL_API_SUBVERSION $api_subversion
setvar api_versionstring "$api_revision.$api_version.$api_subversion"

# Detect cperl to apply cperl-specific settings, here and in other files as well
# Note $base points to cnf/ not the top-level source dir.

mstart "Checking perl variant"
if [ -f $base/../pod/perlcperl.pod ]; then
	setvaru usecperl define '' # force this into config.sh
	setvar package 'cperl'
	setvar perlname 'cperl'
	setvar spackage 'cPerl'
	result "cperl"
else
	setvar package 'perl5'
	setvar perlname 'perl'
	setvar spackage 'Perl5'
	result "mainline"
fi

# Check for patches. Missing patchset indicates unsupported version,
# and almost certain build failure.

version="$PERL_REVISION.$PERL_VERSION.$PERL_SUBVERSION"

if [ ! -d "$base/diffs/$package-$version" ]; then
	msg "No patchset found for $package-$version in $base/diffs"
	msg "This perl version is probably not supported by perl-cross"
	die "Aborting"
fi
