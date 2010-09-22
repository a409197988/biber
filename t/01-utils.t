use strict;
use warnings;
use utf8;
no warnings 'utf8' ;

use Test::More tests => 10;
use Biber;
use Biber::Entry::Name;
use Biber::Entry::Names;
use Biber::Utils;
use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($ERROR);
my $biber = Biber->new(noconf => 1);

is( normalise_string('"a, b–c: d" ', 1),  'a bc d', 'normalise_string' );

Biber::Config->setoption('inputenc', 'latin1');
is( normalise_string_underscore('\c Se\x{c}\"ok-\foo{a},  N\`i\~no
    $§+ :-)   ', 1), 'Secoka_Nino', 'normalise_string_underscore 1' );

Biber::Config->setoption('inputenc', 'UTF-8');
is( normalise_string_underscore('\c Se\x{c}\"ok-\foo{a},  N\`i\~no
    $§+ :-)   ', 0), 'Şecöka_Nìño', 'normalise_string_underscore 2' );

is( normalise_string_underscore('{Foo de Bar, Graf Ludwig}', 1), 'Foo_de_Bar_Graf_Ludwig', 'normalise_string_underscore 2');

my $names = bless [
    (bless { namestring => '\"Askdjksdj, Bsadk Cklsjd', nameinitstring => '\"Askdjksdj, BC' }, 'Biber::Entry::Name'),
    (bless { namestring => 'von Üsakdjskd, Vsajd W\`asdjh', nameinitstring => 'v Üsakdjskd, VW'}, 'Biber::Entry::Name'),
    (bless { namestring => 'Xaskldjdd, Yajs\x{d}ajks~Z.', nameinitstring => 'Xaskldjdd, YZ'}, 'Biber::Entry::Name'),
    (bless { namestring => 'Maksjdakj, Nsjahdajsdhj', nameinitstring => 'Maksjdakj, N'  }, 'Biber::Entry::Name')
], 'Biber::Entry::Names';

is( makenameid($names), 'Äskdjksdj_Bsadk_Cklsjd_von_Üsakdjskd_Vsajd_Wàsdjh_Xaskldjdd_Yajsdajks_Z_Maksjdakj_Nsjahdajsdhj', 'makenameid' );


is( latexescape('Joe & Sons: $3.01 + 5% of some_function()'),
               'Joe \& Sons: \$3.01 + 5\% of some\_function()',
               'latexescape'); 

my @arrayA = qw/ a b c d e f c /;
my @arrayB = qw/ c e /;
my @AminusB = reduce_array(\@arrayA, \@arrayB);
my @AminusBexpected = qw/ a b d f /;

is_deeply(\@AminusB, \@AminusBexpected, 'reduce_array') ;

is(remove_outer('{Some string}'), 'Some string', 'remove_outer') ;

my $pstring = '{$}Some string & with \% some specials and then {some \{ & % $^{3}$
protected specials} and then some more things % $$ _^';

my $pstring_processed = '{$}Some string \& with \% some specials and then {some \{ & % $^{3}$
protected specials} and then some more things \% \$\$ \_\^';

is( latexescape($pstring), $pstring_processed, 'latexescape test');

is( normalise_string_lite('Ä.~{\c{C}}.~{\c S}.'), 'ÄCS', 'normalise_string_lite' ) ;


# vim: set tabstop=4 shiftwidth=4:
