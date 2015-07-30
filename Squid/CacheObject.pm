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

# string
#
# This is a unique SHA hash for the cache object
my $KeySHA = '';

# string
#
# This is a unique MD5 hash for the cache object
my $KeyMD5 = '';

# string
#
# This is the original URL of the content that his cache object holds
my $URL = '';

# string
#
# This id the human readable file size of the cache object file
my $Size = '';

# string
#
# A human readable date representing the cache object's creation date
my $Created = '';

# string
#
# A human readable date representing the cache object's last modified date
my $Modified = '';

# string
#
# This is all the original HTTP headers as they appear in the cache object
my $Headers = '';

# string
#
# This is the cached content as it appears in the cache object
my $Data = '';

# Private Properties
# FIX ME: Needs perl-ification

# integer
#
# This is the length of the meta stat segment in the cache object file
my $MetaDataLength = 0;

# boolean
#
# This will determine if we parse all data or just the meta data headers in s Squid::CacheObject
my $HeaderOnly = false;

#####################################
# 		F U N C T I O N S			#
#####################################

# constructor
#
# returns void
sub SquidCacheObject($$) {
	
	$cacherObject = shift(@_);
	$headerOnly = shift(@_) || false;

	# If we have a cache object
	if ($cacheObject) {
		# no useless messages please
		error_reporting('E_ERROR');

		# set the header only flag
		$self->HeaderOnly = $headerOnly;

		# load it
		$self->Load($cacheObject);
	}
}
1;
