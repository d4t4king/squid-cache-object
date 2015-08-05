#!/usr/bin/perl -w

use warnings;
use strict;
use Data::Dumper;
use Term::ANSIColor;
use Data::HexDump;

#BEGIN { push @INC, '../' }
use Cache::Object;

my @cacheObjs;
my $totalCount = 0;
my $cachedir = '/var/spool/squid/cache';
my @hex = ( '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F' );
foreach my $h ( @hex ) {
	foreach my $uh1 ( @hex ) {
		foreach my $uh2 ( @hex ) {
			my $dir = "$cachedir/0$h/$uh1$uh2";
			opendir (DIR, "$dir") or die "Couldn't open cache dir ($dir): $! \n";
			while (my $file = readdir(DIR)) {
				next if ($file =~ /^\.\.?/);
				print "$file\n";
				$totalCount++;
				my $sco = new Cache::Object("$dir/$file");
				push @cacheObjs, $sco;
			}
			closedir(DIR) or die "Couldn't close cache dir: $dir: $!\n";
		}
	}
}

print "Found a total of $totalCount objects.\n";

#print Dumper(@cacheObjs);

my $buffer;
print "Hex dumping the first object in the array: \n";
my $hd = new Data::HexDump;
open F, "<$cacheObjs[0]->{'_URL'}" or die "Couldn't open cache object: $! \n";
binmode F;
read(F, $buffer, 1024);
close(F);

$hd->data($buffer);
print $hd->dump;

print "Just for giggles....:\n";
print `strings $(echo $buffer)`;
