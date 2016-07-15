# Second part of configure_hint.sh

# By this point, $cctype may be known, and thus it may be a good
# idea to check for compiler-specific hints

if [ -n "$targetarch" -a -n "$cctype" ]; then
	msg "Checking which hints to use for cc type $cctype"
	tryphints "$h_pref" "default-$cctype"
	tryphints "$h_pref" "$h_base-$cctype"
	tryphints "$h_pref" "$h_type-$cctype"
	tryphints "$h_pref" "$h_arch-$cctype"
	tryphints "$h_pref" "$h_arch-$h_mach-$cctype"
	tryphints "$h_pref" "$targetarch-$cctype"
elif [ -n "$target" -a -n "$cctype" ]; then
	msg "Checking which hints to use for cc type $cctype"
	tryphints "$h_pref" "default-$cctype"
	tryphints "$h_pref" "$targetarch-$cctype"
fi
# Add separator to log file
log

# Process -A arguments, if any
for k in $appendlist; do
	v=`valueof "a_$k"`
	appendvar "$k" "$v"
done
