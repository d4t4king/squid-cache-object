package CacheObject;

use strict;
use warnings;
use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION	= 0.01;
@ISA		= qw(Exporter);
@EXPORT		= ();
@EXPORT_OK	= qw();
%EXPORT_TAGS	= ( DEFAULT 	=> [qw(&func1)],
		Both		=> [qw(&func1 &func2)]);


# These are ther different meta types from the enums.h in the Squid source
%ENUMS = (
	'STORE_META_VOID'			=> 0,
	'STORE_META_KEY_URL'		=> 1,
	'STORE_META_KEY_SHA'		=> 2,
	'STORE_META_KEY_MD5'		=> 3,
	'STORE_META_URL'			=> 4,
	'STORE_META_STD'			=> 5,
	'STORE_META_HITMETERING'	=> 6,
	'STORE_META_VALID'			=> 7,
	'STORE_META_END'			=> 8);

#########################################
#		V A R I A B L E S				#
#########################################

# Public P4ropertis
# FIX ME:  Needs perl-ification

# string
#
# This is a key for the URL
my $KeyURL = '';


1;
