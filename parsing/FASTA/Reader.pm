package FASTA::Reader;

use strict;
use warnings;
use Data::Dumper;
use Smart::Comments;

sub new {
    my $inv = shift;
    my $filename = $_[0]->{ filename } || undef;
    my $lines    = $_[0]->{ lines    } || '';
    my $id_regex = $_[0]->{ id_regex } || '>(.*)';
    my $class = ref $inv || $inv;


    my $self = {
        regexes => { $filename => $id_regex }, 
        filenames => {}, # holds the filename => { id => seq } hash
        lines => $lines,
    };

    return bless $self, $class;
}

sub add_regex {
    my ($self, $filename, $id_regex) = @_;
    $id_regex ||= '>(.*)';

    $self->{ regexes }->{ $filename } = $id_regex;
}

sub get_seq {
    my ($self, $seq_filename, $id) = @_;

    if (!defined $self->{ filenames }->{ $seq_filename }) {
        $self->{ filenames }->{ $seq_filename } = $self->_fasta($seq_filename);
    }

    if (!defined $self->{ filenames }->{ $seq_filename }->{ $id }) {
        warn "$id was not found in $seq_filename\n";
        return 0;
    }
    
    return $self->{ filenames }->{ $seq_filename }->{ $id };
}

sub get_all_seq {
    my ($self, $seq_filename) = @_;

    if (!defined $self->{ filenames }->{ $seq_filename }) {
        $self->{ filenames }->{ $seq_filename } = $self->_fasta($seq_filename);
    }

    return $self->{ filenames }->{ $seq_filename };
}

sub get_all_fasta_id {
    my ($self, $seq_filename) = @_;

    if (!defined $self->{ filenames }->{ $seq_filename }) {
        $self->{ filenames }->{ $seq_filename } = $self->_fasta($seq_filename);
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

    my $id_regex = $self->{ regexes }->{ $filename };
    my $gene_id = q{};
    my $seq = q{};
    foreach my $line (@{ $self->{ lines } }) { ### Parsing FASTA [%]
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

    return \%value_of;
    #print Dumper \%value_of;
}

1;

__END__

head1 NAME

head1 SYNOPSIS

head1 AUTHOR

Kenny Billiau
