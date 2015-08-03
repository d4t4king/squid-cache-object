#!/usr/bin/perl -w

use warnings;
use strict;
use Data::Dumper;
use Term::ANSIColor;

BEGIN { push @INC, '../' }
use Cache::Object;

my $CacheObject;
if (scalar(@ARGV) != 1) {
	die "Expect only 1 input: the path to the cache file.\n";
} else {
	# Instantiate the Squid::CacheObject object, providing 
	# the Squid cache file as an argument
	$CacheObject = Cache::Object->new($ARGV[0]);
}

#print $CacheObject->_getObjectSize;
# Dump the contents of the squid cache object
#print Dumper($CacheObject);

my $size = -s $CacheObject->{'_URL'};
my $total_read = 0;
my $buffer = '';
my $bufsize = 1024;

open F, "<$CacheObject->{'_URL'}" or die "Couldn't open file for reading: $! \n";
binmode F;
read(F, $buffer, $bufsize, 0);
close F;
my @lines = split(/\r\n/, $buffer);
my %tmp;
foreach my $line ( @lines ) {
	#print "LINE: $line\n";
	my ($k, $v) = split(/: /, $line);
	last if (((!defined($k)) || ($k eq '')) 
		&& ((!defined($v)) || ($v eq '')));
	if ($k !~ /^[A-Za-z]+/) {
		my @parts = split(//, $k);
		#foreach my $p ( @parts ) { print "$p\n"; }
	} else {
		unless ((!defined($k)) || ($k eq '')) {
			$tmp{$k} = $v;
		}
	}
	#print "\$k => $k; \$v => $v\n";
}
$CacheObject->{'_Headers'} = \%tmp;

#print Dumper($CacheObject->{'_Headers'});
#print colored("$CacheObject->{'_Headers'}{'ETag'}", "red");


print "\n";
print "="x72;
print "\n";

print "Initial size: $size bytes \n";
#print "Total read: $total_read bytes.\n";

print "Date object was created: ".$CacheObject->getCreationDate."\n";
print "Date object was last modified: ".$CacheObject->getModifiedDate."\n";

print "Human readable size of object is ".$CacheObject->getSize."\n";

print "Cache headers: \n";
foreach my $key ( sort keys %{$CacheObject->{'_Headers'}} ) {
	print "\t$key => $CacheObject->{'_Headers'}{$key},\n";
}
