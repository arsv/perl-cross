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
define sPRIXU64 '"LX"'
define sPRId64 '"Ld"'
define sPRIeldbl '"Le"'
define sPRIfldbl '"Lf"'
define sPRIgldbl '"Lg"'
define sPRIi64 '"Li"'
define sPRIo64 '"Lo"'
define sPRIu64 '"Lu"'
define sPRIx64 '"Lx"'
define sSCNfldbl '"Lf"'
define nvEUformat '"E"'
define nvFUformat '"F"'
define nvGUformat '"G"'
define nveformat '"e"'
define nvfformat '"f"'
define nvgformat '"g"'
define uidformat '"lu"'
define gidformat '"lu"'

# 64 ints on 32 host should get %Ld instead of %ld.
# 32 on 32, or 64 on 64, must get regular %ld.
# This matters for use64bitint builds.

if [ "$ivsize" -gt "$longsize" ]; then
	define ivdformat '"Ld"'
	define uvoformat '"Lo"'
	define uvuformat '"Lu"'
	define uvxformat '"Lx"'
	define uvXUformat '"LX"'
else
	define ivdformat '"ld"'
	define uvoformat '"lo"'
	define uvuformat '"lu"'
	define uvxformat '"lx"'
	define uvXUformat '"lX"'
fi
