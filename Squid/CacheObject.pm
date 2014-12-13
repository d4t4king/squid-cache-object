package CacheObject;

use strict;
use warnings;
use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION	= 0.01;
@ISA		= qw(Exporter);
@EXPORT		= ();
@EXPORT_OK	= qw();
%EXPORT_TAGS	= ( DEFAULT 	=> [qw(&func1)],
		Both		=> [qw(&func1 &func2)]);

1;
