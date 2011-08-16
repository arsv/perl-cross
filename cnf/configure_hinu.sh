#!/bin/sh

# Second part of configure_hint.sh
# By this point, $cctype may be known, and thus it may be a good
# idea to check for compiler-specific hints

if [ -n "$targetarch" -a -n "$cctype" ]; then
	msg "Checking which hints to use for cc type $cctype"
	trypphints "$h_pref"\
		"$targetarch-$cctype" "$h_arch-$h_mach-$cctype" "$h_arch-$cctype" \
		"$h_type-$cctype" "$h_base-$cctype" "default-$cctype"

	# Add separator to log file
	log
fi
