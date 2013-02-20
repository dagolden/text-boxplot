use 5.008001;
use strict;
use warnings;

package Text::BoxPlot;
# ABSTRACT: Render ASCII box and whisker charts
# VERSION

use parent 'Exporter';
use List::AllUtils qw/min max/;

our @EXPORT_OK = qw/render/;

use constant {
    NAME => 0,
    MIN  => 1,
    Q1   => 2,
    MED  => 3,
    Q3   => 4,
    MAX  => 5,
};

# Box weight scales output so that window is a multiple of the full range of
# IQR.  This emphasizes the "box" part, particularly at small sizes, but keeps
# some display to show the "whiskers"

sub render {
    my $opt = ref( $_[0] ) eq 'HASH' ? shift : {};
    my (@datasets) = @_;
    my $width = $opt->{width} || 60;
    # XXX maybe croak if <=0 or >1?
    my $box_weight = 2 * max( 0, $opt->{box_weight} || 1 );

    my $smallest_min = min( map { $_->[MIN] } @datasets );
    my $smallest_q1  = min( map { $_->[Q1] } @datasets );
    my $biggest_q3   = max( map { $_->[Q3] } @datasets );
    my $biggest_max  = max( map { $_->[MAX] } @datasets );
    my $label_width  = max( map { length $_->[NAME] } @datasets );
    my $adj_width    = $width - $label_width - 2;

    my $span = ( $biggest_q3 - $smallest_q1 ) || 1;
    my $factor = $adj_width * $box_weight / ( 2 + $box_weight ) / $span;

    my $origin = int( $factor * ( $smallest_q1 - $span / $box_weight ) );
    my $edge   = int( $factor * ( $biggest_q3 + $span / $box_weight ) );
##    warn "SPAN: $span; FACTOR: $factor;  ORIGIN: $origin; EDGE: $edge; AW: $adj_width (" . ($edge - $origin) . ")\n";

    my @str;
    if ( $opt->{with_scale} ) {
        push @str,
          ( " " x ($label_width) )
          . sprintf( " |%-*g%*g|",
            $adj_width / 2,
            $origin / $factor,
            $adj_width / 2,
            $edge / $factor );
    }

    for my $d (@datasets) {
        my ( $name, @copy ) = @$d;
##        warn "PRECOPY: @copy\n";
        my @scaled = ( $name, map { int( $factor * $_ ) } @copy );
##        warn "POSTCOPY: @scaled\n";
        push @str, _render_one( \@scaled, $origin, $edge, $adj_width, $label_width );
    }

    return wantarray ? @str : $str[0];
}

sub _render_one {
    my ( $data, $origin, $edge, $frame_size, $label_width ) = @_;
##    warn "DATA: @$data\n";
    my $str = '';
    $str .= q{ } x ( max( $data->[MIN] - $origin, 0 ) );
    $str .= q{-} x ( $data->[Q1] - max( $data->[MIN], $origin ) );
    $str .= q{=} x ( $data->[MED] - $data->[Q1] );
    $str .= "O";
    $str .= q{=} x ( $data->[Q3] - $data->[MED] );
    $str .= q{-} x ( min( $data->[MAX], $edge ) - $data->[Q3] );
    $str .= q{ } x ( max( $edge - $data->[MAX], 0 ) );
##    warn "STR: " . length($str) . "\n";
    $str = substr($str,0, $frame_size);
##    $str =~ s{^(.{0,$frame_size})}{$1};
##    warn "STR: " . length($str) . "\n";

    if ( substr( $str, 0, 1 ) eq '-' ) {
        substr( $str, 0, 1, "<" );
    }

    if ( substr( $str, -1, 1 ) eq '-' ) {
        substr( $str, -1, 1, "->" );
    }

    $str =~ s{\s+$}{};
    return sprintf( "%*s %s", $label_width, $data->[NAME], $str );
}

1;

=for Pod::Coverage method_names_here

=head1 SYNOPSIS

  use Text::BoxPlot;

=head1 DESCRIPTION

This module might be cool, but you'd never know it from the lack
of documentation.

=head1 USAGE

Good luck!

=head1 SEE ALSO

Maybe other modules do related things.

=cut

# vim: ts=4 sts=4 sw=4 et:
