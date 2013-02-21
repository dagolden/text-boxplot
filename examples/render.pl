#!/usr/bin/env perl
use v5.10;
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use Text::BoxPlot;

my $tbp = Text::BoxPlot->new( with_scale => 1 );

say for $tbp->render( [ 'test data', -2.5, -1, 0, 1, 2.5 ] );
