#!/usr/bin/perl
#
package Cache::Object;

use strict;
use warnings;
no if $] >= 5.017011, warnings => 'experimental::smartmatch';
use feature qw( switch );
use Fcntl qw( SEEK_SET SEEK_CUR SEEK_END );
use Exporter;
use vars qw( $VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS );
use Digest::MD5 qw( md5_hex );
use Digest::SHA1 qw( sha1_hex );
use Data::Dumper;
use Date::Format;
use Term::ANSIColor;

$VERSION	= 0.01;
#@ISA		= qw( Exporter );
#@EXPORT		= ();
#@EXPORT_OK	= qw();
#%EXPORT_TAGS	= ( DEFAULT	=> [qw(&func1)],
#		Both	=> [qw(&func1 &func2)]);

sub new {
	my $class = shift;
	my $self = { 
		_URL			=> shift,
		_orig_URL		=> '',
		_http_status	=> '',
		_MD5			=> '',
		_SHA1			=> '',
		_KeyURL			=> '',
		_KeyMD5			=> '',
		_KeySHA			=> '',
		_Size			=> '',
		_Created		=> '',
		_Modified		=> '',
		_Headers		=> '',
		_Data			=> '',
		_MetaDataLength	=> 0,
		_HeadersOnly	=> 0, 	# false
		_objCreated		=> 0,	# false
	};
	#warn "we just created our new variables...\n";

	bless $self, $class;
	#warn "and now they are $class objects.\n";

	$self->{'_objCreated'} = 1;	# true

	my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
		$atime,$mtime,$ctime,$blksize,$blocks)
			= stat($self->{'_URL'});
	$self->{'_Size'} = $size;
	$self->{'_Created'} = $ctime;
	$self->{'_Modified'} = $mtime;

	$self->{'_MD5'} = md5_hex($self->{'_URL'});
	$self->{'_SHA1'} = sha1_hex($self->{'_URL'});

	$self->_read_bin;

	$self->_clean_hdrs;

	return $self;
}

sub getObjectSize {
	my $self = shift;

	my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
		$atime,$mtime,$ctime,$blksize,$blocks)
			= stat($self->{'_URL'});

	return $size;
}

sub getCreationDate {
	my $self = shift;
	return time2str('%c', $self->{'_Created'});
}

sub getModifiedDate {
	my $self = shift;
	return time2str('%c', $self->{'_Modified'});
}

sub getSize {
	my $self = shift;
	my $return = '';
	if ($self->{'_Size'} < 1024) {
		# bytes
		$return = $self->{'_Size'}." bytes";
	} elsif ($self->{'_Size'} < 1048576) {
		# kilobytes
		$return = sprintf('%d', ($self->{'_Size'} / 1024))." KB";
	} else {
		$return = sprintf('%d', ($self->{'_Size'} / 1048576))." MB";
	}
	return $return;
}

sub _read_bin {
	my $self = shift;
	my $class = shift;

	open(F, "<$self->{'_URL'}") or die "Could not open file for reading: $! \n";
	binmode(F);
	my ($buffer, $junk, $rest, $hdr) = '';
	# skip the first 54 bytes
	# as it seems to be junk, or some
	# sort of cache header
	seek(F, 64, SEEK_SET);
	# check for 'http'
	read(F, $buffer, 4);
	if ((unpack 'H*', $buffer) eq '68747470') {
		print colored("File: $self->{'_URL'}\n", "green");
		print colored("Found cache headers.\n", "green");
	} else {
		print colored("File: $self->{'_URL'}\n", "magenta");
		print colored(unpack('H*', $buffer)."\n", "magenta");
	}
	# try at 80 bytes
	seek(F, 12, SEEK_CUR);
	read(F, $buffer, 4);
	if ((unpack 'H*', $buffer) eq '68747470') {
		print colored("File: $self->{'_URL'}\n", "cyan");
		print colored("Found cache headers.\n", "cyan");
		seek(F, -4, SEEK_CUR);		# back it up to grab the "http"
		read(F, $self->{'_Headers'}, 353);
	} else {
		print colored("File: $self->{'_URL'}\n", "dark_yellow");;
		print colored(unpack('H*', $buffer)."\n", "dark_yellow");
	}
	close F;
}

sub _clean_hdrs {
	my $self = shift;
	my $class = shift;
	my %tmp;
	foreach my $line ( split(/\r\n/, $self->{'_Headers'}) ) {
		chomp($line);
		if ($line =~ /(http(?:s)?\:\/\/.+).*(HTTP\/1.[01]\s+\d{3}\s*\w+)/s) {
			$self->{'_orig_URL'} = $1; $self->{'_http_status'} = $2;
			#if ($self->{'_orig_URL'} =~ /(?:\x00|\r?\n)/) {
			#	$self->{'_orig_URL'} = (split(/$1/, $self->{'_orig_URL'}))[0];
			#}
			#$self->{'_orig_URL'} =~ s/\x00//g;
			#my $tmp = unpack('H*', $self->{'_orig_URL'});
			#my ($u, @junk) = split(/00/, $tmp);
			#$self->{'_orig_URL'} = $u;
			next;
		}
		my ($k, $v) = split(/\: /, $line);
		next if (((!defined($k)) || ($k eq '')) && ((!defined($v)) || ($v eq '')));
		$tmp{$k} = $v;
	}
	$self->{'_Headers'} = \%tmp;
}

1;

