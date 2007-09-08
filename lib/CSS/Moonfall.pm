#!perl
package CSS::Moonfall;
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
             (.*?)    # 1: indentation / check for other chars on the line
             \[       # literal
             ([^]]+)  # 2: what we want to filter
             \]       # literal
             (.*)     # 3: check for other chars on the line
            }{
                $1 . _process($package, $2, 1, $1, $3) . $3
            }xeg;
    return $in;
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

# this is where all the logic of expanding [foo] into some arbitrary string is
sub _process
{
    my $package = shift;
    my $in = shift;
    my $top = shift;
    my $pre = shift;
    my $post = shift;

    $in =~ s/^\s+//;
    $in =~ s/\s+$//;

    if ($in =~ /^[a-zA-Z]\w*/)
    {
        return $in if !$top;
        $in = '$' . $in;
    }

    my $out = $top ? eval "package $package; no strict 'vars'; $in" : $in;

    my @kv = _expand($out);

    if (@kv > 1)
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
            my ($k, $v) = @$_;
            $k =~ s/_/-/g;
            $v = _process($package, $v, 0, $pre, $post);
            ($first++ ? $indent : '') . "$k: $v;";
        }
        sort {$a->[0] cmp $b->[0]} @kv;
    }
    elsif ($kv[0] =~ /^\d+$/)
    {
        $out .= 'px';
    }

    return $out;
}

# try to expand an array/hash ref, recursively, into a list of pairs
# if a value is a reference, then the key is dropped and the value is expanded
# in place
sub _expand
{
    my $in = shift;
    return $in if !ref($in);

    my @kv;

    if (ref($in) eq 'HASH')
    {
        while (my ($k, $v) = each %$in)
        {
            if (ref($v))
            {
                push @kv, _expand($v);
            }
            else
            {
                push @kv, [$k => $v];
            }
        }
    }
    elsif (ref($in) eq 'ARRAY')
    {
        if (ref($in->[0]) eq 'ARRAY')
        {
            for (@$in)
            {
                my ($k, $v) = @$_;
                if (ref($v))
                {
                    push @kv, _expand($v);
                }
                else
                {
                    push @kv, [$k => $v];
                }
            }
        }
        else
        {
            my $i;
            for ($i = 0; $i < @$in; $i += 2)
            {
                my ($k, $v) = ($in->[$i], $in->[$i+1]);
                if (ref($v))
                {
                    push @kv, _expand($v);
                }
                else
                {
                    push @kv, [$k => $v];
                }
            }
        }
    }

    return @kv;
}

=head1 NAME

CSS::Moonfall - port of a Lua CSS generation library

=head1 VERSION

Version 0.01 released 06 Sep 07

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

    package MySite::CSS;
    use CSS::Moonfall;
    our $page_width = 1000;
    our $colors = { background => '#000000', color => '#FFFFFF' };

    package main;
    print MySite::CSS->filter(<<"CSS");
    body { width: [page_width]; }
    #header { width: [$page_width-20]; $colors }
    CSS

=head1 DESCRIPTION

C<Moonfall> is a program for the dynamic generation of CSS. The problem it
solves is making CSS more programmable. The most basic usage is to define
variables within CSS (e.g., so similar elements can have their common color
defined in one and only one place).

See L<http://moonfall.org/> for more details.

=head1 FUNCTIONS

The C<CSS::Moonfall> module has two exports: C<fill> and C<filter>. C<fill> is
to be used by the Moonfall script itself, to aid in the creation of auto-sized
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
Text within brackets C<[...]> is filtered through C<eval>.

As a convenience, barewords (such as C<[foo]>) will be replaced with the value
of the global scalar with that name. If that scalar is a hash reference, then
each (key, value) pair will be turned into CSS-style C<key: value;>
declarations. You may use underscores in key names instead of C<-> to avoid
having to quote the key. This means that if you want to call functions, you
must include a pair of parentheses or something else to distinguish it from
a bareword (this is exactly the restriction on using unquoted variables in
C<$hash{key}>)

If any value looks like a plain integer, it will have C<px> appended to it.

=head1 SEE ALSO

The original Lua Moonfall: L<http://moonfall.org/>

=head1 AUTHOR

Shawn M Moore, C<< <sartak at gmail.com> >>

=head1 BUGS

No known bugs.

Please report any bugs through RT: email
C<bug-moonfall at rt.cpan.org>, or browse to
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=CSS-Moonfall>.

=head1 SUPPORT

You can find this documentation for this module with the perldoc command.

    perldoc CSS::Moonfall

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/CSS-Moonfall>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/CSS-Moonfall>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=CSS-Moonfall>

=item * Search CPAN

L<http://search.cpan.org/dist/CSS-Moonfall>

=back

=head1 COPYRIGHT AND LICENSE

Copyright 2007 Shawn M Moore.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;

