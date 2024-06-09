#!/bin/sh

# perl-cross, being an overlaid changeset, is not particulary
# git- or github-friendly.
#
# To make it look nice on Github, it must carry README, Copying
# and have a plain directory layout. When deploying it onto a perl
# source tree, it's better not to have those files.
#
# Berlios versions were packed to match relevant perl directory
# name, and it worked well at the time.
# However now with the possibility of supporting several perl versions
# and cperl, it makes little sense to keep a single perl version
# in the package name. In most cases, the bundle will be unpacked
# with --strip-compontents=1 anyway.

V=1.5.3

tar -zcf perl-cross-$V.tar.gz\
	--exclude README.md\
	--exclude LICENSE\
	--exclude Artistic\
	--exclude Copying\
	--exclude 0pack.sh\
	--exclude perl-cross.tar\
	--exclude perl-cross\*.tar.gz\
	--exclude tags\
	--xform "s!^!perl-cross-$V/!S"\
	*
