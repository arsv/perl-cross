package File::Temp;

sub tempfile
{
	my $patt = shift;
	my %opts = @_;
	my $i;
	my $tmp;
	local *FH;
	
	return unless defined $patt;
	for($i = 0; $i < 10; $i++) {
		($tmp = $patt) =~ s{X+}{rand()}e;
		next unless sysopen(FH, $tmp, 01 | 0100 | 0200);	# O_WRONLY | O_CREAT | O_EXCL
		return wantarray ? (\*FH, $tmp) : \*FH;
	}

	return;
}

1;
