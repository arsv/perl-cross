#!/bin/sh

function addhco {
	v=`valueof "$1"`
	hco="$hco --target-$1='$v'"
}

# Included if $mode == 'cross', 'native' or 'target'.
# We need to know decisions for target to set the right
# options for configure --mode=buildmini

setifndef prefix "/usr"
setifndef sharedir "$prefix/share"
setifndef html1dir "$sharedir/doc/perl/html"
setifndef html3dir "$sharedir/doc/perl/html"
setifndef man1dir "$sharedir/man/man1"
setifndef man1ext "1"
setifndef man3dir "$sharedir/man/man3"
setifndef man3ext "3"
setifndef bin "$prefix/bin"
setifndef scriptdir "$prefix/bin"
setifndef otherlibdirs ' '
setifndef libsdirs ' '
setifndef privlib "$prefix/lib/perl"
setifndef archlib "$prefix/lib/perl/arch"
setifndef perlpath "$prefix/bin/perl"
setifndef d_archlib 'define'

addhco 'prefix'
addhco 'privlib'
addhco 'archlib'
