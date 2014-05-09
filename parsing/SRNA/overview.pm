#!/usr/bin/perl

use strict;
use warnings;
use Settings q/:DB/;
use DBI;
use Getopt::Long;
use Pod::Usage;
use Smart::Comments;

### LOADED
&runagain() unless caller();
### RAN

# too slow because of the group by on a joined table
sub run {
    my $exp_id = 0;
    
    my $opts = GetOptions(
        'exp_id=i' => \$exp_id
    );

    pod2usage(2) if (!$exp_id);
    
    my $dbh = DBI->connect('dbi:mysql:database='.DB, USER, PASS);

    open(F, '>', $exp_id);
    my $qexp_id = $dbh->quote($exp_id);
    my $sql = "
        SELECT Seq.seq, sum(Srna.abundance)
        FROM srnas Srna
        JOIN sequences Seq ON Seq.id = Srna.sequence_id
        WHERE Srna.experiment_id = $qexp_id 
        GROUP BY Seq.seq
    ";
    my $rs = $dbh->selectall_arrayref($sql);

    for my $line (@$rs) {
        print F join "\t", @$line;
        print F "\n";
    }
    close F;
}

# excellent :)
sub runagain {
    my $exp_id = 0;
    
    my $opts = GetOptions(
        'exp_id=i' => \$exp_id
    );

    pod2usage(2) if (!$exp_id);
    
    my $dbh = DBI->connect('dbi:mysql:database='.DB, USER, PASS);
    ### CONNECTED

    # get the right experiment name
    my $qexp_id = $dbh->quote($exp_id);
    ### QUOTED
    my $exp_name = $dbh->selectrow_arrayref("SELECT name FROM experiments WHERE id = $qexp_id");
    ### GOT EXP
    if (!$exp_name) {
        ### NOT FOUND
        die "Experiment not found in DB!\n";
    }
    $exp_name = $exp_name->[0];

    open(F, '>', "$exp_name.csv");
    # query to determine the averange abundancy per sequence.
    # I am unsure if a sequence would be repeated within the same experiment and still get another smallRNA identifier.
    my $srnas = $dbh->selectall_arrayref("SELECT avg(abundance), sequence_id FROM srnas WHERE experiment_id = $qexp_id GROUP BY sequence_id");
    ### SELECTED
    #my $srnas = $dbh->selectall_arrayref("SELECT count(*), sequence_id FROM srnas WHERE experiment_id = $qexp_id GROUP BY sequence_id");

    my $seq_h = $dbh->prepare('SELECT seq FROM sequences WHERE id = ?');
    print scalar(@$srnas);
    for my $srna (@$srnas) { ### [%]
        my $seq = $dbh->selectrow_arrayref($seq_h, undef, ($srna->[1]))->[0];
        print F "$seq\t$srna->[0]\n";
    }
    close F;
}

__END__

=head1 SYNOPSIS

Usage: perl SRNA::overview experiment_id [options]

Dumps the DB into a abundance per sequence per experiments format.

Options:
    --exp_id: the id if the experiment as in the DB
