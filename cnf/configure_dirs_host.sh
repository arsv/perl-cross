#!/bin/bash

# This is only included when $mode == 'buildmini'
require 'targetarch'
require 'target_arch'

setifndef prefix "/usr"
setifndef bin "$prefix/bin"

setifndef html1dir 'none'
setifndef html3dir 'none'
setifndef man1dir 'none'
setifndef man3dir 'none'
setifndef perlpath 'none'
setifndef otherlibdirs "$sysroot$targetprefix/lib/perl"
setifndef libsdirs ' '
setifndef privlib "$prefix/$target_arch/lib/perl"
setifndef archlib "$prefix/$target_arch/lib/perl/arch"
