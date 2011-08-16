#!/bin/sh

# Second part of configure_hint.sh
# By this point, $cctype may be known, and thus it may be a good
# idea to check for compiler-specific hints

if [ -n "$targetarch" -a -n "$cctype" ]; then
	msg "Checking which hints to use for cc type $cctype"
	trypphints "$h_pref"\
		":$targetarch-$cctype" "a/:$h_arch-$h_mach-$cctype" "a/:$h_arch-$cctype" \
		"s/:$h_type-$cctype" "s/:$h_base-$cctype"
fi
