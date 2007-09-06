#!perl
package Moonfall;
use strict;
use warnings;
use parent 'Exporter';

our @EXPORT = 'filter';

sub filter
{
    my $package = shift;
    my $in = shift;
    no strict 'refs';

    $in =~ s{
             \[       # literal
             ([^]]+)  # 1: some number of closing-bracket chars
             \]       # literal
            }{
                process(${$package.'::'.$1});
            }xeg;
    return $in;
}

sub process
{
    my $in = shift;

    if (ref($in) eq 'HASH')
    {
        $in = join ' ', map
        {
            (my $k = $_) =~ s/_/-/g;
            my $v = process($in->{$_});
            "$k: $v;";
        }
        sort keys %$in;
    }
    elsif ($in =~ /^\d+$/)
    {
        $in .= 'px';
    }

    return $in;
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

