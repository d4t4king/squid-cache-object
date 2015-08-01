#!/usr/bin/perl -w

use warnings;
use strict;

BEGIN { push @INC, '../' }

use Data::Dumper;
use Cache::Object;

# Instantiate the Squid::CacheObject object, providing 
# the Squid cache file as an argument
my $CacheObject = Cache::Object->new('./000005B1');

#print $CacheObject->_getObjectSize;
# Dump the contents of the squid cache object
#print Dumper($CacheObject);

my $size = -s $CacheObject->{'_URL'};
my $total_read = 0;
my $buffer = '';
my $bufsize = 2048;

open F, "<$CacheObject->{'_URL'}" or die "Couldn't open file for reading: $! \n";
binmode F;
read(F, $buffer, $bufsize, 0);
#while ( my $read = sysread(F, $buffer, $bufsize, ) ) {
#	printf "Read %8u bytes\n", $read;
#	# do something with $buffer
#	print "|".unpack('CType/@1/ILength', $buffer)."|\n";
#	$total_read += $read;
#}
#my $m = unpack('CType/@1/ILength', sysread(F, $_, $size));
close F;

my @row;
for (my $i=0; $i < length(split(/\n/, $buffer)); $i++) {
	foreach (split(//, $buffer)) {
	#if (hex(ord($_)) > 255) {
	#	print ".";
	#} else {
	#	printf("%02x", ord($_));
		print "$_";
	#}
	#	push @{$row[$i]}, $_;
		#print "\n" if $_ eq "\n";
		#next if ($_ eq "\n");
	}
}
#for (my $i=0; $i < length(split(/\n/, $buffer)); $i++) {
#	foreach my $ele ( @{$row[$i]} ) {
#		printf("%02x", ord($ele));
#	}
#	print "\n";
#	foreach my $ele ( @{$row[$i]} ) {
#		print "$ele";
#	}
#	print "\n";
#}

#my @rows = split(/\n/, $buffer);
#foreach my $row ( @rows ) {
#	foreach (split(//, $row)) {
#		if ((ord($_) > 10) && (ord($_) <= 255)) {
#			print "$_";
#			#printf("%02x", ord($_));
#		} else {
#			print ".";
#		}
#		print "\n" if ord($_) == 10;
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
