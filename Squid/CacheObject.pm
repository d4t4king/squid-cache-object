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

sub Load($) {

	$cacheObject = shift(@_);

	# If the squid cache object exists
	if (-e $cacheObject) {
		# if the file is readable
		if ( -r $cacheObject ) {
			# firs record the cache object's file size
			my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
				$atime,$mtime,$ctime,$blksize,$blocks)
					= stat($cacheObject);
			$self->Size = $self->HumanReadable($size);
			$self->Created = $ctime; 		### FIX ME:  Format into "human readable"
			$self->Modified = $mtime; 		### Fix ME:  Format into "human readable"

			my $fh; 
			open $fh, "<$cacheObject" or die "Couldn't open file for reading: $! \n";
			if ($fh) {
				# Find out how big the meta data header is

				# Read the meta data header

				# If this looks like a Squid cache object
					# Set the meta data length
					# Loop through the meta data segment
						# Get the current position of the file pointer
						# Read the next meta data tuple
						# If the first character is a newline, we're done.
							# Return tge file pointer to its first position plus one byte
							# exit the loop; we have all our meta data
					# unpack the meta data tuple's type and length
					# Read the meta data value from the file pointer
					# Handle different meta data types differently
					# CASE
				# if we are not getting the headers only
				if (! $self->HeaderOnly) {
					# loop through the HTTP header and file data
						# get the next chunk of data from the file pointer
						# if we already have the header
							# then we just add this to the file data
						# else
							# Add this byte to the headers property

				# close the file pointer
				#
				# # if we got here, we were successful
				return true;

			} else {
				# close the cache file
				# Show the error to the user
				# This does not look like a cache file
				return false;
			}
		} else {
			# tell the user about the error
			$self->Error('Insufficient permissions to read the cache file specified');

			# failure
			return false;
		}
	} else {
		# Show the error to the user
		$self->Error('The cache file specified does not exist.');

		return false;
	}
}
1;
