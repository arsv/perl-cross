# Path may only be set once we know version *and* archname.
# So this must be called after _version and _tool.

# $(something)exp were meant to be "expanded" values, as in
# "~alex" and "/home/alex", but perl-cross does not do that,
# so the values always match $(something).

log
msg "Deciding installation paths"

define prefix "/usr"

defrel() {
	if [ "$userelocatableinc" = 'define' ]; then
		v=`echo "$2" | sed -e "s@^$prefix@.../..@"`
	else
		v="$2"
	fi

	define "$1" "$v"
}

definst() {
	if [ "$userelocatableinc" = 'define' ]; then
		v=`echo "$2" | sed -e "s@^\.\.\./\.\.@$prefix@"`
	else
		v="$2"
	fi

	define "$1" "$installpath$v"
}

define libdir "$prefix/lib"
define sharedir "$prefix/share"
define html1dir "$sharedir/doc/$perlname/html"
define html3dir "$sharedir/doc/$perlname/html"
define man1dir "$sharedir/man/man1"
define man1ext "1"
define man3dir "$sharedir/man/man3"
define man3ext "3"
define bin "$prefix/bin"
define lib "$libdir"
define scriptdir "$prefix/bin"
define libsdirs ' '
defrel privlib "$libdir/$package/$version"
defrel archlib "$libdir/$package/$version/$archname"
define perlpath "$prefix/bin/$perlname"
define d_archlib 'define'

define sitebin	"$prefix/bin"
defrel sitelib_stem "$libdir/$package/site_perl"
define sitelib "$sitelib_stem/$version"
define sitearch "$sitelib_stem/$version/$archname"
define siteprefix "$prefix"
define sitescript "$prefix/bin"

define sitebinexp "$sitebin"
define sitelibexp "$sitelib"
define siteprefixexp "$siteprefix"
define sitescriptexp "$sitescript"
define sitearchexp "$sitearch"
define d_sitearch 'define'

define inc_version_list ''
define inc_version_list_init ''
define d_inc_version_list 'undef'

define otherlibdirs ''
define d_perl_otherlibdirs 'undef'

define siteman1dir "$man1dir"
define siteman3dir "$man3dir"
define sitehtml1dir "$html1dir"
define sitehtml3dir "$html3dir"

define installprefix ''
definst installhtml1dir "$html1dir"
definst installhtml3dir "$html3dir"
definst installman1dir "$man1dir"
definst installman3dir "$man3dir"
definst installarchlib "$archlib"
definst installbin "$bin"
definst installlib "$lib"
definst installprivlib "$privlib"
definst installscript "$scriptdir"
definst installsitearch "$sitearch"
definst installsitebin "$sitebin"
definst installsitehtml1dir "$sitehtml1dir"
definst installsitehtml3dir "$sitehtml3dir"
definst installsitelib "$sitelib"
definst installsiteman1dir "$siteman1dir"
definst installsiteman3dir "$siteman3dir"
definst installsitescript "$sitescript"
define installstyle lib/perl5
define installusrbinperl define

define prefixexp "$prefix"
define installprefixexp "$installprefix"
define html1direxp "$html1dir"
define html3direxp "$html3dir"
define siteman1direxp "$siteman1dir"
define siteman3direxp "$siteman3dir"
define sitehtml1direxp "$sitehtml1dir"
define sitehtml3direxp "$sitehtml3dir"
define scriptdirexp "$scriptdir"
define man1direxp "$man1dir"
define man3direxp "$man3dir"
define archlibexp "$archlib"
define privlibexp "$privlib"
define binexp "$bin"

define libpth "/lib /usr/lib /usr/local/lib"
define glibpth "$libpth"
define plibpth

# Vendor prefix logic from Configure.
# -Dusevendorprefix => set $vendorprefix to default value: not supported
# -Dvendorprefix=/path => define $usevendorprefix, set $vendor*
# no -Dvendorprefix => undef $usevendorprefix, set $vendor* = ''

mstart "Deciding whether to use \$vendorprefix"
define vendorprefix ''
test -n "$vendorprefix"
resdef usevendorprefix 'yes' 'no'

if [ "$usevendorprefix" = 'define' -a -z "$vendorprefix" ]; then
	die "must specify -Dvendorprefix with -Dusevendorprefix"
elif [ "$usevendorprefix" != 'define' -a -n "$vendorprefix" ]; then
	die "non-empty vendorprefix without -Dusevendorprefix"
fi

vendorpath() {
	if [ -n "$vendorprefix" ]; then
		define "$1" "$2"
	else
		define "$1" ''
	fi
}

vendortest() {
	if [ -n "$2" ]; then
		define "$1" 'define'
	else
		define "$1" 'undef'
	fi
}

vendorpath vendorbin "$vendorprefix/bin"
vendorpath vendorlib_stem "$libdir/$package/vendor_perl"
vendorpath vendorlib "$vendorlib_stem/$version"
vendorpath vendorarch "$vendorlib_stem/$version/$archname"
vendorpath vendorscript "$vendorprefix/bin"

# These are used to control #ifdefs around vendorpath-specific code
vendortest d_vendorarch "$vendorarch"
vendortest d_vendorbin "$vendorbin"
vendortest d_vendorlib "$vendorlib"
vendortest d_vendorscript "$vendorscript"

vendorpath vendorbinexp "$vendorbin"
vendorpath vendorlibexp "$vendorlib"
vendorpath vendorarchexp "$vendorarch"
vendorpath vendorprefixexp "$vendorprefix"
vendorpath vendorscriptexp "$vendorscript"

vendorpath vendorman1dir "$man1dir"
vendorpath vendorman3dir "$man3dir"
vendorpath vendorhtml1dir "$html1dir"
vendorpath vendorhtml3dir "$html3dir"

vendorpath vendorman1direxp "$vendorman1dir"
vendorpath vendorman3direxp "$vendorman3dir"
vendorpath vendorhtml1direxp "$vendorhtml1dir"
vendorpath vendorhtml3direxp "$vendorhtml3dir"

vendorpath installvendorarch "$installpath$vendorarch"
vendorpath installvendorbin "$installpath$vendorbin"
vendorpath installvendorhtml1dir "$installpath$vendorhtml1dir"
vendorpath installvendorhtml3dir "$installpath$vendorhtml3dir"
vendorpath installvendorlib "$installpath$vendorlib"
vendorpath installvendorman1dir "$installpath$vendorman1dir"
vendorpath installvendorman3dir "$installpath$vendorman3dir"
vendorpath installvendorscript "$installpath$vendorscript"

log
