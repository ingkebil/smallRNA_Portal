package Index::Test;

use strict;
use warnings;
use Time::HiRes qw/ gettimeofday tv_interval /;
use Data::Dumper;
use DBI;

our $dbi = DBI->connect('dbi:mysql:database=smallrna_opt', 'kebil', 'kebil', { AutoCommit => 1 } );
# autocommit on to have a reconnect when the connection should time out

sub exe {
    my $title = shift;
    my $qs = shift;
    # { title => { q => 'SELECT .. ', data => \@data }
    # { title => { q => 'SELECT .. ', data => $data  }

    print "\n| $title |";
    while (my ($t, $exec) = each %$qs) {
        my $start = [gettimeofday()];
        my $sth = $dbi->prepare($exec->{ q });
        my $total = 1;
        if (@{ $exec->{ data } }) {
            foreach my $data (@{ $exec->{ data } }) {
                if (ref $data) {
                    $sth->execute( @$data );
                }
                else {
                    $sth->execute( $data );
                }
            }
            $total = scalar @{ $exec->{ data } };
        }
        else {
            $sth->execute();
        }
        my $stop = [gettimeofday()];

        printf " %.4f (%.4f) |", $total/tv_interval($start, $stop), tv_interval($start, $stop);
    }
}

1;

__END__

=head1 SYNOPSIS

Test different indexing strategies on annotations and srnas
