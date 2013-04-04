#! /usr/bin/false

package Digest::MD5;
use Digest::Perl::MD5 qw(md5 md5_hex md5_base64);
use Exporter;
use vars qw($VERSION @ISA @EXPORTER @EXPORT_OK);

@EXPORT_OK = qw(md5 md5_hex md5_base64);
@ISA = 'Exporter';
$VERSION = '1.6';
