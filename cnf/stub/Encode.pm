package Encode;

use Exporter;
our @EXPORT = qw(encode);

sub encode
{
	return $_[1];
}

sub resolve_alias
{
	return $_[1];
}

sub encodings
{
	return ( );
}

1;
