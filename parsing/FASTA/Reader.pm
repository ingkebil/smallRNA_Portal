package FASTA::Reader;

use strict;
use warnings;
use Data::Dumper;
#use Smart::Comments;

my $def_id_regex = '>(.*)';

sub new {
    my $inv = shift;
    my $filename = $_[0]->{ filename } || '';
    my $lines    = $_[0]->{ lines    } || '';
    my $id_regex = $_[0]->{ id_regex } || $def_id_regex;
    my $class = ref $inv || $inv;


    my $self = {
        regexes => { $filename => $id_regex }, 
        filenames => {}, # holds the filename => { id => seq } hash
        lines => $lines,
    };

    return bless $self, $class;
}

## Instead of reading the whole FASTA file at once, just read it an entry at the time
sub get_next_seq {
    my $self = shift;
    my $filename = shift;
    my $id_regex = shift || $def_id_regex;

    my ($line_nr, $skip_nr) = $self->{ line_nr } || 0;

    my $id    = q{};
    my $fasta = q{};
    open F, '<', $filename;
    for ($skip_nr--) { my $line = <F>; } # skip the lines we already did
    while (my $line = <F>) {
        $line_nr++;
        chomp($line);
        if (substr($line,0,1) eq q{>}) {
            last if $id; # if we reach the next >header, exit
            ($id = $line) =~ s/$id_regex/$1/i;
        }
        else {
            $fasta .= $line;
        }
    }
    $self->{ line_nr } = $line_nr;
    close F;

    return { id => $id, fasta => $fasta };
}

sub add_regex {
    my ($self, $filename, $id_regex) = @_;
    $id_regex ||= '>(.*)';

    $self->{ regexes }->{ $filename } = $id_regex;
}

sub get_seq {
    my ($self, $seq_filename, $id) = @_;

    if (!defined $self->{ filenames }->{ $seq_filename }) {
        $self->_fasta($seq_filename);
    }

    if (!defined $self->{ filenames }->{ $seq_filename }->{ $id }) {
        warn "$id was not found in $seq_filename\n";
        return 0;
    }
    
    return $self->{ filenames }->{ $seq_filename }->{ $id };
}

sub get_seq_ref {
    my ($self, $seq_filename, $id) = @_;

    #my $s = $self->get_seq($seq_filename, $id);
    if (!defined $self->{ filenames }->{ $seq_filename }) {
        $self->_fasta($seq_filename);
    }

    if (!defined $self->{ filenames }->{ $seq_filename }->{ $id }) {
        warn "$id was not found in $seq_filename\n";
        return 0;
    }
    
    return \$self->{ filenames }->{ $seq_filename }->{ $id };
}

sub get_seq_arrayref {
    my ($self, $seq_filename, $id) = @_;

    if (! defined $self->{ filenames_arrayref }->{ $seq_filename }->{ $id }) {
        my @s = split //, $self->get_seq($seq_filename, $id);
        $self->{ filenames_arrayref }->{ $seq_filename }->{ $id } = \@s;
    }
    
    return $self->{ filenames_arrayref }->{ $seq_filename }->{ $id };
}

sub get_all_seq {
    my ($self, $seq_filename) = @_;

    if (!defined $self->{ filenames }->{ $seq_filename }) {
        $self->_fasta($seq_filename);
    }

    return $self->{ filenames }->{ $seq_filename };
}

sub get_all_fasta_id {
    my ($self, $seq_filename) = @_;

    if (!defined $self->{ filenames }->{ $seq_filename }) {
        $self->_fasta($seq_filename);
    }

    my @keys = keys %{ $self->{ filenames }->{ $seq_filename } };
    return \@keys;
}

sub _fasta {
    my ($self, $filename) = @_;
    my $lines = $self->{ lines };

    if (ref $lines eq 'ARRAY') {
        return $self->_parse_fasta($filename);
    }

    return $self->_read_fasta($filename);
}

sub _read_fasta {
    my ($self, $filename) = @_;
    open(SEQ_FASTA, $filename) or die ("Cannot open $filename!\n");
    my @lines = <SEQ_FASTA>;
    $self->{ lines } = \@lines;

    return $self->_parse_fasta($filename);
}

sub _parse_fasta {
    my ($self, $filename) = @_;
    my %value_of = ();

    my $id_regex = $self->{ regexes }->{ $filename } || $def_id_regex;
    my $gene_id = q{};
    my $seq = q{};
    foreach my $line (@{ $self->{ lines } }) { ### Parsing FASTA '$filename' [%]
        chomp($line);
        if (substr($line,0,1) eq q{>}) {
            if ($gene_id) {
                $value_of{ $gene_id } = $seq;
                $seq = q{};
            }
            #$line = uc($line);
            ($gene_id = $line) =~ s/$id_regex/$1/i;
        }
        else {
            $seq .= $line;
        }
    }
    # add the last found gene_id and sequence to the hash
    if ($seq && $gene_id) {
        $value_of{ $gene_id } = $seq;
    }

    undef $self->{ lines }; # make it reusable after initing it with @lines

    $self->{ filenames }->{ $filename } = \%value_of;

    return \%value_of;
}

1;

__END__

head1 NAME

head1 SYNOPSIS

head1 AUTHOR

Kenny Billiau
