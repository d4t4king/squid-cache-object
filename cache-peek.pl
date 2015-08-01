#!/usr/bin/perl -w

use strict;
use warnings;
#no warnings "experimental::smartmatch";
use feature qw(switch);
use Getopt::Long;
#use XBase;
use Term::ANSIColor;

use Data::Dumper;

my ($cachedir, $file, $recursive, $further);
GetOptions(
	'c|cachedir=s'	=> \$cachedir,
	'f|file=s'		=> \$file,
	'r|recursive'	=> \$recursive,
	'i|further'	=> \$further,
);

my %pkg_types = (
	'application/x-gzip' => 1,
	'application/x-debian-package' => 1,
	'application/octet-stream' => 1,
	'application/x-bzip2' => 1,
	'application/x-tar' => 1,
	'application/x-gzip; charset=binary' => 1,
	'binary/octet-stream' => 1,
	'application/zip' => 1,
	'application/x-apple-webarchive' => '1',
);

my %video_types = (
	'video/x-flv' => '1',
	'video/x-mng' => '1',
	'video/webm' => '1',
	'video/mp4' => '1',
);

my (%further);

if ((!$cachedir) || (!$file)) {
	&usage;
}

if ($cachedir) {
	my %content_types;
	if ($recursive) {
		my @hex = ( '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F' );

		foreach my $h ( @hex ) {
			foreach my $uh1 ( @hex ) {
				foreach my $uh2 ( @hex ) {
					my $dir = "$cachedir/0$h/$uh1$uh2";
					opendir(DIR, "$dir") or die "Couldn't open cache dir ($cachedir): $! \n";
					while (my $file = readdir(DIR)) {
						print ".";
						my @strings = `strings $dir/$file | head -16`;
						#print "Found ".scalar(@strings)." strings.  Attempting to match HTTP headers.\n";
						foreach my $str ( @strings ) {
							given ($str) {
								when (/Content-Type: (.*)/) {
									my $type = $1;
									next if ((!defined($type)) || ($type eq ""));
									$content_types{$type}++;
									if (exists($pkg_types{$type})) {
										$further{$type}{"$dir/$file"}++;
										if ($type eq "application/x-tar") {
											system("scp $dir/$file charlie\@gentoo-32:/home/charlie/scripts/cache-peek/ > /dev/null 2>&1");
										}
									}
								}
								default { 
									#foo
								}
							}
						}
					}
					print "\n";
				}
			}
		}
		closedir(DIR);
	} else {
		opendir(DIR, "$cachedir") or die "Couldn't open cache dir: $! \n";
		while (my $file = readdir(DIR)) {
			my @strings = `strings $cachedir/$file | head -16`;
			#print "Found ".scalar(@strings)." strings.  Attempting to match HTTP headers.\n";
			foreach my $str ( @strings ) {
				given ($str) {
					when (/Content-Type: (.*)/) {
						my $type = $1;
						$type = lc($type);
						$content_types{$type}++;
					}
					default { 
						#foo
					}
				}
			}
		}
		closedir(DIR);
	}

	print colored("Content-Type:\t\t\t\t\tCached File Count:\n", "bold red");
	foreach my $k ( sort { $content_types{$b} <=> $content_types{$a} } keys %content_types ) {
		if (length($k) <= 9) {
			if (exists($pkg_types{$k})) {
				print colored("$k (".length($k)."):\t\t\t\t\t$content_types{$k}\n", "bold green");
			} elsif (exists($video_types{$k})) {
				print colored("$k (".length($k)."):\t\t\t\t\t$content_types{$k}\n", "magenta");
			} else {
				print "$k (".length($k)."):\t\t\t\t\t$content_types{$k}\n";
			}
		} elsif (length($k) <= 17) {
			if (exists($pkg_types{$k})) {
				print colored("$k (".length($k)."):\t\t\t\t$content_types{$k}\n", "bold green");
			} elsif (exists($video_types{$k})) {
				print colored("$k (".length($k)."):\t\t\t\t$content_types{$k}\n", "magenta");
			} else {
				print "$k (".length($k)."):\t\t\t\t$content_types{$k}\n";
			}
		} elsif (length($k) <= 25) {
			if (exists($pkg_types{$k})) {
				print colored("$k (".length($k)."):\t\t\t$content_types{$k}\n", "bold green");
			} elsif (exists($video_types{$k})) {
				print colored("$k (".length($k)."):\t\t\t$content_types{$k}\n", "magenta");
			} else {
				print "$k (".length($k)."):\t\t\t$content_types{$k}\n";
			}
		} elsif (length($k) <= 33) {
			if (exists($pkg_types{$k})) {
				print colored("$k (".length($k)."):\t\t$content_types{$k}\n", "bold green");
			} elsif (exists($video_types{$k})) {
				print colored("$k (".length($k)."):\t\t$content_types{$k}\n", "magenta");
			} else {
				print "$k (".length($k)."):\t\t$content_types{$k}\n";
			}
		} else {
			if (exists($pkg_types{$k})) {
				print colored("$k (".length($k)."):\t$content_types{$k}\n", "bold green");
			} elsif (exists($video_types{$k})) {
				print colored("$k (".length($k)."):\t$content_types{$k}\n", "magenta");
			} else {
				print "$k (".length($k)."):\t$content_types{$k}\n";
			}
		}
	}

	if ($further) {
		print "For further investigation:\n";
		foreach my $t ( sort keys %further ) {
			print colored("$t:\n", "green");
			foreach my $f ( sort keys %{$further{$t}} ) {
				print "\t$f\n";
			}
		}
	}
} elsif ($file) {
	open(IN, "<$file") or die "Couldn't open file: $! \n";
	binmode IN;
	close IN;
}

sub usage {
	print <<EOF;
Usage: $0 [-f|--file <filename>] [-c|--cachedir <cache/dir/path>] [-r|--recursive] [-i|--further]

-f|--file		Examine a singular file in the cache or local (speficied) directory
-c|--cachedir		Examine the entire cache dir specified
-i|--further		Store files for further inspection
-r|--recursive		Recursively parse the cache directory tree

EOF
	exit 1;
}
