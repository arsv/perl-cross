#!/bin/bash

# Some final tweaks that do not fit in any other file

# Use $ldflags as default value for $lddlflags, together with whatever
# hints provided, but avoid re-setting anyting specified in the command line
if [ -n "$ldflags" -a "$x_lddlflags" != "user" ]; then
	msg "Checking which flags from \$ldflags to move to \$lddlflags"
	for f in $ldflags; do 
		case "$f" in
			-L*|-R*|-Wl,-R*)
				msg "\tadded $f"
				appendvar 'lddlflags' "$f"
				;;
		esac
	done
fi
