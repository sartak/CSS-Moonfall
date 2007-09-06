# Load the Module::Install bundled in ./inc/
use inc::Module::Install;

# Define metadata
name           'Moonfall';
all_from       'lib//Moonfall.pm';

requires       '';

build_requires 'Test::More';

auto_install;
WriteAll;

