# Path may only be set once we know version *and* archname.
# So this must be called after _version and _tool.

log
msg "Deciding installation paths"

define prefix "/usr"
define sharedir "$prefix/share"
define html1dir "$sharedir/doc/$perlname/html"
define html3dir "$sharedir/doc/$perlname/html"
define man1dir "$sharedir/man/man1"
define man1ext "1"
define man3dir "$sharedir/man/man3"
define man3ext "3"
define bin "$prefix/bin"
define lib "$prefix/lib"
define scriptdir "$prefix/bin"
define libsdirs ' '
define privlib "$prefix/lib/$package/$version"
define archlib "$prefix/lib/$package/$version/$archname"
define perlpath "$prefix/bin/$perlname"
define d_archlib 'define'

define sitebin	"$prefix/bin"
define sitelib_stem "$prefix/lib/$package/site_perl"
define sitelib "$sitelib_stem/$version"
define siteprefix "$prefix"
define sitescript "$prefix/bin"

define sitebinexp "$sitebin"
define sitelibexp "$sitelib"
define siteprefixexp "$siteprefix"
define sitescriptexp "$sitescript"

define sitearch "$sitelib_stem/$version/$archname"
define sitearchexp "$sitearch"
define d_sitearch 'define'

define inc_version_list ''
define inc_version_list_init ''
define d_inc_version_list 'undef'

define otherlibdirs ''
define d_perl_otherlibdirs 'undef'

define usevendorprefix undef

define d_vendorarch $usevendorprefix
define d_vendorbin $usevendorprefix
define d_vendorlib $usevendorprefix
define d_vendorscript $usevendorprefix

if [ "$usevendorprefix" == 'define' ]; then
	define vendorprefix "$prefix"
	define vendorbin "$vendorprefix/bin"
	define vendorlib_stem "$vendorprefix/lib/$package/vendor_perl"
	define vendorlib "$vendorlib_stem/$version"
	define vendorarch "$vendorlib_stem/$version/$archname"
	define vendorscript "$vendorprefix/bin"
fi

define vendorbinexp "$vendorbin"
define vendorlibexp "$vendorlib"
define vendorarchexp "$vendorarch"
define vendorprefixexp "$vendorprefix"
define vendorscriptexp "$vendorscript"

define vendorman1dir "$man1dir"
define vendorman3dir "$man3dir"
define vendorhtml1dir "$html1dir"
define vendorhtml3dir "$html3dir"
define siteman1dir "$man1dir"
define siteman3dir "$man3dir"
define sitehtml1dir "$html1dir"
define sitehtml3dir "$html3dir"

define installprefix ''
define installhtml1dir "$installpath$html1dir"
define installhtml3dir "$installpath$html3dir"
define installman1dir "$installpath$man1dir"
define installman3dir "$installpath$man3dir"
define installarchlib "$installpath$archlib"
define installbin "$installpath$bin"
define installlib "$installpath$lib"
define installprivlib "$installpath$privlib"
define installscript "$installpath$scriptdir"
define installsitearch "$installpath$sitearch"
define installsitebin "$installpath$sitebin"
define installsitehtml1dir  "$installpath$sitehtml1dir "
define installsitehtml3dir "$installpath$sitehtml3dir"
define installsitelib  "$installpath$sitelib "
define installsiteman1dir "$installpath$siteman1dir"
define installsiteman3dir "$installpath$siteman3dir"
define installsitescript "$installpath$sitescript"
define installvendorarch "$installpath$vendorarch"
define installvendorbin "$installpath$vendorbin"
define installvendorhtml1dir "$installpath$vendorhtml1dir"
define installvendorhtml3dir "$installpath$vendorhtml3dir"
define installvendorlib "$installpath$vendorlib"
define installvendorman1dir "$installpath$vendorman1dir"
define installvendorman3dir "$installpath$vendorman3dir"
define installvendorscript "$installpath$vendorscript"
define installstyle lib/perl5
define installusrbinperl define

define prefixexp "$prefix"
define installprefixexp "$installprefix"
define html1direxp "$html1dir"
define html3direxp "$html3dir"
define vendorman1direxp "$vendorman1dir"
define vendorman3direxp "$vendorman3dir"
define vendorhtml1direxp "$vendorhtml1dir"
define vendorhtml3direxp "$vendorhtml3dir"
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

log
