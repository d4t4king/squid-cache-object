#!/usr/bin/perl -w

use warnings;
use strict;

BEGIN { push @INC, '../' }

use Data::Dumper;
use Squid::CacheObject;

# Instantiate the Squid::CacheObject object, providing 
# the Squid cache file as an argument
my $CacheObject = Squid::CacheObject->new('./00000000');

# Dump the contents of the squid cache object
print Dumper($CacheObject);
