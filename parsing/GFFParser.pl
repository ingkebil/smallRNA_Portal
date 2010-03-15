#!/usr/bin/perl

use lib "/home/kebil/modules";
use strict;
use warnings;
use Data::Dumper;
use PLAZA::XML::XPathParserChecker;
use Smart::Comments;
use Getopt::Long;
use Pod::Usage;

our $VERSION = '0.1';

Getopt::Long::Configure("auto_version");

######################
# Set up the options #
######################

# Define option requirements
my $gff_filename = q{};
my $csv_filename = q{};
my $tr_filename = q{};
my $pep_filename = q{};
my $genome_filename = q{};

# get the options
my $options_ok = GetOptions(
    'input|i=s' => \$gff_filename,
    'output|o=s' => \$csv_filename,
    'tr-filename|t=s' => \$tr_filename,
    'pep-filename|p=s' => \$pep_filename,
    'genome-filename|g=s' => \$genome_filename,
    
    # Default options
    'usage|u' => sub { pod2usage({-verbose => 0}); }, # IMPORTANT: specify --usage output in the perldoc "=head1 USAGE" section below!!!
    'help|h' => sub { pod2usage({-verbose => 1}); },  # IMPORTANT: specify --help output in the perldoc "=head1 USAGE", "=head1 OPTIONS" & "=head1 ARGUMENTS" section below!!!
    # --version is implemented automatically based on the $VERSION value
);

# Show usage if command-line arguments are not ok
if (! $options_ok ) {
    pod2usage({-verbose => 0});
}

# Call this subroutine if you'r not happy with user input in your code
sub usage {
    pod2usage({-verbose => 0});
}

##########################
# The program code below #
##########################

open(GFFFILE,'<' . $gff_filename);
open(CSVFILE,'>' . $csv_filename);
my $csv_fh = *CSVFILE;

