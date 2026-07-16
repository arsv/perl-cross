# Non-testable printf formats; must be hinted or guessed.

define d_PRIEUldbl 'undef'
define d_PRIFUldbl 'undef'
define d_PRIGUldbl 'undef'
define d_PRIeldbl 'undef'
define d_PRIfldbl 'undef'
define d_PRIgldbl 'undef'
define d_SCNfldbl 'undef'
define sPRIEUldbl '"LE"'
define sPRIFUldbl '"LF"'
define sPRIGUldbl '"LG"'
define sPRIeldbl '"Le"'
define sPRIfldbl '"Lf"'
define sPRIgldbl '"Lg"'
define sSCNfldbl '"Lf"'
define nvEUformat '"E"'
define nvFUformat '"F"'
define nvGUformat '"G"'
define nveformat '"e"'
define nvfformat '"f"'
define nvgformat '"g"'
define uidformat '"lu"'
define gidformat '"lu"'

# Mainline perl Configure implements/-ed a kind of crude stdint.h
# replacement in case the header is not available. We won't do that.

test "$i_stdint" = 'define' || die "Cannot proceed without <stdint.h>"

define d_PRIXU64 'define'
define d_PRId64  'define'
define d_PRIi64  'define'
define d_PRIo64  'define'
define d_PRIu64  'define'
define d_PRIx64  'define'

define sPRIXU64 'PRIX64'
define sPRId64  'PRId64'
define sPRIi64  'PRIi64'
define sPRIo64  'PRIo64'
define sPRIu64  'PRIu64'
define sPRIx64  'PRIx64'

if [ "$ivsize" = 8 ]; then
	define ivdformat "$sPRId64"
	define uvoformat "$sPRIo64"
	define uvuformat "$sPRIu64"
	define uvxformat "$sPRIx64"
	define uvXUformat "$sPRIXU64"
elif [ "$ivsize" = "$longsize" ]; then
	define ivdformat '"ld"'
	define uvoformat '"lo"'
	define uvuformat '"lu"'
	define uvxformat '"lx"'
	define uvXUformat '"lX"'
elif [ "$ivsize" = "$intsize" ]; then
	define ivdformat '"d"'
	define uvoformat '"o"'
	define uvuformat '"u"'
	define uvxformat '"x"'
	define uvXUformat '"X"'
elif [ "$ivsize" = "$shortsize" ]; then
	define ivdformat '"hd"'
	define uvoformat '"ho"'
	define uvuformat '"hu"'
	define uvxformat '"hx"'
	define uvXUformat '"hX"'
elif [ "$ivsize" -gt "$longsize" ]; then
	define ivdformat '"lld"'
	define uvoformat '"llo"'
	define uvuformat '"llu"'
	define uvxformat '"llx"'
	define uvXUformat '"llX"'
else
	msg "Cannot determine printf formats for ${ivsize}-byte iv"
	exit 1
fi

define i32dformat 'PRId32'
define u32uformat 'PRIu32'
define u32oformat 'PRIo32'
define u32xformat 'PRIx32'
define u32XUformat 'PRIX32'