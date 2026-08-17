# Non-testable printf formats; must be hinted or guessed.

define d_PRIEUldbl 'undef'
define d_PRIFUldbl 'undef'
define d_PRIGUldbl 'undef'
define d_PRIXU64 'undef'
define d_PRId64 'undef'
define d_PRIeldbl 'undef'
define d_PRIfldbl 'undef'
define d_PRIgldbl 'undef'
define d_PRIi64 'undef'
define d_PRIo64 'undef'
define d_PRIu64 'undef'
define d_PRIx64 'undef'
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

# 64 ints on 32 host should get %lld instead of %ld.
# 32 on 32, or 64 on 64, must get regular %ld.
# This matters for use64bitint builds.

if [ "$ivsize" -gt "$longsize" ]; then
	define ivdformat '"lld"'
	define uvoformat '"llo"'
	define uvuformat '"llu"'
	define uvxformat '"llx"'
	define uvXUformat '"llX"'
	# unused, set for consistency only
	define sPRId64 '"lld"'
	define sPRIi64 '"lli"'
	define sPRIo64 '"llo"'
	define sPRIu64 '"llu"'
	define sPRIx64 '"llx"'
	define sPRIXU64 '"llX"'
else
	define ivdformat '"ld"'
	define uvoformat '"lo"'
	define uvuformat '"lu"'
	define uvxformat '"lx"'
	define uvXUformat '"lX"'
	# unused, set for consistency only
	define sPRId64 '"ld"'
	define sPRIi64 '"li"'
	define sPRIo64 '"lo"'
	define sPRIu64 '"lu"'
	define sPRIx64 '"lx"'
	define sPRIXU64 '"lX"'
fi

define i32dformat 'PRId32'
define u32uformat 'PRIu32'
define u32oformat 'PRIo32'
define u32xformat 'PRIx32'
define u32XUformat 'PRIX32'