# some default values
#my $tr_filename = '/home/kebil/plazadata/ptr/transcripts.Poptr1_1.JamboreeModels.fasta';
#my $pep_filename   = '/home/kebil/plazadata/ptr/proteins.Poptr1_1.JamboreeModels.fasta';
#my $genome_filename = '/home/kebil/plazadata/ptr/poplar.unmasked.fasta';
my $field_encap = q{"};
my $field_delim = ", ";
my $species = 'ptr'; # the species PLAZA name
my $source_key = '3'; # the source key in the PLAZA db
my $transcript_nr = '.1'; # the default transcript nr
my $gene_type = 'coding'; # the default gene type

my %exons_of = (); # where to store the exons of each gene in

my $previous_chr = q{};
my $chr;
my $chr_nr;

# first step, parse the gff fiel into something we can work with
LINE:
while (my $line = <GFFFILE>) {
    my %attr_value_of = ();
    my $has_id = 0;
    
    # first, check if we find the word transcriptId or proteinId
    my @split_line = split /\t/, $line;         # split line in columns
    
    my @split_attr = split /;/, $split_line[8]; # split last column in attributes
    foreach my $attr (@split_attr) {
        $attr =~ s/\s?(.*)\s?/$1/;
        my ($id_name, $id) = split /\s+/, $attr;
        $id =~ s/"//g; # all ids, except numeric ids,  are surrounded by "
        $attr_value_of{ $id_name } = $id; 
        if ($id_name =~ m/(proteinId|transcriptId)/) {
            $has_id = 1;
        }
    }
    next LINE if !$has_id; # we only need the lines with an id (no start and stop codons)
#    next LINE if $attr_value_of{ 'name' } ne 'grail3.0034007101'; # DEBUG, check just one gene

    #group the values on name
    my $id = $attr_value_of{ 'name' };

    # some caching of chromosome numbers .. only convert roman to arabic if the chr is different
    if ($previous_chr ne $split_line[0]) {
        $chr = $split_line[0];
        $chr_nr = substr($split_line[0],0,9) eq 'scaffold_' ? '0' 
                                                            : &_roman2number(substr($split_line[0],3));
        $chr_nr = $chr_nr <= 9 ? "0$chr_nr" : "$chr_nr";
        $previous_chr = $split_line[0];
    }
    
    next if $chr !~ m/scaffold/;
    # create a hash of all the exon values ..
    my $exon_ref = {
        'prot_id' => $attr_value_of{ 'proteinId' },
        'tr_id'   => $attr_value_of{ 'transcriptId' },
        'start'   => $split_line[3],
        'stop'    => $split_line[4],
        'strand'  => $split_line[6],
        'cds'     => $split_line[2] =~ m/cds/i ? 1 : 0,
        'desc'    => $attr_value_of{ 'name' },
        'chr'     => $chr,
        'chr_nr'  => $chr_nr,
        'phase'   => $split_line[7],
    };

    # add them to the general hash ..
    if (!defined $exons_of{ $id }) {
        $exons_of{ $id } = [];
    }
    push @{ $exons_of{ $id } }, $exon_ref;
}

# count all the genes and display the number ..
my $count = 0;
while (my ($k, $v) = each(%exons_of)) {
    $count++;
}
print "Parsing $count genes...\n";

# ok, now we have hash, what can we do with it?

# set the regex to recognize the id in the id-line of a fasta file
&set_id_regex({ 'regex' => '>jgi\|Poptr1_1\|[0-9]{6}\|(.*)', 'filename' => $tr_filename });
&set_id_regex({ 'regex' => '>jgi\|Poptr1_1\|[0-9]{6}\|(.*)', 'filename' => $pep_filename});
&set_id_regex({ 'regex' => '>([a-zA-Z0-9_]*)( .*)?', 'filename' => $genome_filename});

my $gene_id = 10; # this is our gene id counter .. incrementing with 10
my $faulty_len = 1;
my $faulty_cds_len = 0;
my $pep_eq = 0;
my $pep_ne = 0;
my $pep_none = 0;
my $pep_error = 0;
my $no_seq = 0;
my $gen_seq_ne = 0;

my %strand_cnt = ();
$strand_cnt{ '-' } = 0;
$strand_cnt{ '+' } = 0;

my %pep_len_err = ();
$pep_len_err{  1 } = 0;
$pep_len_err{ -1 } = 0;
$pep_len_err{  0 } = 0;

my %pep_tr = ();
$pep_tr{ 1 } = 0;
$pep_tr{-1 } = 0;
$pep_tr{ 0 } = 0;

# initialize the starting gene_ids for each chromosome
my %chroms = ();
my %last_gene_id_of = ();
my @chrom_names = @{ &get_all_fasta_id({ 'filename' => $genome_filename }) };
foreach my $chrom_name (@chrom_names) {
    $chroms{ $chrom_name } = &get_seq({ 'id' => $chrom_name, 'filename' => $genome_filename});
    if ($chrom_name =~ m/^scaffold/) {
        $last_gene_id_of{ 'scaffold' } = 10;
    }
    else {
        $last_gene_id_of{ $chrom_name } = 10;
    }
}



my %fasta_seq_eq = ();
$fasta_seq_eq{ 0 } = 0;
$fasta_seq_eq{-1 } = 0;
$fasta_seq_eq{ 1 } = 0;

my %fasta_cds_seq_eq = ();
$fasta_cds_seq_eq{ 0 } = 0;
$fasta_cds_seq_eq{-1 } = 0;
$fasta_cds_seq_eq{ 1 } = 0;

#my $prev_exon = 0; # will be used to check if we jump back in coordinates (which means our sorting is wrong!)

my %prev_start = ();

# loop over all genes (and sort then according to a random exon start coordinate) 
foreach my $exons_ref (sort _by_coord values %exons_of) { ### processed %
    my $id        = q{};
    my $prot_id   = q{};
    my $tr_id     = q{};
    my $coords    = q{};
    my $coords_tr = q{};
    my $strand    = q{};
    my $chr       = q{};
    my $chr_nr    = q{};
    my $desc      = q{};
    my %coords_of    = ();
    my %coords_tr_of = ();
    my @comments     = ();

    # first, glue together the transcript coordinates
    foreach my $exon_ref (sort _by_start_coord @{ $exons_ref }) { # loop through all exons of a TU
        if ($exon_ref->{ 'cds' }) {
            $coords_of{ $exon_ref->{ 'start' } } = $exon_ref->{ 'stop' };
        }
        else {
            $coords_tr_of{ $exon_ref->{ 'start' } } = $exon_ref->{ 'stop' };
        }
        $strand  = $strand  ? $strand  : $exon_ref->{ 'strand'  }; # easy caching: assigning a value is quicker then a hash-lookup
        $chr     = $chr     ? $chr     : $exon_ref->{ 'chr'     };
        $chr_nr  = $chr_nr  ? $chr_nr  : $exon_ref->{ 'chr_nr'  };
        $prot_id = $prot_id ? $prot_id : $exon_ref->{ 'prot_id' };
        $tr_id   = $tr_id   ? $tr_id   : $exon_ref->{ 'tr_id'   };
        $desc    = $desc    ? $desc    : $exon_ref->{ 'desc'    };
        $id = $desc;
    }
    
    if (defined $prev_start{ $chr } && $prev_start{ $chr }->[0]->{ 'start' } > $exons_ref->[0]->{ 'start' }) {
        print Dumper $exons_ref;
        print Dumper $prev_start{ $chr };
        die "Apparently, I'm not sorting correctly!";
    }
    else {
        $prev_start{ $chr } = $exons_ref;
    } 

    # join and add join( )
    foreach my $start (sort { $a <=> $b } keys %coords_of) {
        $coords .= ',' . $start . '..' . $coords_of{ $start };
    }
    $coords = 'join(' . substr($coords,1) . ')';
    foreach my $start (sort { $a <=> $b } keys %coords_tr_of) {
        $coords_tr .= ',' . $start . '..' . $coords_tr_of{ $start };
    }
    $coords_tr = 'join(' . substr($coords_tr,1) . ')';

    # add the complement if on minus strand
    if ($strand eq q{-}) {
        $coords    = 'complement(' . $coords . ')';
        $coords_tr = 'complement(' . $coords_tr . ')';
        $strand_cnt{ '-' } += 1; # DEBUG
    }
    else {
        $strand_cnt{ '+' } += 1; #DEBUG
    }

    # get sequence out of the fasta file
    my $useq       = uc(&_glue_seq({ 'coords' => \$coords_tr, 'gene_id' => $id, 'genome' => \$chroms{ $chr } }));
    my $ucds_seq   = uc(&_glue_seq({ 'coords' => \$coords   , 'gene_id' => $id, 'genome' => \$chroms{ $chr } }));
    my $seq = ${ &_full_complement(\$useq) };
    my $cds_seq = ${ &_full_complement(\$ucds_seq) };
    my $fasta_seq = uc(&get_seq({'id' => $id, 'filename' => $tr_filename }));
    my $offset = &_get_offset({ 'cds_coords' => \%coords_of, 'tr_coords' => \%coords_tr_of });
    my $fasta_cds_seq = &_get_cds({ 'seq_ref' => \$fasta_seq, 'coords' => \%coords_of, 'start' => $offset });

    if (!$seq) {
        $seq = q{};
        $no_seq++;
    }
    $fasta_seq_eq{ $seq cmp $fasta_seq } += 1; # DEBUG
    $fasta_cds_seq_eq { $cds_seq cmp $fasta_cds_seq } += 1; #DEBUG

    # get the uttermost coordinates
    my $start_stop_ref    = &_get_start_stop(\%coords_of);
    my $start_stop_tr_ref = &_get_start_stop(\%coords_tr_of);
    my $start_tr = $start_stop_tr_ref->{ 'start' };
    my $stop_tr  = $start_stop_tr_ref->{ 'stop'  };
    my $start    = $start_stop_ref ? $start_stop_ref->{ 'start' } : $start_tr;
    my $stop     = $start_stop_ref ? $start_stop_ref->{ 'stop'  } : $start_tr;

    # check some sequence specific stuff (length, start codon, protein comparison,  ..)
    if ($seq) { 
        my $fault_in_len = 0; 
        my $calced_len = &_calc_seq_len(\%coords_of);
        if (length($seq) != $calced_len) {
            $faulty_cds_len++; # DEBUG
            $fault_in_len = 1;
        } 
        $calced_len = &_calc_seq_len(\%coords_tr_of);
        if (length($seq) != $calced_len) {
            $faulty_len++; # DEBUG
            $fault_in_len = 2;
        }
        else {
            $fault_in_len = 0;
        }

        if ($fault_in_len) {
            print "$prot_id: length fault $fault_in_len\n";
        }

        # add some comments ..
        push @comments, "name=$id";
        push @comments, "pid=$prot_id";
        push @comments, "tid=$tr_id";

        # if we have a sequence .. do something with it
        if (!$cds_seq) {
            $pep_error++; # DEBUG
        }
        else {
            my $check_pep = &check_pep_ext({ 'pep_filename' => $pep_filename, 'cds_seq_ref' => \$cds_seq, 'full_gene_id' => $id });

            if ($check_pep > 0) {
                $pep_eq++; # DEBUG
                push @comments, 'prot=eq';
                push @comments, 'compl=1';
                if ($check_pep == 2) {
                    push @comments, 'stops=1';
                }
            }
            elsif ($check_pep == 0) {
                my $print = 0;
                if ($cds_seq ne $fasta_cds_seq) {
                    $seq = ${ &_full_complement(\$seq) };
                    $cds_seq = ${ &_full_complement(\$cds_seq) };
                    $check_pep = &check_pep_ext({ 'pep_filename' => $pep_filename, 'cds_seq_ref' => \$cds_seq, 'full_gene_id' => $id });
                    if ($check_pep == 0) {
                        $pep_ne++; # DEBUG
                        $print = 1;
                        push @comments, 'prot=ne'
                    }
                    elsif ($check_pep > 0){
                        $pep_eq++; # DEBUG
                        push @comments, 'prot=eq';
                        if ($check_pep == 2) {
                            push @comments, 'stops=1';
                        }
                    }
                    elsif ($check_pep == -1) {
                        $pep_none++; # DEBUG
                        push @comments, 'prot=none';
                    }
                    else {
                        $pep_error++; #DEBUG
                    }
                }
                else {
                    $pep_ne++; # DEBUG 
                    $print = 1;
                    push @comments, 'prot=ne';
                }
                
#                # print the sequences into a fasta format if they did not pass the quality checks
#                if ($print) {
#                    print ">$id|transcriptId:$tr_id|proteinId:$prot_id";
#                    if ($cds_seq ne $fasta_cds_seq) {
#                         print " ***** ";
#                    }
#                    print "\n$cds_seq\n"; 
#                }
                
            }
            elsif ($check_pep == -1) {
                $pep_none++; # DEBUG
            }
        }
    }

    # determine the chromosome whereon the gene resides (so that we can determine the internal gene_id and incrementor)
    my $gene_id_chr = q{};
    my $gene_id_inc = 10;
    if ($chr =~ m/scaffold/ ) {
        $gene_id_chr = 'scaffold';
        $gene_id_inc = 5;
    }
    else {
        $gene_id_chr = $chr;
    }

    # print it ..
    &_print_update_format({
        'gene_id'       => 'PT' . $chr_nr . 'G' . &_add_leading_zeros($last_gene_id_of{ $gene_id_chr }),
        'species'       => $species,
        'transcript_nr' => $transcript_nr,
        'cds_coords'    => $coords,
        'start'         => $start,
        'stop'          => $stop,
        'tr_coords'     => $coords_tr,
        'seq'           => $cds_seq,
        'strand'        => $strand,
        'chr'           => $chr,
        'gene_type'     => $gene_type,
        'go_codes'      => 'NULL',
        'desc'          => $desc,
        'comment'       => join(q{;}, @comments),
        'source_key'    => $source_key,
    });
    
    # we're done for this one
    undef $exons_of{ $id };
    $last_gene_id_of{ $gene_id_chr } += $gene_id_inc;
}

# DEBUG
print "max gene ids           : " . Dumper \%last_gene_id_of;
print "No sequence            : $no_seq\n";
print "Faulty cds lenght count: $faulty_cds_len\n";
print "Faulty lenght count    : $faulty_len\n";
print "Peptides eq            : $pep_eq\n";
print "Peptides ne            : $pep_ne\n";
print "Peptides none          : $pep_none\n";
print "Peptides CDS not found : $pep_error\n";
print "Genome seq ne          : $gen_seq_ne\n";
print "Lenght err             : " . Dumper \%pep_len_err;
print "Translation err        : " . Dumper \%pep_tr;
print "Strand count           : " . Dumper \%strand_cnt; 
print "Fasta seq eq           : " . Dumper \%fasta_seq_eq;
print "Fasta cds seq eq       : " . Dumper \%fasta_cds_seq_eq;

sub _print_plaza_format() {
    # "gene_id";"species";"transcript";"coord";"start";"stop";"coord_transcript";"seq";"strand";"chr";"type";"go_code";"desc";"source_key"
    # mysqlimport -C -h psbsql01 --local -v --fields-enclosed-by=\" --fields-terminated-by=\; --lines-terminated-by=\\n -p db_kebil_plaza annotation.csv

    my ($in_ref) = @_;

    my $gene_id = $in_ref->{ 'gene_id' };
    my $desc    = $in_ref->{ 'desc' };
    my $comment = $in_ref->{ 'comment' };

    # print it ..
    print $csv_fh $field_encap, $gene_id,                                     $field_encap, $field_delim; # gene_id
    print $csv_fh $field_encap, $in_ref->{ 'species' },                       $field_encap, $field_delim; # species
    print $csv_fh $field_encap, $gene_id, $in_ref->{ 'transcript_nr' },       $field_encap, $field_delim; # transcript
    print $csv_fh $field_encap, $in_ref->{ 'cds_coords' },                    $field_encap, $field_delim; # coord
    print $csv_fh $field_encap, $in_ref->{ 'start' },                         $field_encap, $field_delim; # start
    print $csv_fh $field_encap, $in_ref->{ 'stop' },                          $field_encap, $field_delim; # stop
    print $csv_fh $field_encap, $in_ref->{ 'tr_coords' },                     $field_encap, $field_delim; # coord_transcript
    print $csv_fh $field_encap, $in_ref->{ 'seq' },                           $field_encap, $field_delim; # seq
    print $csv_fh $field_encap, $in_ref->{ 'strand' },                        $field_encap, $field_delim; # strand
    print $csv_fh $field_encap, $in_ref->{ 'chr' },                           $field_encap, $field_delim; # chr
    print $csv_fh $field_encap, $in_ref->{ 'gene_type' },                     $field_encap, $field_delim; # type
    print $csv_fh $field_encap, $in_ref->{ 'go_codes' },                      $field_encap, $field_delim; # go_code
    print $csv_fh $field_encap, ${ &_escape_delim(\$desc) },                  $field_encap, $field_delim; # desc
    print $csv_fh $field_encap, ${ &_escape_delim(\$comment) },               $field_encap, $field_delim; # comment
    print $csv_fh $field_encap, $in_ref->{ 'source_key' },                    $field_encap, $field_delim; # source_key
    print $csv_fh "\n";
}

sub _print_update_format() {
    # "gene_id";"species";"transcript";"coord";"start";"stop";"coord_transcript";"seq";"strand";"chr";"type";"go_code";"desc";"source_key"

    my ($in_ref) = @_;

    my $gene_id = $in_ref->{ 'gene_id' };
    my $desc    = $in_ref->{ 'desc' };
    my $comment = $in_ref->{ 'comment' };

    # print it ..
    print $csv_fh 'UPDATE `annotation` SET ';
    print $csv_fh '`gene_id` = ' . $field_encap, $gene_id,                                 $field_encap, $field_delim; # gene_id
    print $csv_fh '`species` = ' . $field_encap, $in_ref->{ 'species' },                    $field_encap, $field_delim; # species
    print $csv_fh '`transcript` = ' . $field_encap, $gene_id, $in_ref->{ 'transcript_nr' }, $field_encap, $field_delim; # transcript
    print $csv_fh '`coord_cds` = ' . $field_encap, $in_ref->{ 'cds_coords' },              $field_encap, $field_delim; # coord
    print $csv_fh '`start` = ' . $field_encap, $in_ref->{ 'start' },                        $field_encap, $field_delim; # start
    print $csv_fh '`stop` = ' . $field_encap, $in_ref->{ 'stop' },                          $field_encap, $field_delim; # stop
    print $csv_fh '`coord_transcript` = ' . $field_encap, $in_ref->{ 'tr_coords' },         $field_encap, $field_delim; # coord_transcript
    print $csv_fh '`seq` = ' . $field_encap, $in_ref->{ 'seq' },                            $field_encap, $field_delim; # seq
    print $csv_fh '`strand` = ' . $field_encap, $in_ref->{ 'strand' },                      $field_encap, $field_delim; # strand
    print $csv_fh '`chr` = ' . $field_encap, $in_ref->{ 'chr' },                         $field_encap, $field_delim; # chr
    print $csv_fh '`type` = ' . $field_encap, $in_ref->{ 'gene_type' },                     $field_encap, $field_delim; # type
    print $csv_fh '`go_code` = ' . $field_encap, $in_ref->{ 'go_codes' },                   $field_encap, $field_delim; # go_code
    print $csv_fh '`desc` = ' . $field_encap, ${ &_escape_delim(\$desc) },                  $field_encap, $field_delim; # desc
    print $csv_fh '`comment` = ' . $field_encap, ${ &_escape_delim(\$comment) },            $field_encap, $field_delim; # comment
    print $csv_fh '`source_key` = ' . $field_encap, $in_ref->{ 'source_key' },              $field_encap; # source_key
    print $csv_fh " WHERE `gene_id` = '$gene_id';\n";
}

sub _glue_seq() {
    my ($in_ref) = @_;

    my $gene_coords = ${ $in_ref->{ 'coords' } };
    my $gene_id     = $in_ref->{ 'gene_id' };
    my $genome_ref  = $in_ref->{ 'genome' };

    if ($genome_ref) {

        my @coords = split(q{,},$gene_coords);
        my $seq_len = 0; # DEBUG

        # remove join( or complement(join( and ) or ))
        $coords[0] = substr($coords[0], rindex( $coords[0],'(' ) + 1);
        $coords[$#coords] =~ s/\)+//;

        my $seq = q{};
        foreach my $coord (@coords) {
            my ($start,$stop) = split /\.\./, $coord;
            #### check: $start =~ /^-?\d/ && $stop =~ /^-?\d/
            my $diff = int($stop) - int($start);
            $seq .= substr(${ $genome_ref }, $start - 1, $diff + 1);
            $seq_len += abs($stop - $start) + 1;
        }

        $seq =~ s/\s+//g;

        #### check: length $seq == $seq_len && $gene_id

        if (index($gene_coords,'complement(') == 0) {
            $seq = reverse $seq;
        }
        return $seq;

    }
    return 0;
}

sub _get_start_stop {
    my ($coords_ref) = @_;
    my $min = 100000000;
    my $max = -1;
    
    foreach my $start (keys %{ $coords_ref }) {
        my @start_stop = ($start, $coords_ref->{ $start });
        foreach my $coord (@start_stop) {
            if ($coord > $max) {
                $max = $coord;
            }
            if ($coord < $min) {
                $min = $coord;
            }
        }
    }

    if ($min == 100000000 || $max == -1) {
        return 0;
    }
    else {
        return { 'start' => $min, 'stop' => $max };
    }
}

sub _get_offset {
    my ($in_ref) = @_;
    my $cds_coords_ref = $in_ref->{ 'cds_coords' };
    my $tr_coords_ref  = $in_ref->{ 'tr_coords'  };

    my $offset = 0;
    my ($cds_start) = sort { $a <=> $b } keys %{ $cds_coords_ref };
    my @sorted_tr_starts  = sort { $a <=> $b } keys %{ $tr_coords_ref  };
    my $i = 0;

    my $tr_start = $sorted_tr_starts[$i];
    my $tr_stop = $tr_coords_ref->{ $tr_start };
    my $start_coord = $tr_start;
    my $prev_tr_stop = $tr_start - 1;
    
    COORDS:
    while ($tr_stop < $cds_start) {
        $offset += $tr_start - $prev_tr_stop - 1;

        $prev_tr_stop = $tr_stop;
        $tr_start = $sorted_tr_starts[++$i];
        $tr_stop  = $tr_coords_ref->{ $tr_start };
    }
    $offset += $tr_start - $prev_tr_stop - 1;

#    print 'offset:' . ($start_coord - $offset) . "\n";
    return $start_coord + $offset;
}

sub _get_cds {
    my ($in_ref) = @_;
    my $seq        = ${ $in_ref->{ 'seq_ref' } };
    my $coords_ref = $in_ref->{ 'coords' };
    my $base       = $in_ref->{ 'start'  };

    my $previous_len = 0;
    my $cds_seq = q{};
    CDS:
    foreach my $start (sort { $a <=> $b } keys %{ $coords_ref }) {
        my $stop = $coords_ref->{ $start };
        if (!$previous_len) {
            $previous_len = $start - $base;
        }
        if ($previous_len + ($stop - $start + 1) > length($seq) + 1) {
#            last CDS;
            return 0;
        }
        $cds_seq .= substr $seq, $previous_len, ($stop - $start + 1);
        $previous_len += (abs($stop - $start) + 1);
    }
    return $cds_seq;
}

sub _by_coord {
    my $chr_sort_res = 0;
    if ($a->[0]->{ 'chr' } =~ m/scaffold/ && $b->[0]->{ 'chr' } =~ m/scaffold/) {
        $chr_sort_res = substr($a->[0]->{ 'chr' },9) <=> substr($b->[0]->{ 'chr' },9);
    }

    if ($chr_sort_res == 0) {
        return $a->[0]->{ 'start' } <=> $b->[0]->{ 'start' };
    }
    else {
        return $chr_sort_res;
    }
}

sub _by_start_coord {
    return $a->{ 'start' } <=> $b->{ 'start' };
}

sub _add_leading_zeros {
    my ($nr) = @_;
    while (length($nr) < 5) {
        $nr = '0' . $nr;
    }
    return $nr;
}

sub _calc_seq_len {
    my ($coords_ref) = @_;

    my $total_len = 0;
    foreach my $start (keys %{ $coords_ref }) {
        my $stop = $coords_ref->{ $start };
        $total_len += (abs($start - $stop) + 1);
    }

    return $total_len;
}

sub _escape_delim() {
    my ($string) = @_;
    $string =~ s/"/\\"/;
    return $string;
}

sub _roman2number {
    my ($roman) = @_;
    my $total = 0;
    NUMBER:
    for($roman) {
        m/^I(.*)/ && do {
            if ($1 =~ m/^[XV]/) {
                $total -= 1;
            }
            else {
                $total++;
            }
            $_ = substr($_,1);
            redo NUMBER;
        };
        m/^V/ && do {
            $total += 5;
            $_ = substr($_,1);
            redo NUMBER;
        };
        m/^X/ && do {
            $total += 10;
            $_ = substr($_,1);
            redo NUMBER;
        };
        m/^$/ && do {
            last NUMBER;
        };
    }
    return $total;
}

__END__

=head1 NAME

GFFParser.pl - Parses a GFF file into a PLAZA csv format for the db.

=head1 SYNOPSIS

./GFFParser.pl -i poptr.gff -o annotation.csv 
               -t transcripts.fasta
               -p peptides.fasta
               -g genome.fasta
  
=head1 DESCRIPTION

First parses a GFF file into a useable hash format. It groups the exons of a
gene on the 'name' attribute in attribute column of the GFF file.

Hereafter the genes are sorted according to chromosome and coordinates. An
internal gene_id will be given to each gene. It is incremented by 10, except
for the genes on the scaffolds which is incremented by 5. They both start
counting at 10.

Some datasanitation:
- Sequences have been chomped and cleared of whitespace.
- A sequence has been complemented if necessary to match the protein sequence.
- A sequence has been reversed if on the minus strand.

Some quality checks have been implemented:
- The length of the transcript sequence has to be equal with the length
  calculated from coordinates of the exons. Only a warning will be displayed
  if a sequence does not comply.
- The cds sequence cut from the genome has to be equal to the cds sequence
  cut from the transcript (out of transcript.fasta). If not equal it will be
  noted in the comment field of the csv with 'prot=ne' (because the following
  condition won't be true.
- The translated cds sequence has to be equal with the protein sequence (from
  protein.fasta). If this is not equal, it will be noted in the comment field
  of the csv file with 'prot=ne'.
  If it is equal, it will be noted with 'prot=eq'.
  If no protein is found it will be noted with 'prot=none'.
 
=head1 ARGUMENTS

  none

=head1 OPTIONS

  -i, --input       : The input GFF file. This must be valid GFF3.
  -o, --output      : The name of the CSV file to output.
  -t, --tr-filename : The name of the fasta file with the transcript
                      sequences.
  -p, pep-filename  : The name of the fasta file with the peptide sequences.
  -f, seq-filename  : The name of the fasta file with the sequence of the
                      chromosome.
  -u, --usage       : Print this.
  -h, --help        : Print the help.

=head1 METHODS

Full description of your module's methods. Use this as a template.

  Title   : print_plaza_format
  Usage   : 
    &_print_plaza_format({
        'gene_id'       => 'PT' . $chr_nr . 'G' . &_add_leading_zeros($last_gene_id_of{ $gene_id_chr }),
        'species'       => $species,
        'transcript_nr' => $transcript_nr,
        'cds_coords'    => $coords,
        'start'         => $start,
        'stop'          => $stop,
        'tr_coords'     => $coords_tr,
        'seq'           => $cds_seq,
        'strand'        => $strand,
        'chr'           => $chr,
        'gene_type'     => $gene_type,
        'go_codes'      => 'NULL',
        'desc'          => $desc,
        'comment'       => join(q{;}, @comments),
        'source_key'    => $source_key,
    });
  Purpose : Prints the csv format.
  Returns : Nothing.
  Args    : A hash with following keys (for more information about the PLAZA
            db see the PLAZA technical specification document found in the svn
            under 'doc'):
            gene_id : The gene id.
            species : The species name in a 3 letter format.
            transcript_nr : The full gene id with transcript nr.
            cds_coords : The EMBL like cds coordinates.
            start : The lowest start (cds) coordinate.
            stop : The highest start (cds) coordinate.
            tr_coords : The EMBL like transcript coordinates.
            seq : The (cds) sequence.
            strand : The strand (+|-).
            chr : The name of the chromosome in the GFF file.
            gene_type : The gene type (coding).
            go_codes : The GO codes (null).
            desc : The description (name of gene).
            comment : Comments.
            source_key : The source key found in annot_source.


    Title   : _glue_seq
    Usage   : 
              my $coords = 'complement(join(1..25,28..31))';
              my $sequence = &_glue_seq({
                    'gene_id' => 'PTR01G00010',
                    'coords'  => \$coords,
                    'genome'  => \$sequence,
              });
    Purpose : glues together a sequence based on it EMBL like coordinates.
    TODO    : disconnect this functions dependence on EMBL like coordinates.
    Returns : The glued sequence or 0 if 'genome' was empty.
    args    :
        gene_id: only necessary for error checking. On error prints out the
                 gene_id.
        coords : a reference to the EMBL like coords.
        genome : a reference to the genome.

    Title   : _get_start_stop
    Usage   : my $start_stop_ref = &_get_start_stop({ '1' => '25', '28' => 32'});
    Purpose : Gets the lowest and the highest coordinate.
    Returns : { 'start' => $start, 'stop' => $stop }.
    Args    : A hash with following key:
        coords : exon coordinates with the key as start coordinate and the
                 value as stop coordinate.

    
    Title   : _get_offset
    Usage   : my $offset = &_get_offset({
                'cds_coords' => \%coords_of,
                'tr_coords' => \%coords_tr_of
              });
    Purpose : Gets the offset to subtract from the CDS coordinates so
              that it seems that the first coordinate of the transcript is
              placed at 1 AND that there are no introns in the UTR.
              This function is necessary to calculate the the CDS sequence out
              of the transcript sequence if only the latter one is given.
    Returns : The offset to substract from the cds coordinates.
    Args    : Hash with following keys:
        cds_coords : A reference to the cds coords in a start => stop format.
        tr_coords  : A reference to the trancript coordinates in a start =>
                     stop format.

    Title   : _by_coord
    Usage   : foreach my $exons_ref (sort _by_coord values %exons_of) {}
    Purpose : Sorts the %exons_of hash according to starting coordinates.
              If it is a scaffold it first sorts according to scaffold number.
              ATTENTION: apparently, this doesn't sort correctly when you sort
              both scaffolds and non-scaffolds at the same time. You should
              comment out the scaffold part when dealing with genes and
              vice-versa.
    Returns : -1, 0 or 1
    Args    : A list to sort.

    Title   : _by_start_coord
    Usage   : foreach my $exon_ref (sort _by_start_coord @{ $exons_ref }) {}
    Purpose : Sorts the @exons array according to starting coordinates.
    Returns : -1, 0 or 1
    Args    : A list to sort.

=head1 SEE ALSO

GFF3: http://www.sanger.ac.uk/Software/formats/GFF/GFF_Spec.shtml

=head1 AUTHOR

Kenny Billiau, E<lt>kebil@psb.ugent.beE<gt>

=head1 COPYRIGHT AND LICENSE

Kenny Billiau, E<lt>kebil@psb.ugent.beE<gt>

=cut
