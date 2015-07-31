package CacheObject;

use strict;
use warnings;
use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# The following is adapted from the PHP SquidCachObject Class
# referenced here:
# http://www.phpclasses.org/package/3362-PHP-Parse-a-binary-Squid-cache-file.html#view_files/files/15882
# You must be registered to view the code.
#+----------------------------------------------------------------------+ 
#| SquidCacheObject v0.6 | 
#+----------------------------------------------------------------------+ 
#| Copyright (c) 2006 Warren Smith ( smythinc 'at' gmail 'dot' com ) | 
#+----------------------------------------------------------------------+ 
#| This library is free software; you can redistribute it and/or modify | 
#| it under the terms of the GNU Lesser General Public License as | 
#| published by the Free Software Foundation; either version 2.1 of the | 
#| License, or (at your option) any later version. | 
#| | 
#| This library is distributed in the hope that it will be useful, but | 
#| WITHOUT ANY WARRANTY; without even the implied warranty of | 
#| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU | 
#| Lesser General Public License for more details. | 
#| | 
#| You should have received a copy of the GNU Lesser General Public | 
#| License along with this library; if not, write to the Free Software | 
#| Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 | 
#| USA | 
#+----------------------------------------------------------------------+ 
#| Simple is good. | 
#+----------------------------------------------------------------------+ 
# 
#+----------------------------------------------------------------------+ 
#| Package: SquidCacheObject v0.6 | 
#| Class : SquidCacheObject | 
#| Created: 25/08/2006 | 
#+----------------------------------------------------------------------+
 
$VERSION	= 0.01;
@ISA		= qw(Exporter);
@EXPORT		= ();
@EXPORT_OK	= qw();
%EXPORT_TAGS	= ( DEFAULT 	=> [qw(&func1)],
		Both		=> [qw(&func1 &func2)]);


# These are ther different meta types from the enums.h in the Squid source
my %ENUMS = (
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
	
	my $cacheObject = shift(@_);
	my $headerOnly = shift(@_) || false;

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

# load a cache object and parse it into a program object
#
# return boolean
sub Load($) {

	my $cacheObject = shift(@_);

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
				close $fh;
				# Show the error to the user
				$self->Error("You did not specify a valid squid cache object or the cache object is corrupted");
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

# This will get the hex string for some bytes
#
# return string
sub HexString($) {
	my $bytes = shift(@_);

	# this is the string we'll be returning
	my $return = '';

	# If we have some bytes to loop through....
	if ($bytes) {
		# Loop through the bytes
		for (my $i = 0; $i < length($bytes); $i++) {
			# Get the hex value for this byte
			my $Hex = hex(ord($$bytes[$i]));

			# If this hex character is only 1 character in length add a preceding 0.
			if (length($Hex) == 1) { $Hex = "0".$Hex; }

			# Add this value to the final string
			$return .= $Hex;
		}
	}

	# Return the final string
	return $return;
}

# Makes a user readable file size string from the byte value
#
# return string
sub HumanReadable($) {
	my $bytes = shift(@_) || 0;

	# the return string
	my $return = '';

	# for files smaller than a kilobyte
	if ($bytes < 1024) {
		# we are dealing with bytes
		$return = $bytes." bytes";
	} elsif ($bytes < 1048576) {
		# we are dealing with kilobytes
		$return = sprintf("%d", ($bytes / 1024))." KB";
	} elsif ($bytes < 1073741824) {
		# we are dealing with megabytes
		$return = sprintf("%d", ($bytes / 1048576))." MB";
	} else {
		# and in the unlikely occurrance, we assume anything else
		# will be gigabytes
		$return = sprintf("%d", ($bytes / 1073741824))." GB";
	}
}

# Report an error to the user specific to their environment
#
# return void
sub Error($) {
	my $msg = shift(@_) || "";

	# if we have a message to show
	if ($msg) {
		# format the message for the command line interface
		$msg = '[!] '.$msg."\n";
	}
}

1;
