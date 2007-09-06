#!perl
package Moonfall;
use strict;
use warnings;
use parent 'Exporter';
use Carp;

our @EXPORT = qw/filter fill/;

sub filter
{
    my $package = shift;
    my $in = shift;

    $in =~ s{
             (.*?)
             \[       # literal
             ([^]]+)  # 1: some number of closing-bracket chars
             \]       # literal
             (.*)
            }{
                $1 . process($package, $2, 1, $1, $3) . $3
            }xeg;
    return $in;
}

sub process
{
    my $package = shift;
    my $in = shift;
    my $top = shift;
    my $pre = shift;
    my $post = shift;
    my $out = '';

    if ($top && $in =~ /\./)
    {
        $out = resolve($package, $in);
    }
    else
    {
        no strict 'refs';
        $out = $top ? ${$package.'::'.$in} : $in;
    }

    if (ref($out) eq 'HASH')
    {
        my $joiner = ' ';
        my $indent = '';
        if ($pre =~ /^\s*$/ && $post =~ /^\s*$/)
        {
            $joiner = "\n";
            $indent = $pre;
        }

        my $first = 0;
        $out = join $joiner, map
        {
            (my $k = $_) =~ s/_/-/g;
            my $v = process($package, $out->{$_}, 0, $pre, $post);
            ($first++ ? $indent : '') . "$k: $v;";
        }
        sort keys %$out;
    }
    elsif ($out =~ /^\d+$/)
    {
        $out .= 'px';
    }

    return $out;
}

sub resolve
{
    my $package = shift;
    my $in = shift;
    no strict 'refs';

    my @levels = split qr/\./, $in;
    my $global = shift @levels;
    my $current = ${$package.'::'.$global};

    $current = $current->{shift @levels}
        or croak "Malformed input."
            while @levels;

    return $current;
}

sub fill
{
    my $values = shift;
    my $total = delete $values->{total} or croak "You must define a total size in a call to fill.";
    my $unfilled = 0;

    for my $k (keys %$values)
    {
        if (defined(my $w = $values->{$k}))
        {
            $total -= $w;
        }
        else
        {
            ++$unfilled;
        }
    }

    $total = int($total / $unfilled);

    for (values %$values)
    {
        defined or $_ = $total;
    }

    return $values;
}

=head1 NAME

Moonfall - port of a Lua dynamic CSS generation library

=head1 VERSION

Version 0.01 released 06 Sep 07

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

    package Moonfall::MySite;
    use Moonfall;
    our $page_width = 1000;

    package main;
    use Moonfall::MySite;
    @css = map { Moonfall::MySite->filter($_) } @css;

=head1 DESCRIPTION

Moonfall is a Lua library for the dynamic generation of CSS. The problem it
solves is making CSS more programmable. The most basic usage is to define
variables within CSS (e.g., so similar elements can have their common color
defined in one and only one place).

See L<http://moonfall.org/> for more details.

=head1 FUNCTIONS

The C<Moonfall> module has two exports: C<fill> and C<filter>. C<fill> is to
be used by the Moonfall script itself, to aid in the creation of auto-sized
fields. C<filter> is used by modules calling your library to filter input.

=head2 fill HASHREF => HASHREF

Takes a hashref and uses the known values to fill in the unknown values. This
is mostly useful for dynamically calculating the width of multiple elements.

You must pass in a nonzero C<total> field which defines the total size. Pass
in known values in the usual fashion (such as: C<< center => 300 >>). Unknown
values should be explicitly set to C<undef> (such as: C<< left => undef >>).

Here's an example:

    fill { total => 1000, middle => 600, bottom => undef, top => undef }
        => { middle => 600, top => 200, bottom => 200 }

=head2 filter STRING => STRING

This takes the pseudo-CSS passed in and applies what it can to return real CSS.
Text within brackets C<[...]> is filtered.

Plain strings (such as C<[foo]>) will be replaced with the value of the global
scalar with that name (in this case, C<$Moonfall::MyApp::foo>). If that scalar
is a hash reference, then each (key, value) pair will be turned into CSS-style
C<key: value;> declarations. You may use underscores in key names instead of
C<-> to avoid having to quote the key.

If any value looks like a plain integer, it will have C<px> appended to it.

See the test distribution for concrete examples.

=head1 TODO

I haven't even looked at the C<Moonfall> source. It likely has some features
not listed on the front page. I suspect it supports full Lua evaluation, which
would mean this C<Moonfall> implementation is not interoperable with the
original version. Of course, in its stead, we would have full Perl evaluation.

=head1 SEE ALSO

The original Lua Moonfall: L<http://moonfall.org/>

=head1 AUTHOR

Shawn M Moore, C<< <sartak at gmail.com> >>

=head1 BUGS

No known bugs.

Please report any bugs through RT: email
C<bug-moonfall at rt.cpan.org>, or browse to
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Moonfall>.

=head1 SUPPORT

You can find this documentation for this module with the perldoc command.

    perldoc Moonfall

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Moonfall>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Moonfall>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Moonfall>

=item * Search CPAN

L<http://search.cpan.org/dist/Moonfall>

=back

=head1 COPYRIGHT AND LICENSE

Copyright 2007 Shawn M Moore.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;

