# -*- cperl -*-
use strict;
use warnings;
use utf8;
no warnings 'utf8';

use Test::More tests => 27;

use Biber;
use Biber::Utils;
use Biber::Output::bbl;
use Log::Log4perl;
chdir("t/tdata");

# Set up Biber object
my $biber = Biber->new(configfile => 'biber-test-variants.conf');
my $LEVEL = 'ERROR';
my $l4pconf = qq|
    log4perl.category.main                             = $LEVEL, Screen
    log4perl.category.screen                           = $LEVEL, Screen
    log4perl.appender.Screen                           = Log::Log4perl::Appender::Screen
    log4perl.appender.Screen.utf8                      = 1
    log4perl.appender.Screen.Threshold                 = $LEVEL
    log4perl.appender.Screen.stderr                    = 0
    log4perl.appender.Screen.layout                    = Log::Log4perl::Layout::SimpleLayout
|;
Log::Log4perl->init(\$l4pconf);

$biber->parse_ctrlfile("bibtex-variants.bcf");
$biber->set_output_obj(Biber::Output::bbl->new());

# Options - we could set these in the control file but it's nice to see what we're
# relying on here for tests

# Biber options
Biber::Config->setoption('sortlocale', 'C');
Biber::Config->setoption('fastsort', 1);

# THERE IS A CONFIG FILE BEING READ TO TEST USER MAPS TOO!

# Now generate the information
$biber->prepare;
my $out = $biber->get_output_obj;
my $section = $biber->sections->get_section(0);
my $bibentries = $section->bibentries;
my $main = $biber->sortlists->get_list(0, 'entry', 'nty');

my $f7 = [ "The variant enabled name field 'author' in entry 'forms7' has variants with different numbers of items. This will almost certainly cause problems.",
           "The variant enabled list field 'location' in entry 'forms7' has variants with different numbers of items. This will almost certainly cause problems." ];

is($bibentries->entry('forms1')->get_field('title'), 'Мухаммад ибн муса ал-Хорезми. Около 783 – около 850', 'forms - 1');
is($bibentries->entry('forms1')->get_field('title', 'original'), 'Мухаммад ибн муса ал-Хорезми. Около 783 – около 850', 'forms - 2');
is($bibentries->entry('forms1')->get_field('title', 'romanised'), 'Mukhammad al-Khorezmi. Okolo 783 – okolo 850', 'forms - 3');
is($bibentries->entry('forms1')->get_field('title', 'translated'), 'Mukhammad al-Khorezmi. Ca. 783 – ca. 850', 'forms - 4');
is($bibentries->entry('forms1')->get_field('publisher', 'original')->[0], 'Наука', 'forms - 5');
is($bibentries->entry('forms1')->get_field('author')->nth_name(2)->get_firstname, 'Борис', 'forms - 6');
# global labelname form
is($bibentries->entry('forms1')->get_field('labelname')->nth_name(2)->get_firstname, 'Борис', 'labelname - 1');
# per-type labelname form
is($bibentries->entry('forms2')->get_field('labelname')->nth_name(1)->get_firstname, 'Boris', 'labelname - 2');
# per-entry labelname form
is($bibentries->entry('forms3')->get_field('labelname')->nth_name(1)->get_firstname, 'Борис', 'labelname - 3');
# global labeltitle form
is($bibentries->entry('forms1')->get_field('labeltitle'), 'Мухаммад ибн муса ал-Хорезми. Около 783 – около 850', 'labeltitle - 1');
# per-type labeltitle form
is($bibentries->entry('forms2')->get_field('labeltitle'), 'Mukhammad al-Khorezmi. Okolo 783 – okolo 850', 'labeltitle - 2');
# per-entry labeltitle form
is($bibentries->entry('forms3')->get_field('labeltitle'), 'Mukhammad al-Khorezmi. Ca. 783 – ca. 850', 'labeltitle - 3');
is_deeply($bibentries->entry('forms7')->get_field('warnings'), $f7, 'MS warnings - 1') ;

