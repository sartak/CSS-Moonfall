# Load the Module::Install bundled in ./inc/
use inc::Module::Install;

# Define metadata
name           'CSS-Moonfall';
all_from       'lib/CSS/Moonfall.pm';
author         'Shawn M Moore, C<< <sartak at gmail.com> >>';

requires       'Text::Balanced' => '2.0.0';
requires       'parent';
requires       'Exporter';
requires       'Carp';

build_requires 'Test::More';

auto_install;
WriteAll;

