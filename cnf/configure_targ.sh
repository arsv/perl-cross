# This is called before _gencfg is invoked for the second time
# to generate tconfig.sh
# It should forcibly set cc & Co. to some non-cross values.
# Note: this is *not* tested, and probably can't be.

setvareither() {
	if [ -n "$2" ]; then
		setvar "$1" "$2"
	else
		setvar "$1" "$3"
	fi
}

default_tnat() {
	v=`valueof "target_$1"`
	w=`valueof "$1"`
	if [ -n "$v" -a "$v" != ' ' ]; then
		setvar "install$1" "$v"
	else
		setvar "install$1" "$installprefix$w"
	fi

}

setvareither 'cc' "$target_cc" 'cc'
setvareither 'cpp' "$target_cpp" "$cc -E"
setvareither 'ld' "$target_ld" 'ld'
setvareither 'ar' "$target_ar" 'ar'
setvareither 'objdump' "$target_objdump" 'objdump'
setvareither 'ranlib' "$target_ranlib" 'ranlib'

setvar 'cpprun' "$cpp"
setvar 'cppstdin' "$cpp"

setvareither installprefix "$target_installprefix" ''

default_tnat html1dir
default_tnat html3dir
default_tnat man1dir
default_tnat man1ext
default_tnat man3dir
default_tnat man3ext
default_tnat scriptdir
default_tnat otherlibdirs
default_tnat libsdirs
default_tnat archlib
default_tnat bin
default_tnat html1dir
default_tnat html3dir
default_tnat privlib
default_tnat script
default_tnat sitearch
default_tnat sitebin
default_tnat sitehtml1dir 
default_tnat sitehtml3dir
default_tnat sitelib 
default_tnat siteman1dir
default_tnat siteman3dir
default_tnat sitescript
default_tnat vendorarch
default_tnat vendorbin
default_tnat vendorhtml1dir
default_tnat vendorhtml3dir
default_tnat vendorlib
default_tnat vendorman1dir
default_tnat vendorman3dir
default_tnat vendorscript
