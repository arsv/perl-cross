#!/bin/sh

setvar PERL_CONFIG_SH true
setvar PERL_REVISION 5
setvar PERL_VERSION 12
setvar PERL_SUBVERSION 3
setvar PERL_PATCHLEVEL ''
setvar PERL_API_REVISION $PERL_REVISION
setvar PERL_API_VERSION $PERL_VERSION
setvar PERL_API_SUBVERSION $PERL_SUBVERSION
setvar api_revision $PERL_API_REVISION
setvar api_version $PERL_VERSION
setvar api_subversion $PERL_SUBVERSION
setvar api_versionstring "$api_revision.$api_version.$api_subversion"
