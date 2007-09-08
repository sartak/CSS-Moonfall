# Load the Module::Install bundled in ./inc/
use inc::Module::Install;

# Define metadata
name           'Moonfall';
all_from       'lib//Moonfall.pm';

requires       'parent';
requires       'Exporter';
requires       'Carp';

build_requires 'Test::More';

auto_install;
WriteAll;

