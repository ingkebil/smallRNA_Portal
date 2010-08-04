package SRNA::Chroms;

use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;
###use Smart::Comments;
use DBI;

use Settings q/:DB/;
use FASTA::Reader;
use SRNA::DBAbstract;

&run() unless caller;

sub run {
    my $gfffile = q{};
    my ($exp_id, $species_id) = 0;
    my ($path, $type, $fasta_file, $fasta_id_regex, $chr_fasta) = q{};

    my $opts = GetOptions(
        'path:s' => \$path,
        'fasta:s' => \$fasta_file,
        'fasta_id_regex:s' => \$fasta_id_regex,
        'speciesid:i' => \$species_id,
    );

    # pod2usage(2) if !$ARGV[0];

    $fasta_id_regex = $fasta_id_regex || '>(.*)';

    my $dbh     = DBI->connect('dbi:mysql:database='. DB, USER, PASS) or die "Could not connect to DB\n";
    my $chroms  = new SRNA::DBAbstract({ dbh => $dbh, table => 'chromosomes' });
    my $freader = new FASTA::Reader({ filename => $fasta_file, 'id_regex' => $fasta_id_regex });
    $freader->_fasta($fasta_file); # force read
    foreach my $chr_name (@{ $freader->get_all_fasta_id($fasta_file) }) {
        if ( ! $chroms->get_id('name' => $chr_name)) {
            my $chr_len = length ${ $freader->get_seq_ref($fasta_file, $chr_name) };
            $chroms->add({ name => $chr_name, length => $chr_len, species_id => $species_id });
        }
    }

    &fprint("$path/chromosomes.csv", join("\n", @{ $chroms->get_new_rows_CSV('id', 'name', 'length', 'species_id') }));
}

sub fprint {
    my $file = shift;
    my $content = shift;

    if (open(F, '>', $file)) {
        print F $content;
        close F;
    }
    else {
        warn "Failed to write to $file!";
    }
}

1;
