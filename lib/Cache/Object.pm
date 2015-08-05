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

	#my $fh;
	#open $fh, "<$self->{'_URL'}" or die "Couldn't open file fore reading: $! \n";
	#my $MetaDataHeader = unpack('CType/@1/ILength', sysread($fh, $_, $self->{'_Size'}));
	#close $fh;
	#print Dumper($MetaDataHeader);

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

1;

