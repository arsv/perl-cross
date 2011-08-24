#!/bin/sh

tar -zcvf \!pack.tar.gz\
	cpan/podlators/lib/Pod/Man.pm\
	cpan/ExtUtils-MakeMaker/lib/ExtUtils/Liblist/Kid.pm\
	ext/POSIX/Makefile.PL\
	utils/Makefile\
	x2p/Makefile\
	cnf/config*\
	cnf/hints\
	extlibs\
	Makefile\
	Makefile.config.SH\
	make_ext_Makefile.pl\
	configpm\
	configure\
	miniperl_top
