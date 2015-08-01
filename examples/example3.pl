#!/usr/bin/perl -w

use warnings;
use strict;
use Fcntl qw( SEEK_SET );
use Data::Dumper;

BEGIN { push @INC, '../' }
use Cache::Object;

# Instantiate the Squid::CacheObject object, providing 
# the Squid cache file as an argument
my $CacheObject = Cache::Object->new('./000005B1');

my $size = -s $CacheObject->{'_URL'};
my $total_read = 0;
my $buffer = '';
my $bufsize = 1024;

my $string = "";
open F, "<$CacheObject->{'_URL'}" or die "Couldn't open file for reading: $! \n";
binmode F;
{
	local $/ = "\0";
	seek(F, 0, SEEK_SET) or die "Seek error: $! \n";
	$string = <F>;
	chomp $string;
}
print "$string\n";
close F;

#my @row;
#for (my $i=0; $i < length(split("\0", $buffer)); $i++) {
#	foreach (split(//, $buffer)) {
#		print "$_";
#	}
#}

print "\n";
print "="x72;
print "\n";

print "Initial size: $size bytes \n";
print "Total read: $total_read bytes.\n";

#print Dumper($m);

print "Date object was created: ".$CacheObject->getCreationDate."\n";
print "Date object was last modified: ".$CacheObject->getModifiedDate."\n";

print "Human readable size of object is ".$CacheObject->getSize."\n";
