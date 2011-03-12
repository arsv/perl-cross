#!/bin/sh

tar -zcvf \!pack.tar.gz\
	lib/Pod/Man.pm\
	utils/Makefile\
	x2p/Makefile\
	cnf/config*\
	cnf/hints\
	Makefile\
	Makefile.config.SH\
	make_ext_Makefile.pl\
	configpm\
	configure\
	miniperl_top
