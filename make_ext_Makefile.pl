#!./miniperl

# This script creates a minimal Makefile.PL for modules
# that lack it. Typical call order:
#	$(MINIPERL) make_ext_Makefile cpan/Archive-Extract/Makefile.PL
# This was a part of make_ext.pl. Check that file for the correct way
# of writing Makefiles.

# I have a strong impression that there's something really really wrong
# with the very problem this script tries to solve.
# OTOH, given the context, any hacks are ok as long as they yield correct
# results for the set of Makefile.PL-less standard modules.
$spec = shift;
$spec =~ s'/Makefile\.PL$'';	# cpan/Archive-Extract
$fromname = get_fromname($spec);

$dirname = $spec;
$dirname =~ s!^[^/]+/!!;
$dirname =~ s!-!::!g;
$mname = $dirname;

if($mname eq 'podlators') {
	warn "Creating specific $spec/Makefile.PL for podlators\n";
	$fromname = 'VERSION';
	$key = 'DISTNAME';
	$value = 'podlators';
	$mname = 'Pod';
} else {
	warn "Creating $spec/Makefile.PL for $mname\n";
	$key = 'ABSTRACT_FROM';
	($value = $fromname) =~ s/\.pm\z/.pod/;
	$value = $fromname unless -e $value;
}

open my $fh, '>', "$spec/Makefile.PL"
	or die "Can't open $spec/Makefile.PL for writing: $!";
printf $fh <<'EOM', $0, $mname, $fromname, $key, $value;
#-*- buffer-read-only: t -*-

# This Makefile.PL was written by %s.
# It will be deleted automatically by make realclean

use strict;
use ExtUtils::MakeMaker;

# This is what the .PL extracts to. Not the ultimate file that is installed.
# (ie Win32 runs pl2bat after this)

# Doing this here avoids all sort of quoting issues that would come from
# attempting to write out perl source with literals to generate the arrays and
# hash.
my @temps = 'Makefile.PL';
foreach (glob('scripts/pod*.PL')) {
    # The various pod*.PL extractors change directory. Doing that with relative
    # paths in @INC breaks. It seems the lesser of two evils to copy (to avoid)
    # the chdir doing anything, than to attempt to convert lib paths to
    # absolute, and potentially run into problems with quoting special
    # characters in the path to our build dir (such as spaces)
    require File::Copy;

    my $temp = $_;
    $temp =~ s!scripts/!!;
    File::Copy::copy($_, $temp) or die "Can't copy $temp to $_: $!";
    push @temps, $temp;
}

my $script_ext = $^O eq 'VMS' ? '.com' : '';
my %%pod_scripts;
foreach (glob('pod*.PL')) {
    my $script = $_;
    s/.PL$/$script_ext/i;
    $pod_scripts{$script} = $_;
}
my @exe_files = values %%pod_scripts;

WriteMakefile(
    NAME          => '%s',
    VERSION_FROM  => '%s',
    %-13s => '%s',
    realclean     => { FILES => "@temps" },
    (%%pod_scripts ? (
        PL_FILES  => \%%pod_scripts,
        EXE_FILES => \@exe_files,
        clean     => { FILES => "@exe_files" },
    ) : ()),
);

# ex: set ro:
EOM
close $fh or die "Can't close Makefile.PL: $!";


# Find an actual module file name, relative to its directory
#	"cpan/Archive-Extract" -> "lib/Archive/Extract.pm"
# (implying existance of cpan/Archive-Extract/lib/Archive/Extract.pm)
sub get_fromname
{
	my $spec = shift;
	my($base1, $base2, $leaf1, $leaf2);

	($base1 = $spec) =~ s!^(cpan|ext|dist|ext)/!!;
	($base2 = $base1) =~ s!-!/!g;
	($leaf1 = $spec) =~ s!.*/!!;
	($leaf2 = $spec) =~ s!.*-!!;

	return $leaf1 if $leaf1 eq 'podlators';

	foreach("$leaf1.pm", "$leaf2.pm", "lib/$base1/$leaf1.pm", "lib/$base2.pm") {
		#warn "\tTrying $spec/$_\n";
		return $_ if -f "$spec/$_";
	}

	die "$spec: can't find module source\n";
}
