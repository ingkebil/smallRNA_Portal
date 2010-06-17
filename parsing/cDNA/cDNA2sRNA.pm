package cDNA::cDNA2sRNA;

use strict;
use warnings;
use DBI;
use Getopt::Long;
use Pod::Usage;
use FASTA::Reader;
use Smart::Comments;
use Data::Dumper;
use Carp;
local $SIG{__WARN__} = \&Carp::cluck;
local $SIG{__DIE__} = \&Carp::confess;


&run() unless caller;

sub run {
    my $gfffile = q{};
    my ($source_id, $species_id) = 0;
    my ($species_name, $source_name, $path) = q{};

    my $opts = GetOptions(
        'sourceid:i' => \$source_id,
        'sourcename:s' => \$source_name,
        'speciesid:i' => \$species_id,
        'speciesname:s' => \$species_name,
        'path:s' => \$path,
    );

    pod2usage(2) if (! $source_id && ! $source_name);
    pod2usage(2) if (! $species_id && ! $species_name);

    $ARGV[0] || pod2usage(3);

    my $cdna2srna = __PACKAGE__->new();
    my $reader = new FASTA::Reader({ filename => $ARGV[0], id_regex => '>(.*)'});
    my $lines  = $reader->get_all_seq($ARGV[0]);
    $source_id = $cdna2srna->check_source($source_id, $source_name);
    $species_id = $cdna2srna->check_species($species_id, $species_name);

    my $results = $cdna2srna->run_parser($lines, $source_id, $species_id);
    $path .= q{/} if substr($path, -1, 1) ne q{/};

    print Dumper $results;

#    $cdna2srna->fprint($path . 'annotations.csv', join( "\n", @{ $results->{ annotations } }));
#    $cdna2srna->fprint($path . 'structures.csv', join( "\n", @{ $results->{ structures } }));
}

sub fprint {
    my $self = shift;
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

sub new {
    my $inv = shift;
    my $class = ref $inv || $inv;

    my ($fasta_file, $fasta_id_regex) = @_;

    my $dbh = DBI->connect('dbi:mysql:database=smallrna', 'kebil', 'kebil') or die "Could not connect to DB\n";

    my $self = {
        dbh    => $dbh,
        # structure is we want to get is something like this, which litterally translates to the DB scheme
        # { acc_nr.model_nr => { strand, chr, type, seq, start, stop, struct } }
        genes   => {},
    };

    return bless $self, $class;
}

sub run_parser {
    my $self = shift;
    my $seqs = shift;
    my ($species_id, $source_id) = @_;
    my (@annotations, @structures) = ();

    while (my ($key, $seq) = each %$seqs) {
        my ($acc_nr, $model_nr, $symbols, $comment, $chr, $start, $stop, $strand) = $key =~
        /(.+)\.(\d*) \| Symbols: (.*?) \| (.*) \| (.{3,4}):(\d+)-(\d+) (.+)/;

        push @annotations, join "\t", (
            $self->get_next_id(),
            $acc_nr,
            $model_nr,
            $start,
            $stop,
            $strand =~ /forward/i ? q{+} : q{-},
            $chr,
            'cdna',
            $species_id,
            $seq,
            $comment,
            $source_id
        );

        my $undef = $self->{ dbh }->quote(undef);
        push @structures, join "\t", (
            $undef,
            $self->get_cur_id(),
            $start,
            $stop,
            'N'
        );
    }

    return { annotations => \@annotations, structures => \@structures };
}

{ 
my $last_insert_id = 0;

sub get_next_id {
    my $self = shift;

    if (!$last_insert_id) {
        $last_insert_id = $self->{ dbh }->selectrow_arrayref(q{SELECT MAX(id) FROM `annotations`})->[0];
    }

    return ++$last_insert_id;
}

sub get_cur_id {
    return $last_insert_id;
}
}

sub check_source {
    my $self = shift;
    my ($sid, $sname) = @_;

    if ($sid) {
        my $q_sid   = $self->{ dbh }->quote($sid);
        my $count = $self->{ dbh }->selectcol_arrayref(qq{SELECT count(*) FROM `sources` WHERE id = $q_sid})->[0];

        warn "Sources ID '$sid' is not found in the DB. Make sure you've already added it or foreign key constraints will tair the galaxy part!" if ! $count;
    }
    elsif ($sname) {
        my $q_sname = $self->{ dbh }->quote(qq{%$sname%});
        $sid = $self->{ dbh }->selectcol_arrayref(qq{SELECT id FROM `sources` WHERE name LIKE $q_sname})->[0];

        die "'$sname' is not found in the DB. The program needs a correct name to look up the source ID so we can link the annotation to the right source!" if ! $sid;
    }

    return $sid;
}

sub check_species {
    my $self = shift;
    my ($sid, $sname) = @_;

    if ($sid) {
        my $q_sid   = $self->{ dbh }->quote($sid);
        my $count = $self->{ dbh }->selectcol_arrayref(qq{SELECT count(*) FROM `species` WHERE id = $q_sid})->[0];

        warn "Species ID '$sid' is not found in the DB. Make sure you've already added it or foreign key constraints will tair the galaxy part!" if ! $count;
    }
    elsif ($sname) {
        my $q_sname = $self->{ dbh }->quote(qq{%$sname%});
        $sid = $self->{ dbh }->selectcol_arrayref(qq{SELECT id FROM `species` WHERE full_name LIKE $q_sname})->[0];

        die "'$sname' is not found in the DB. The program needs a correct name to look up the species ID so we can link the annotation to the right species!" if ! $sid;
    }

    return $sid;
}

1;

__END__;

=head1 SYNOPSIS

Usage: perl SRNA/cDNA.pm [options] file.cdna

Optional:
  --species_id|--species_name:
  --sources_id|--sources_name:
