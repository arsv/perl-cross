#!./miniperl

# This script creates a minimal Makefile.PL for modules
# that lack it. Typical call order:
#	$(MINIPERL) make_ext_Makefile cpan/Archive-Extract/Makefile.PL

# I have a strong impression that there's something really really wrong
# with the very problem this script tries to solve.
# OTOH, given the context, any hacks are ok as long as they yield correct
# results for the set of Makefile.PL-less standard modules.
$spec = shift;
$spec =~ s'/Makefile\.PL$'';	# cpan/Archive-Extract
$fromname = get_fromname($spec);
$mname = $fromname;
$mname =~ s!^lib/!!;
$mname =~ s/\.pm$//;
$mname =~ s!/!::!g;

warn "Creating $spec/Makefile.PL for $mname\n";

($pod_name = $fromname) =~ s/\.pm\z/.pod/;
$pod_name = $fromname unless -e $pod_name;

open my $fh, '>', "$spec/Makefile.PL"
	or die "Can't open $spec/Makefile.PL for writing: $!";
print $fh <<"EOM";
#-*- buffer-read-only: t -*-

# This Makefile.PL was written by $0.
# It will be deleted automatically by make realclean

use strict;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => '$mname',
    VERSION_FROM  => '$fromname',
    ABSTRACT_FROM => '$pod_name',
    realclean     => {FILES => 'Makefile.PL'},
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

	foreach("$leaf1.pm", "$leaf2.pm", "lib/$base1/$leaf1.pm", "lib/$base2.pm") {
		#warn "\tTrying $spec/$_\n";
		return $_ if -f "$spec/$_";
	}

	die "$spec: can't find module source\n";
}
