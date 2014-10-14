#!/bin/sh

# perl-cross, being an overlaid changeset, is not particulary
# git- or github-friendly.
#
# To make it look nice on Github, it must carry README, Copying
# and have a plain directory layout. When deploying it onto a perl
# source tree, it's better not to have said files.
#
# Berlios versions were packed to match relevant perl directory
# name, and it worked well. So the idea here is to keep
# Github-friendly directory structure for Github, and have this
# script to pack the files into an easily-applicable tarball
# for deploying.
#
# Tar with --xform option support is expected.

PV=5.20.1

tar -cf perl-cross.tar\
	--exclude README.md\
	--exclude LICENSE\
	--exclude Artistic\
	--exclude Copying\
	--exclude 0pack.sh\
	--exclude perl-cross.tar\
	--xform "s!^!perl-$PV/!"\
	*
