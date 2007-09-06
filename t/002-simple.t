#!perl -T
use strict;
use warnings;
use Test::More tests => 1;

my $out = Moonfall::SimpleExample->filter(<<"INPUT");
#example  a { [nav_link_attrs] }
#contact  a { [nav_link_attrs] }
#list     a { [nav_link_attrs] }
#download a { [nav_link_attrs] }
INPUT

is($out, <<"EXPECTED", "simple example from moonfall.org works");
#example  a { float: right; line-height: 40px; margin-right: 5px; font-size: 1.1em; color: white; }
#contact  a { float: right; line-height: 40px; margin-right: 5px; font-size: 1.1em; color: white; }
#list     a { float: right; line-height: 40px; margin-right: 5px; font-size: 1.1em; color: white; }
#download a { float: right; line-height: 40px; margin-right: 5px; font-size: 1.1em; color: white; }
EXPECTED

BEGIN
{
    package Moonfall::SimpleExample;
    use Moonfall;

    # from Moonfall::SimplestExample, this suggests we want inheritance
    our $page_width = 1000;
    our $medium_em = "1.1em";

    our $nav_link_attrs = {
        float => "right",
        line_height => 40,
        margin_right => 5,
        font_size => $medium_em,
        color => "white",
    };
}

