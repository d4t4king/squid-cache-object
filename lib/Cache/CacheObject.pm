#!/usr/bin/perl
#
package CacheObject;

use strict;
use warnings;
no if $] >= 5.017011, warnings => 'experimental::smartmatch';
use feature qw( switch );
use Fcntl qw( SEEK_SET SEEK_CUR SEEK_END );
use Exporter;
use vars qw( $VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS );

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
		_created		=> 0,	# false
	};
	warn "we just created our new variables...\n";

	bless $self, $class;
	warn "and now they are $class objects.\n";

	$self->{'_created'} = 1;	# true
	return $self;
}

1;

