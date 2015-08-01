#!/usr/bin/perl -w

use warnings;
use strict;

BEGIN { push @INC, '../' }

use Data::Dumper;
use Cache::Object;

# Instantiate the Squid::CacheObject object, providing 
# the Squid cache file as an argument
my $CacheObject = Cache::Object->new('./00000000');

#print $CacheObject->_getObjectSize;
# Dump the contents of the squid cache object
#print Dumper($CacheObject);

my $size = -s $CacheObject->{'_URL'};
my $total_read = 0;
my $buffer = '';
my $bufsize = 1024;

open F, "<$CacheObject->{'_URL'}" or die "Couldn't open file for reading: $! \n";
#while ( my $read = sysread(F, $buffer, $bufsize, ) ) {
#	printf "Read %8u bytes\n", $read;
	# do something with $buffer
#	print "|".unpack('CType/@1/ILength', $buffer)."|\n";
#	$total_read += $read;
#}
my $m = unpack('CType/@1/ILength', sysread(F, $_, $size));
close F;

print "Initial size: $size bytes \n";
print "Total read: $total_read bytes.\n";

print Dumper($m);

print "Date object was created: ".$CacheObject->getCreationDate."\n";
print "Date object was last modified: ".$CacheObject->getModifiedDate."\n";

print "Human readable size of object is ".$CacheObject->getSize."\n";
