#!/bin/sh

tar -zcvf \!pack.tar.gz\
	lib/Pod/Man.pm\
	ext/POSIX/Makefile.PL\
	utils/Makefile\
	x2p/Makefile\
	cnf/config*\
	cnf/hints\
	installman\
	writemain.SH\
	Makefile\
	Makefile.config.SH\
	make_ext_Makefile.pl\
	configpm\
	configure\
	miniperl_top