my $S = { spec => [
         [
          {},
          {'author'     => {'form' => 'uniform'}},
          {'author'     => {}},
         ],
         [
          {},
          {'title'      => {'form' => 'translated', 'lang' => 'lang1'}},
          {'title'      => {'form' => 'translated', 'lang' => 'lang2'}},
          {'title'      => {}}
         ],
         [
          {},
          {'year'  => {}},
         ],
        ]};

$main->set_sortscheme($S);

$biber->set_output_obj(Biber::Output::bbl->new());
$biber->prepare;
$section = $biber->sections->get_section(0);
is_deeply([$main->get_keys], ['forms9', 'forms10', 'forms11', 'forms13', 'forms14', 'forms15', 'forms8', 'forms5', 'forms4', 'forms12', 'forms6', 'forms3', 'forms1', 'forms2', 'forms7'], 'Forms sorting - 1');

# reset options and regenerate information
Biber::Config->setblxoption('labelalphatemplate', {
  labelelement => [
             {
               labelpart => [
                 {
                  content                   => "author",
                  form                      => "uniform",
                  substring_width           => "3",
                  substring_side            => "left"
                 },
               ],
               order => 1,
             },
             {
               labelpart => [
                 {
                  content                   => "title",
                  form                      => "translated",
                  lang                      => "lang1",
                  substring_width           => "3",
                  substring_side            => "left"
                 },
                 {
                  content                   => "title",
                  substring_width           => "3",
                  substring_side            => "left"
                 },
               ],
               order => 2,
             },
           ],
  type  => "global",
});


foreach my $k ($section->get_citekeys) {
  $bibentries->entry($k)->del_field('sortlabelalpha');
  $bibentries->entry($k)->del_field('labelalpha');
  $main->set_extraalphadata_for_key($k, undef);
}

$biber->prepare;
$section = $biber->sections->get_section(0);
$main = $biber->sortlists->get_list(0, 'entry', 'nty');
$bibentries = $section->bibentries;

is($bibentries->entry('forms1')->get_field('sortlabelalpha'), 'BulRosМух', 'labelalpha forms - 1');
is($bibentries->entry('forms4')->get_field('sortlabelalpha'), 'F t', 'labelalpha forms - 2');
is($bibentries->entry('forms5')->get_field('sortlabelalpha'), 'A t', 'labelalpha forms - 3');
is($bibentries->entry('forms6')->get_field('sortlabelalpha'), 'Z t', 'labelalpha forms - 4');

my $forms1 = q|    \entry{forms1}{book}{}
      \name{labelname}{2}{}{%
        {{uniquename=0,hash=e7c368e13a02c9c0f0d3629316eb6227}{Булгаков}{Б\bibinitperiod}{Павел}{П\bibinitperiod}{}{}{}{}}%
        {{uniquename=0,hash=f5f90439e5cc9d87b2665d584974a41d}{Розенфельд}{Р\bibinitperiod}{Борис}{Б\bibinitperiod}{}{}{}{}}%
      }
      \name{author}{2}{}{%
        {{uniquename=0,hash=e7c368e13a02c9c0f0d3629316eb6227}{Булгаков}{Б\bibinitperiod}{Павел}{П\bibinitperiod}{}{}{}{}}%
        {{uniquename=0,hash=f5f90439e5cc9d87b2665d584974a41d}{Розенфельд}{Р\bibinitperiod}{Борис}{Б\bibinitperiod}{}{}{}{}}%
      }
      \name[form=uniform]{author}{2}{}{%
        {{hash=d3e42eb37529f4d05f9646c333b5fd5f}{Bulgakov}{B\bibinitperiod}{Pavel}{P\bibinitperiod}{}{}{}{}}%
        {{hash=87d0ec74cbe7f9e39f5bbc25930f1474}{Rosenfeld}{R\bibinitperiod}{Boris}{B\bibinitperiod}{}{}{}{}}%
      }
      \list{institution}{1}{%
        {University of Life}%
      }
      \list{location}{1}{%
        {Москва}%
      }
      \list[form=romanised]{location}{1}{%
        {Moskva}%
      }
      \list[form=uniform]{location}{1}{%
        {Moscow}%
      }
      \list{publisher}{1}{%
        {Наука}%
      }
      \list[form=romanised]{publisher}{1}{%
        {Nauka}%
      }
      \list[form=translated]{publisher}{1}{%
        {Science}%
      }
      \strng{namehash}{253fe13319a1daadcda3e2acce242883}
      \strng{fullhash}{253fe13319a1daadcda3e2acce242883}
      \field{labelalpha}{БР02}
      \field{sortinit}{Б}
      \field{labeltitle}{Мухаммад ибн муса ал-Хорезми. Около 783 – около 850}
      \true{singletitle}
      \field{day}{01}
      \field{month}{10}
      \field{title}{Мухаммад ибн муса ал-Хорезми. Около 783 – около 850}
      \field[form=romanised]{title}{Mukhammad al-Khorezmi. Okolo 783 – okolo 850}
      \field[form=translated]{title}{Mukhammad al-Khorezmi. Ca. 783 – ca. 850}
      \field{year}{2002}
    \endentry
|;

my $forms9 = q|    \entry{forms9}{book}{vtranslang=german,vlang=french}
      \field{sortinit}{0}
      \field{labeltitle}{Un titel}
      \field{langid}{french}
      \field{title}{Un titel}
    \endentry
|;

my $forms10 = q|    \entry{forms10}{book}{vlang=french}
      \field{sortinit}{0}
      \field{labeltitle}{Un titel}
      \field{langid}{french}
      \field{title}{Un titel}
    \endentry
|;

my $forms11 = q|    \entry{forms11}{book}{vlang=french}
      \field{sortinit}{0}
      \field{labeltitle}{Un titel}
      \field{langid}{french}
      \field{title}{Un titel}
    \endentry
|;

my $forms12 = q|    \entry{forms12}{unpublished}{}
      \field{sortinit}{T}
      \field{labeltitle}{TITLE}
      \true{singletitle}
      \field[form=translated,lang=french]{maintitle}{Maintitle translated FRENCH}
      \field[form=uniform,lang=german]{subtitle}{Subtitle uniform GERMAN}
      \field{title}{TITLE}
      \field[form=translated,lang=french]{title}{Title translated FRENCH}
    \endentry
|;

my $forms13 = q|    \entry{forms13}{unpublished}{}
      \field{sortinit}{0}
      \field[form=translated,lang=french]{journaltitle}{Jtitle translated french}
      \field[form=uniform,lang=french]{journaltitle}{Jtitle uniform french}
      \field[form=translated,lang=french]{note}{Note translated french}
      \field[form=translated,lang=german]{note}{Note translated german}
    \endentry
|;

my $forms14 = q|    \entry{forms14}{unpublished}{}
      \field{sortinit}{0}
      \field[lang=french]{journaltitle}{JTITLE french}
      \field[form=translated]{note}{NOTE translated}
    \endentry
|;

my $forms15 = q|    \entry{forms15}{unpublished}{}
      \field{sortinit}{0}
      \field[form=romanised]{booktitle}{German title}
    \endentry
|;

is($out->get_output_entry('forms1', $main), $forms1, 'bbl entry - forms 1') ;
is($bibentries->entry('forms8')->get_field('title', 'original', 'lang1'), 'L title', 'lang only');
is($out->get_output_entry('forms9', $main), $forms9, 'bbl entry - langid option') ;
is($out->get_output_entry('forms10', $main), $forms10, 'bbl entry - vtranslang same as global') ;
is($out->get_output_entry('forms11', $main), $forms11, 'bbl entry - vlang with unset options') ;
is($out->get_output_entry('forms12', $main), $forms12, 'bbl entry - mapping with forms/langs - 1') ;
is($out->get_output_entry('forms13', $main), $forms13, 'bbl entry - mapping with forms/langs - 2') ;
is($out->get_output_entry('forms14', $main), $forms14, 'bbl entry - mapping with forms/langs - 3') ;
is($out->get_output_entry('forms15', $main), $forms15, 'bbl entry - mapping with forms/langs - 4') ;