package Net::DNS::Async::Simple;

use Modern::Perl;
use Net::DNS::Async;
use Data::Dumper;

sub massDNSLookup {
    my $list = shift
        or die 'Net::DNS::Async::Simple: one argument required';
    die 'Net::DNS::Async::Simple: first required argument must be an ARRAY reference'
        if not ref $list or ref $list ne 'ARRAY';
    my $async = new Net::DNS::Async(QueueSize => 20, Retries => 3);

    my $callback = sub {
        my ($index, $response) = @_;
        if(not $response) {     #timeout
            $list->[$index]->{timeout} = 1;
            return;
        }
        my @answers = $response->answer;
        if(not scalar @answers) {
            $list->[$index]->{error} = "returned no answers via";
            return;
        }
        foreach my $answer (@answers) {
            if(ref $answer eq 'Net::DNS::RR::A') {
                $list->[$index]->{name} = $answer->name;
                $list->[$index]->{address} = $answer->address;
            } elsif(ref $answer eq 'Net::DNS::RR::PTR') {
                $list->[$index]->{ptrdname} = $answer->ptrdname;
            }
        }
    };

    my $i = 0;
    while($list->[$i]) {
        my $j = $i;
        $async->add(
            sub {
                $callback->($j, @_)
            }, @{$list->[$j]->{query}}
        );
        $i++;
    }
    $async->await;
    return undef;
}

1;

__END__

=head1 NAME

Net::DNS::Async::Simple - A simple wrapper around the excellent Net::DNS::Async

=head1 SYNOPSIS

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
    ok $list->[1]->{ptrdname} eq 'tendorfour.realms.org', 'reverse lookup worked';

=head1 DESCRIPTION


=head1 FUNCTIONS

=head2 massDNSLookup($list, %extraArgs);

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

=item timeout

Will force this function to return in no more than this many seconds.


=head1 TODO

=head1 BUGS

None known.

=head1 AUTHOR

Dana M. Diederich <dana@realms.org>

=head1 COPYRIGHT

Copyright (c) 2016 Dana M. Diederich. All Rights Reserved.
This module is free software. It may be used, redistributed
and/or modified under the terms of the Perl Artistic License
  (see http://www.perl.com/perl/misc/Artistic.html)

=cut
