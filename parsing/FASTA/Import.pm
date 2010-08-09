package FASTA::Import;

use strict;
use warnings;

use DBI;

use Settings qw/:DB/;
use FASTA::Reader;
use SRNA::DBAbstract;

&run() unless caller();

sub run {
    my $import = new FASTA::Import($ARGV[0]);

    my $seqs  = $import->{ seqs  };
    my $srnas = $import->{ srnas };
    my $f     = $import->{ freader };
    foreach my $fasta_id (@{ $f->get_all_fasta_id($ARGV[0]) }) {
        my $r = $srnas->get_record(name => $fasta_id);
        if (! defined $r) {
            my $srna_id = $r->{ id };
            my $seq = $f->get_seq($fasta_id);
            my $seq_id = $seqs->get_id(seq => $seq);
            if ( ! $seq_id) {
                $seq_id = $seqs->add(seq => $seq);
            }
            $r->{ seq_id } = $seq_id;
            $srnas->add($r);
        }
    }
    print Dumper $seqs->get_new_rows_CSV('id', 'seq');
    print Dumper $srnas->get_new_rows_CSV('id', 'name', 'start', 'stop', 'strand', 'sequence_id', 'score', 'type_id', 'abundance', 'normalized_abundance', 'experiment_id', 'chromosome_id');
}

sub new {
    my $inv = shift;
    my $filename = shift;

    my $dbh     = DBI->connect('dbi:mysql:database=' . DB, USER, PASS);
    my $freader = new FASTA::Reader({ filename => $filename });
    my $seqs    = new SRNA::DBAbstract({ dbh => $dbh, table => 'sequences' });
    my $srnas   = new SRNA::DBAbstract({ dbh => $dbh, table => 'srnas' });

    my $self = {
        fasta => $filename,
        freader => $freader,
        seqs => $seqs,
        srnas => $srnas
    };

    return bless $self, ref $inv || $inv;
}

sub csv_adder {
    my $self = shift;
    my $type = shift;

    push @{ $self->{ return }->{ csv }->{ $type } },
        join qq{\t},
        map { $self->{ dbh }->quote($_); }
        @_;
}

1;

__END__
