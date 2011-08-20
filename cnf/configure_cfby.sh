#!/bin/bash

# Figure out cf_by and related constants

mstart "Checking how to get hostname"
if nothinted phostname; then
	_myhostname=`hostname`
	if [ -n "$_myhostname" ]; then
		setvar phostname hostname
		result "hostname"
	else
		result unknown
	fi
fi

mstart "Figuring out host name"
if nothinted myhostname; then
	if [ -z "$_myhostname" -a -n "$phostname" ]; then
		_myhostname=`$phostname -s 2>/dev/null`
		if [ -z "$_myhostname" ]; then
			_myhostname=`$phostname 2>/dev/null`
		fi
	fi
	if [ -n "$_myhostname" ]; then
		setvar myhostname "$_myhostname"
		result "$_myhostname"
	else
		result unknown
	fi
fi

mstart "Figuring out domain name"
if nothinted mydomainname; then
	if [ -n "$phostname" ]; then
		mydomainname=`$phostname -y 2>/dev/null`
		if [ -z "$mydomainname" -o "$mydomainname" == "(none)" ]; then
			mydomainname=`$phostname -d 2>/dev/null`
		fi
		if [ -n "$mydomainname" ]; then
			setvar mydomainname ".$mydomainname"
			result "$mydomainname"
		else
			result unknown
		fi
	else
		result unknown
	fi
fi

mstart "Figuring out FQDN"
if nothinted myfqdn; then
	if [ -n "$phostname" ]; then
		myfqdn=`$phostname -f 2>/dev/null`
		if [ -n "$myfqdn" -a "$myfqdn" != 'localhost' -a "$myfqdn" != 'localhost.localdomain' ]; then
			result "$myfqdn"
		else
			myfqdn=''
			result unknown
		fi
	else
		result unknown
	fi
fi

mstart "Configured by (name)"
if nothinted cf_by; then
	if [ -n "$USER" ]; then
		setvar cf_by "$USER"
		result "$USER"
	else
		result unknown
	fi
fi

mstart "Configured by (email)"
if nothinted cf_email; then
	if [ -n "$cf_by" -a -n "$myfqdn" ]; then
		setvar cf_email "$cf_by@$myfqdn"
		result "$cf_email"
	elif [ -n "$cf_by" -a -n "$myhostname" ]; then
		if [ -n "$mydomainname" -a "$mydomainname" != '.localdomain' ]; then
			setvar cf_email "$cf_by@$myhostname$mydomainname"
		else
			setvar cf_email "$cf_by@$myhostname"
		fi
		setvar perladmin "$cf_email"
		result "$cf_email"
	else
		result uknown
	fi
fi

mstart "Configured on"
if nothinted cf_date; then
	setvar cf_date "`LC_ALL=C date 2>/dev/null`"
	result "$cf_date"
fi
