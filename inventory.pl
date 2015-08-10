#!/usr/bin/perl -w

use warnings;
use strict;
use Data::Dumper;
use Term::ANSIColor;
use Data::HexDump;
use Fcntl qw( SEEK_SET SEEK_CUR SEEK_END );
use Date::Calc qw( Today_and_Now );
use DBI;
#use DBD::Sqlite;

#BEGIN { push @INC, '../' }
use Cache::Object;

my %sha1s;
my $dbh = DBI->connect(
	"dbi:SQLite:dbname=cache.db",
	"",
	"",
	{ RaiseError => 1 },
) or die $DBI::errstr;
my $sth = $dbh->prepare('SELECT sha1sum FROM cache');
$sth->execute();
while (my @row = $sth->fetchrow_array()) {
	$sha1s{$row[0]} = 1;
}
$sth->finish();
my @cacheObjs;
my $lt = localtime();
my ($year, $month, $day, $hour, $min, $sec) = Today_and_Now($lt);
my $Today_and_Now = "$year-$month-$day $hour:$min:$sec";
my $totalCount = 0;
my $totalInserted = 0;
my $cachedir = '/var/spool/squid/cache';
my @hex = ( '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F' );
foreach my $h ( @hex ) {
	foreach my $uh1 ( @hex ) {
		foreach my $uh2 ( @hex ) {
			my $dir = "$cachedir/0$h/$uh1$uh2";
			opendir (DIR, "$dir") or die "Couldn't open cache dir ($dir): $! \n";
			while (my $file = readdir(DIR)) {
				next if ($file =~ /^\.\.?/);
				#print "$file\n";
				$totalCount++;
				my $sco = new Cache::Object("$dir/$file");
				push @cacheObjs, $sco;
				print <<EOB;
	URL			=>	$sco->{'_orig_URL'}
	FILE_PATH		=>	$sco->{'_URL'}
	CONTENT_TYPE		=>	$sco->{'_Headers'}{'Content-Type'}
	FILE_SIZE		=>	$sco->{'_Size'}
	MD5			=>	$sco->{'_MD5'}
	SHA1			=>	$sco->{'_SHA1'}
	DATE_ENTERED		=>	$Today_and_Now
EOB

				if (!exists($sha1s{$sco->{'_SHA1'}})) {
					$dbh->do("INSERT INTO cache (file_path, content_type, file_size_bytes, md5sum, sha1sum, date_entered) VALUES ('$sco->{'_URL'}', '$sco->{'_Headers'}{'Content-Type'}', '$sco->{'_Size'}', '$sco->{'_MD5'}', '$sco->{'_SHA1'}', '$Today_and_Now');");
					$totalInserted++;
				}
			}
			closedir(DIR) or die "Couldn't close cache dir: $dir: $!\n";
		}
	}
}
$dbh->disconnect();

print "Found a total of $totalCount objects.\n";
print "Inserted a total of $totalInserted new records.\n";

#print "Dumping first object: \n";
#print Dumper($cacheObjs[0]);

#&_read_bin($cacheObjs[0]->{'_URL'});
#print Dumper(@cacheObjs);

#my ($xdr, $buffer, $length, $hdr_glob) = '';
#print "Checking file $cacheObjs[0]->{'_URL'}\n";
#open F, "<$cacheObjs[0]->{'_URL'}" or die "Couldn't open cache object: $! \n";
#binmode F;
#while (read(F, $buffer, 1) != 0) {
#	print "|".unpack('H*', $buffer)."|\n";
#	if ((unpack('H*', $buffer)) eq 'ff') {
#		read(F, $buffer, 1);
#		if ((unpack('H*', $buffer)) eq 'd8') {
#			# found a jpeg image
#			print "Found a JPEG image.\n";
#		}
#	} else {
#		$xdr .= $buffer;
#	}
#}
#close(F);
sub _read_bin {
	my $file = shift;
	open(F, "<$file") or die "Could not open file for reading: $! \n";
	binmode(F);
	my ($buffer, $junk, $rest, $hdr) = '';
	# skip the first 54 bytes
	# as it seems to be junk, or some
	# sort of cache header
	seek(F, 64, SEEK_SET);
	# check for 'http'
	read(F, $buffer, 4);
	if ((unpack 'H*', $buffer) eq '68747470') {
		print colored("Found cache headers.\n", "green");
	} else {
		print "File: $file\n";
		print colored(unpack('H*', $buffer)."\n", "yellow");
	}
	# try at 80 bytes
	seek(F, 12, SEEK_CUR);
	read(F, $buffer, 4);
	if ((unpack 'H*', $buffer) eq '68747470') {
		print colored("Found cache headers.\n", "green");
	} else {
		print "File: $file\n";
		print colored(unpack('H*', $buffer)."\n", "dark_yellow");
	}
}
