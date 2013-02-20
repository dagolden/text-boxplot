use 5.008001;
use strict;
use warnings;
use Test::More 0.96;
use Test::Deep '!blessed';
use Test::Fatal;

use Text::BoxPlot qw/render/;

my @cases = (
    {
        label => "single",
        data => [[ "test", -2.5, -1, 0, 1, 2.5 ]],
    },
    {
        label => "double",
        data => [
            [ "test", -2.5, -1, 0, 1, 2.5 ],
            [ "test", 0, 1, 5, 10, 30 ],
        ],
    },
);

for my $c ( @cases ) {
    subtest $c->{label} => sub {
        for my $i ( 10 .. 80 ) {
            my $which = 0;
            for my $s ( render( { width => $i }, @{$c->{data}} ) ) {
                my $label = "$c->{label} (" . join(", ", @{$c->{data}[$which++]}) . ")";
                ok( length($s) <= $i, "length $i for  $label" ) or diag "GOT: |$s|, length " . length($s);
                like( $s, qr/test\s+<?-*=*O=*-*>?/, "box format for $label" );
            }
        }

    };
}

done_testing;
# COPYRIGHT
# vim: ts=4 sts=4 sw=4 et:
