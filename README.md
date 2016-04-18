# NAME

Net::DNS::Async::Simple - A simple wrapper around the excellent Net::DNS::Async

# SYNOPSIS

    use Net::DNS::Async::Simple;
    use Test::More;
    my $list = [
        {   query => ['www.realms.org','A'],
        },{ query => ['174.136.1.7','PTR'],
            useResolvers => ['8.8.4.4','4.2.2.2']
        }
    ];
    Net::DNS::Async::Simple::massDNSLookup($list);
    ok $list->[0]->{address} eq '174.136.1.7', 'forward lookup worked';
    ok $list->[1]->{ptrdname} eq 'tendotfour.realms.org', 'reverse lookup worked';

# DESCRIPTION

# FUNCTIONS

## massDNSLookup($list, %extraArgs);

Takes one required argument, which is an ARRAY reference, each entry
contains a HASH reference containing at least a 'query' attribute, which
is itself an ARRAY reference.  These arguments end up being passed
into a Net::DNS::Resolver::query call, the semantics of which depend
on the specific kind of DNS record being looked up.

For more record types, the first query argument is the 'key' (for
A records, the name to be looked up, for example) and the second query
argument is the type of DNS record.

The results of the DNS query are added to the appropriate HASH
reference, using the same keys that come back from response, as
a Net::DNS::Packet object.  For A records, this will populate
the 'name' and 'address' fields.  PTR will populate the 'ptrdname'
field.

This function will never throw an exception, nor does it return
anything useful.  Timeouts and errors will be added to the
individual HASH references as appropriate.

%extraArgs is optional.

- timeout

    Will force this function to return in no more than this many seconds.

# TODO

# BUGS

None known.

# AUTHOR

Dana M. Diederich <dana@realms.org>

# COPYRIGHT

Copyright (c) 2016 Dana M. Diederich. All Rights Reserved.
This module is free software. It may be used, redistributed
and/or modified under the terms of the Perl Artistic License
  (see http://www.perl.com/perl/misc/Artistic.html)

# POD ERRORS

Hey! **The above document had some coding errors, which are explained below:**

- Around line 50:

    '=item' outside of any '=over'

- Around line 55:

    You forgot a '=back' before '=head1'
