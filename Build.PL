#!/usr/bin/perl -w

use warnings;
use strict;
use Module::Build;

Module::Build->new
	( module_name => 'Cache::Object',
	  license	=> 'perl',
	  requires	=> { 'Date::Format'	=> 0,
	  				 'Digest::MD5'	=> 0,
					 'Digest::SHA1'	=> 0,
				   },
	)->create_build_script;
