#!/bin/sh

tar -zcvf \!pack.tar.gz\
	x2p/Makefile\
	cnf/config*\
	cnf/hints\
	cnf/diffs\
	cnf/cpan\
	extlibs\
	statars\
	Makefile\
	Makefile.config.SH\
	make_ext_Makefile.pl\
	configure\
	miniperl_top\
	utils/Makefile
