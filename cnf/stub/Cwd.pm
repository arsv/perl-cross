package Cwd;

@ISA = qw(Exporter);
require Exporter;

@EXPORT = qw(cwd getcwd abs_path);
@EXPORT_OK = qw(cwd getcwd abs_path);


sub cwd
{
	my $cwd = `pwd`;
	chomp $cwd;
	return $cwd;
}

sub getcwd { return cwd(); }

sub abs_path
{
	my $path = shift;
	return $path if $path =~ m!^/!;
	my $cwd = cwd();
	$path = "$cwd/$path";
	$path =~ s{/\./}{/}g;
	$path =~ s{/[^/]+/\.\./}{/}g;
	return $path;
}

1;
