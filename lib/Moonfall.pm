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
             \[       # literal
             ([^]]+)  # 1: some number of closing-bracket chars
             \]       # literal
            }{
                process($package, $1, 1);
            }xeg;
    return $in;
}

sub process
{
    my $package = shift;
    my $in = shift;
    my $top = shift;
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
        $out = join ' ', map
        {
            (my $k = $_) =~ s/_/-/g;
            my $v = process($package, $out->{$_}, 0);
            "$k: $v;";
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
    my $total = $values->{total} or croak "You must define a total size in a call to fill.";
    my $unfilled = 0;

    for my $k (keys %$values)
    {
        next if $k eq 'total';
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

Moonfall - ???

=head1 VERSION

Version 0.01 released ???

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

    use Moonfall;
    do_stuff();

=head1 DESCRIPTION



=head1 SEE ALSO

L<Foo::Bar>

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

