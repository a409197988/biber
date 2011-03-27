use strict;
use warnings;

use Test::More tests => 7;
use Biber;
use Cwd qw(getcwd);
use File::Spec;
use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($ERROR);
chdir('t/tdata');

my %colloptsA = ( level => 3, table => '/home/user/data/otherkeys.txt' );
my %nosort = (author => [ q/\A\p{L}{2}\p{Pd}/, q/[\x{2bf}\x{2018}]/ ],
              translator => q/[\x{2bf}\x{2018}]/ );

# Set up Biber object
my $biberA = Biber->new( configfile => 'biber-test.conf', mincrossrefs => 7 );
$biberA->parse_ctrlfile('general1.bcf');

is(Biber::Config->getoption('mincrossrefs'), 7, 'Options 1 - from cmdline');
is(Biber::Config->getoption('configfile'), File::Spec->catfile('biber-test.conf'), 'Options 2 - from cmdline');
is(Biber::Config->getoption('sortlocale'), 'testlocale', 'Options 3 - from config file');
is_deeply(Biber::Config->getoption('collate_options'), \%colloptsA, 'Options 4 - from config file');
is_deeply(Biber::Config->getoption('nosort'), \%nosort, 'Options 5 - from config file');
is_deeply(Biber::Config->getoption('sortcase'), 0, 'Options 6 - from .bcf');
is(Biber::Config->getoption('decodecharsset'), 'extra', 'Options 7 - from defaults');