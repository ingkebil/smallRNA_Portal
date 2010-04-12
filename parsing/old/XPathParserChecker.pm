package PLAZA::XML::XPathParserChecker;

use strict;
#use warnings;
use Data::Dumper;
#use Smart::Comments;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Template ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(

    ) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

# List all of your public methods here. One method on each line.
our @EXPORT = qw(
check_seq
check_cds
check_pep
check_pep_ext
check_pep_vitis
check_no_stop
check_seq_codons
check_start_codon
set_id_regex
get_seq
get_all_fasta_id
_translate
_full_complement
_complement
);

our $VERSION = '0.01';

# Preloaded methods go here.

# Comments : prepend internal methods with _
{

    # the key is the filename, the value is the regex to check the '>id' with
    my %id_regex = ();

    # the key is the filename, the value is a hash of the file's contents (as key the '>id' line, as value the other lines
    my %fn = ();

    sub set_id_regex {
        my ($in_ref) = @_;
        my $filename = $in_ref->{ 'filename' };
        my $regex    = $in_ref->{ 'regex' };

        $id_regex{ $filename } = $regex;
    }

    sub check_cds {
        my ($in_ref) = @_;

        my $cds_filename = $in_ref->{ 'cds_filename' };
        my $cds_seq_ref  = $in_ref->{ 'cds_seq_ref'  };
        my $gene_id      = $in_ref->{ 'full_gene_id' };

        if (!defined $fn{ $cds_filename }) {
            &_read_fasta($cds_filename);
        }

        if (${ $cds_seq_ref } eq $fn{ $cds_filename }->{ $gene_id }) {
            return 1;
        }
        elsif (${ &_complement($cds_seq_ref) } eq $fn{ $cds_filename }->{ $gene_id }) {
            return -1;
        }
        else {
            #print $gene_id . ' -> ' . $fn{ $cds_filename }->{ $gene_id } . ' ne ' . ${ $cds_seq_ref } . "\n";
            return 0;
        }
    }

    sub check_seq {
        my ($in_ref) = @_;

        my $cds_filename = $in_ref->{ 'cds_filename' };
        my $cds_seq_ref  = $in_ref->{ 'cds_seq_ref'  };
        my $gene_id      = $in_ref->{ 'full_gene_id' };

        if (!defined $fn{ $cds_filename }) {
            &_read_fasta($cds_filename);
        }

        my $fasta_seq = $fn{ $cds_filename }->{ $gene_id };

        if (${ $cds_seq_ref } eq $fasta_seq) {
            return 1;
        }
        elsif (${ &_full_complement($cds_seq_ref) } eq $fasta_seq) {
            return -1;
        }
        elsif (${ &_complement($cds_seq_ref) } eq $fasta_seq) {
            return -1;
        }
        else {
            #print $gene_id . ' -> ' . $fasta_seq . ' ne ' . ${ $cds_seq_ref } . "\n";
            return 0;
        }
    }

    sub check_pep {
        my ($in_ref) = @_;

        my $pep_filename = $in_ref->{ 'pep_filename' };
        my $cds_seq_ref  = $in_ref->{ 'cds_seq_ref'  };
        my $gene_id      = $in_ref->{ 'full_gene_id' };

        if (!defined $fn{ $pep_filename }) {
            &_read_fasta($pep_filename);
        }

        if (!$fn{ $pep_filename }->{ $gene_id }) {
            return -1;
        }
        elsif (${ &_translate($cds_seq_ref) } eq $fn{ $pep_filename}->{ $gene_id }) {
            return 1;
        }
        else {
            #print $gene_id . ' -> ' . $fn{ $pep_filename}->{ $gene_id } . ' ne ' . ${ &_translate($cds_seq_ref) } . "\n";
            return 0;
        }
    }

    sub check_pep_no_stop {
        my ($in_ref) = @_;

        my $pep_filename = $in_ref->{ 'pep_filename' };
        my $cds_seq_ref  = $in_ref->{ 'cds_seq_ref'  };
        my $gene_id      = $in_ref->{ 'full_gene_id' };

        if (!defined $fn{ $pep_filename }) {
            &_read_fasta($pep_filename);
        }

        my $tr_seq = ${ &_translate_full({ 'sequence' => $cds_seq_ref, 'return_on_stop' => 0 }) };
        my $last_char = substr($tr_seq, -1);
        $tr_seq =~ s/\*/X/g;
        $tr_seq = substr($tr_seq, 0, length($tr_seq) - 1) . $last_char;

        if (!$fn{ $pep_filename }->{ $gene_id }) {
            return -1;
        }
        elsif ($tr_seq eq $fn{ $pep_filename }->{ $gene_id }) {
            return 1;
        }
        else {
            return 0;
        }
    }

    sub check_pep_ext {
        my ($in_ref) = @_;

        my $pep_filename = $in_ref->{ 'pep_filename' };
        my $cds_seq_ref  = $in_ref->{ 'cds_seq_ref'  };
        my $gene_id      = $in_ref->{ 'full_gene_id' };

        if (!defined $fn{ $pep_filename }) {
            &_read_fasta($pep_filename);
        }

        if (!$fn{ $pep_filename }->{ $gene_id }) {
            return -1;
        }
        elsif (${ &_translate($cds_seq_ref) } eq $fn{ $pep_filename }->{ $gene_id }) {
            return 1;
        }
        else {
            my $tr_seq = ${ &_translate_full({ 'sequence' => $cds_seq_ref, 'return_on_stop' => 0 }) };
            my $last_char = substr($tr_seq, -1);
            $tr_seq =~ s/\*/X/g;
            $tr_seq = substr($tr_seq, 0, length($tr_seq) - 1) . $last_char;
            if ($tr_seq eq $fn{ $pep_filename }->{ $gene_id }) {
                return 2;
            }
        }
        return 0;
    }

    sub check_pep_vitis {
        my ($in_ref) = @_;

        my $pep_filename = $in_ref->{ 'pep_filename' };
        my $cds_seq_ref  = $in_ref->{ 'cds_seq_ref'  };
        my $gene_id      = $in_ref->{ 'full_gene_id' };

        if (!defined $fn{ $pep_filename }) {
            &_read_fasta($pep_filename);
        }

        if (!$fn{ $pep_filename }->{ $gene_id }) {
            return -1;
        }
        elsif (${ &_translate($cds_seq_ref) } eq $fn{ $pep_filename }->{ $gene_id }) {
            return 1;
        }
        else {
            my $tr_seq = ${ &_translate_full({ 'sequence' => $cds_seq_ref, 'return_on_stop' => 0 }) };
            my $last_char = substr($tr_seq, -1);
            $tr_seq =~ s/\*/X/g;
            $tr_seq = substr($tr_seq, 0, length($tr_seq) - 1);
            if ($tr_seq eq $fn{ $pep_filename }->{ $gene_id }) {
                return 2;
            }
        }
        return 0;
    }

    sub check_seq_codons {
        my ($seq_ref) = @_;

        # check if the sequence is a multiple of 3
        if (length(${ $seq_ref }) % 3 != 0) {
            return 0;
        }
        return 1;
    }

    sub check_start_codon {
        my ($seq_ref) = @_;

        my $return = 1;
        if (substr(${ $seq_ref },0,3) ne q{ATG}) {
            $return = 0;
            if (substr(${ $seq_ref },0,3) eq q{TAC}) {
                $return = -1;
            }

        }

        return $return;
    }

    sub get_seq {
        my ($in_ref) = @_;

        my $id           = $in_ref->{ 'id' };
        my $seq_filename = $in_ref->{ 'filename' };

        if (!defined $fn{ $seq_filename }) {
            &_read_fasta($seq_filename);
        }

        return $fn{ $seq_filename }->{ $id };
    }

    sub get_all_seq {
        my ($in_ref) = @_;

        my $seq_filename = $in_ref->{ 'filename' };

        if (!defined $fn{ $seq_filename }) {
            &_read_fasta($seq_filename);
        }

        return \$fn{ $seq_filename };
    }

    sub get_all_fasta_id {
        my ($in_ref) = @_;

        my $seq_filename = $in_ref->{ 'filename' };

        if (!defined $fn{ $seq_filename }) {
            &_read_fasta($seq_filename);
        }

        my @keys = keys %{ $fn{ $seq_filename } };
        return \@keys;
    }

#    sub _read_cds_fasta {
#        my ($filename) = @_;
#        &_read_fasta({ 'filename' => $filename, 'hash' => \%cds_of }); 
#    }
#
#    sub _read_seq_fasta {
#        my ($filename, $id_regex) = @_;
#        &_read_fasta({ 'filename' => $filename, 'hash' => \%seq_of }); 
#    }
#
#    sub _read_pep_fasta {
#        my ($filename) = @_;
#        &_read_fasta({ 'filename' => $filename, 'hash' => \%pep_of }); 
#    }

    sub _read_fasta {
        my ($filename) = @_;
        my %value_of = ();

        open(SEQ_FASTA, $filename) or die ("Cannot open $filename");
        print "opening $filename\n";
        my $id_regex = q{};
        if (!defined $id_regex{ $filename }) {
            $id_regex{ $filename } = '>LOC_(([A-Z]{2}[0-9]{1,2}[GMC][0-9]{5}(\.[0-9]{1,2}))|(TRF[0-9]{7})).*';
        }
        $id_regex = $id_regex{ $filename };

        my $gene_id = q{};
        my $seq = q{};
        while(my $line = <SEQ_FASTA>) {
            chomp($line);
            if (substr($line,0,1) eq q{>}) {
                if ($gene_id) {
                    $value_of{ $gene_id } = $seq;
                    $seq = q{};
                }
                #$line = uc($line);
#                ($gene_id = $line) =~ s/>LOC_(([A-Z]{2}[0-9]{1,2}[GMC][0-9]{5}(\.[0-9]{1,2}))|(TRF[0-9]{7})).*/$1/;
                ($gene_id = $line) =~ s/$id_regex/$1/i;
#                ($gene_id = $line) =~ s/>jgi\|Poptr1_1\|([0-9]{6})\|.*/$1/i;
            }
            else {
                $seq .= $line;
            }
        }
        # add the last found gene_id and sequence to the hash
        if ($seq && $gene_id) {
            $value_of{ $gene_id } = $seq;
        }
        
        $fn{ $filename } = \%value_of;
        #print Dumper \%value_of;
    }

    sub _translate_full {
        my ($in_ref) = @_;
        my $seq = ${ $in_ref->{ 'sequence' } };
        my $return_on_stop = $in_ref->{ 'return_on_stop' };
        my $len = length($seq);
        my $output = q{};
        my %protein_of = (
            "TCA"=>"S","TCC"=>"S","TCG"=>"S","TCT"=>"S","TCN"=>"S",     	# Serine
            "TTT"=>"F","TTC"=>"F","TTY"=>"F",                               # Phenylalanine
            "TTA"=>"L","TTG"=>"L","TTR"=>"L",                               # Leucine
            "TAT"=>"Y","TAC"=>"Y","TAY"=>"Y",                               # Tyrosine
            "TAA"=>"*","TAG"=>"*","TAR"=>"*",                               # Stop
            "TGT"=>"C","TGC"=>"C","TGY"=>"C",                               # Cysteine
            "TGA"=>"*",                                                     # Stop
            "TGG"=>"W",                                                     # Tryptophan
            "CTA"=>"L","CTC"=>"L","CTG"=>"L","CTT"=>"L","CTN"=>"L",         # Leucine
            "CCA"=>"P","CCC"=>"P","CCG"=>"P","CCT"=>"P","CCN"=>"P",         # Proline
            "CAT"=>"H","CAC"=>"H","CAY"=>"H",                               # Histidine
            "CAA"=>"Q","CAG"=>"Q","CAR"=>"Q",                               # Glutamine
            "CGA"=>"R","CGC"=>"R","CGG"=>"R","CGT"=>"R","CGN"=>"R",         # Arginine
            "ATA"=>"I","ATC"=>"I","ATT"=>"I","ATH"=>"I",                    # Isoleucine
            "ATG"=>"M",                                                     # Methionine
            "ACA"=>"T","ACC"=>"T","ACG"=>"T","ACT"=>"T","ACN"=>"T",         # Threonine
            "AAT"=>"N","AAC"=>"N","AAY"=>"N",                               # Asparagine
            "AAA"=>"K","AAG"=>"K","AAR"=>"K",                               # Lysine
            "AGT"=>"S","AGC"=>"S","AGY"=>"S",                               # Serine
            "AGA"=>"R","AGG"=>"R","AGR"=>"R",                               # Arginine
            "GTA"=>"V","GTC"=>"V","GTG"=>"V","GTT"=>"V","GTN"=>"V",         # Valine
            "GCA"=>"A","GCC"=>"A","GCG"=>"A","GCT"=>"A","GCN"=>"A",         # Alanine
            "GAT"=>"D","GAC"=>"D","GAY"=>"D",                               # Aspartic Acid
            "GAA"=>"E","GAG"=>"E","GAR"=>"E",                               # Glutamic Acid
            "GGA"=>"G","GGC"=>"G","GGG"=>"G","GGT"=>"G","GGN"=>"G",         # Glycine
        );

        for (my $i=0; $i < ($len-2); $i+=3) {
            my $codon = substr($seq, $i, 3);
            if (exists $protein_of{ $codon }) { 
                my $protein = $protein_of{ $codon };
                $output .= $protein;
                last if ($protein eq "*" && $return_on_stop);
            }
            else {
                $output .= 'X'; # unknown codon
                #	printf STDERR " no translation for: " . substr($seq,$i,3) . "\n"; 
            }                        
        }

        return \$output;
    }

    sub _translate {
        return &_translate_full({ 'sequence' => $_[0], 'return_on_stop' => 1 });
    }


    sub _complement {
        my ($seq_ref) = @_;
        my $seq = ${ $seq_ref };
        $seq =~ tr/('A','T','G','C')/('T','A','C','G')/;
        return \$seq;
    }


    sub _full_complement {
        my ($seq_ref) = @_; 
        my @split_seq = split(//,${ $seq_ref }); 
        my %complement = ( 
            "A" => "T", 
            "T" => "A", 
            "C" => "G", 
            "G" => "C", 
            "M" => "K", 
            "R" => "Y", 
            "W" => "W", 
            "S" => "S", 
            "Y" => "R", 
            "K" => "M", 
            "V" => "B", 
            "H" => "D", 
            "D" => "H", 
            "B" => "V", 
            "N" => "N", 
            "X" => "X", 
        );
        my $comp_seq = q{};

        for (my $i=0; $i <= $#split_seq ; $i++) { 
            $comp_seq .= $complement{ $split_seq[$i] };
        }
        return \$comp_seq;
    }   

}

1;


=cut

=head 

TODO: refractor this code out of the XML part

