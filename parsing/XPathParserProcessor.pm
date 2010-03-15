package PLAZA::XML::XPathParserProcessor;

use strict;
use warnings;
use PLAZA::XML::XPathParser;
use PLAZA::XML::XPathParserChecker;
use PLAZA::XML::XPathParserPost;
use Data::Dumper;
use Smart::Comments '####'; # '###' is for debug, '####' is for verbosity 

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
    process_file 
    print_plaza_format
    print_gff_format
    group
);

our $VERSION = '0.01';

# Preloaded methods go here.

# Comments : prepend internal methods with _

my $field_delim = qq{;};
my $field_encap = qq{"};
my %xpath_of;
my $species;
my $source_key;
my $csv_fh;
my $cds_filename;
my $pep_filename;
my $seq_filename;

my $tu = 0;
my $rna = 0;
my $te = 0;
my $te_for_coding = 0;
my $error = 0;

my @unfinished_genes = ();
my $assembly_seq;

sub process_file() {
    my ($init_params_ref) = @_;

    #### <now> Started parsing ...
    # remember these values
    %xpath_of     = %{ $init_params_ref->{ 'xpath_of'     } };
    $species      = ${ $init_params_ref->{ 'species'      } };
    $source_key   = ${ $init_params_ref->{ 'source_key'   } };
    my $csvfile   = ${ $init_params_ref->{ 'csvfile'      } };
    my $gfffile   = ${ $init_params_ref->{ 'gfffile'      } };
    $cds_filename = ${ $init_params_ref->{ 'cds_filename' } };
    $pep_filename = ${ $init_params_ref->{ 'pep_filename' } };
    $seq_filename = ${ $init_params_ref->{ 'seq_filename' } };

    # open the output files
    open CSVFILE, ">$csvfile" or die "Cannot open $csvfile";
    $csv_fh = *CSVFILE;
#    open GFFFILE, ">$gfffile" or die "Cannot open $gfffile";

    &parse_file($init_params_ref);

    # some statistics
    #### coding: $tu
    #### rna   : $rna
    #### te    : $te, $te_for_coding
    #### ERRORS: $error;

    # close the output files
    close CSVFILE;
#    close GFFFILE;

    #### <now> Done.
}

sub group() {
    my ($t,$tag) = @_;
    
    # create the xpath to the element ..
    my $xpath = '/' . join('/',$t->{twig_parser}->context,$tag);

    $t->purge;
    
    # exec function according to group ..
    SWITCH: {
        $xpath eq $xpath_of{ 'tu' } && do {
            my $current_group_ref = &get_current_group;
            if ($current_group_ref->{ $xpath_of{ 'pseudogene' } } == '0') {
                my $best_model_ref = &_get_best_model;
                &print_coding_gene({ 'transcript' => $current_group_ref, 'best_model' => $best_model_ref});
            }
            else {
                &print_pseudogene({ 'transcript' => $current_group_ref, 'best_model' => @{ $current_group_ref->{ $xpath_of{ 'model'}}}[0] });
            }
            $tu++;
            last SWITCH;
        };
        my $quoted_rna = quotemeta('/TIGR/PSEUDOCHROMOSOME/ASSEMBLY/GENE_LIST/RNA_GENES/');
        $xpath =~ m/$quoted_rna(PRE\-TRNA|SNRNA|SNORNA|MIRNA|MISCRNA|RRNA|SIRNA|SLRNA|SRNA)/ && do {
            &print_rna({ 'current_group' => &get_current_group });
            $rna++;
            last SWITCH;
        };
        $xpath eq $xpath_of{ 'assembly' } && do {
            ($assembly_seq = &get_current_group->{ $xpath_of{ 'assembly_seq' } }) =~ s/[\n\r]//g;
            #### check: defined $assembly_seq;
            #### <now> Processing unfinished genes...
            &process_unfinished_genes;
            last SWITCH;
        };
    }
    &rm_subgroup($xpath);
}

sub process_unfinished_genes() {
    #### Unfinished genes: $#unfinished_genes + 1
    foreach my $gene_ref (@unfinished_genes) { #### processed %
        if (defined $gene_ref->{ 'glue_coords' }) { # crap, we have to glue the sequence together
            $gene_ref->{ 'seq' } = &glue_seq({ 'coords' => \$gene_ref->{ 'glue_coords' }, 'gene_id' => $gene_ref->{ 'gene_id' } });
        }
        else { # for pseudo genes and rna
            my $start = $gene_ref->{ 'start' };
            my $stop  = $gene_ref->{ 'stop' };
            my $seq = &_complement(substr($assembly_seq, $start - 1, $stop - $start + 1));
            if ($gene_ref->{ 'strand' } eq q{-}) {
                $seq = reverse $seq;
            }
            $gene_ref->{ 'seq' } = $seq;
            #### check: length $gene_ref->{seq} == $stop - $start + 1 && $gene_ref->{gene_id}
        }
        
        &print_plaza_format($gene_ref);
        $gene_ref = undef;
    }
}

sub glue_seq() {
    my ($in_ref) = @_;

    my $gene_coords = ${ $in_ref->{ 'coords' } };
    my $gene_id = $in_ref->{ 'gene_id' };

    my @coords = split(q{,},$gene_coords);
    my $seq_len = 0; # DEBUG

    # remove join( or complement(join( and ) or ))
    $coords[0] = substr($coords[0], rindex( $coords[0],'(' ) + 1);
    $coords[$#coords] =~ s/\)+//;
    
    my $seq = q{};
    foreach my $coord (@coords) {
        my ($start,$stop) = split('\.\.',$coord);
        #### check: $start =~ /^-?\d/ && $stop =~ /^-?\d/
        my $diff = int($stop) - int($start);
        $seq .= substr($assembly_seq, $start - 1, $diff + 1);
        $seq_len += abs($stop - $start) + 1;
    }

    $seq =~ s/\s+//g;
    
    #### check: length $seq == $seq_len && $gene_id
    
    if (index($gene_coords,'complement(') == 0) {
        $seq = reverse $seq;
    }

    return $seq;
}

sub print_gff3_format() {

}

sub print_plaza_format() {
    # "gene_id";"species";"transcript";"coord";"start";"stop";"coord_transcript";"seq";"strand";"chr";"type";"go_code";"desc";"source_key"
    # mysqlimport -C -h psbsql01 --local -v --fields-enclosed-by=\" --fields-terminated-by=\; --lines-terminated-by=\\n -p db_kebil_plaza annotation.csv

    my ($in_ref) = @_;

    if (!($in_ref->{ 'gene_id' } &&
        $in_ref->{ 'species' } &&
        $in_ref->{ 'transcript_nr' } &&
        $in_ref->{ 'cds_coords' } &&
        $in_ref->{ 'start' } &&
        $in_ref->{ 'stop' } &&
        $in_ref->{ 'tr_coords' } &&
        $in_ref->{ 'seq' } &&
        $in_ref->{ 'strand' } &&
        $in_ref->{ 'chr' } &&
        $in_ref->{ 'gene_type' } &&
        $in_ref->{ 'go_codes' } &&
        $in_ref->{ 'desc' } &&
        $in_ref->{ 'source_key' })) {
        print Dumper $in_ref;
    }

    # make sure we have extracted the correct gene-id in the correct format (e.g.AT1G01010)
    my $gene_id = uc($in_ref->{ 'gene_id' });
    $gene_id =~ s/.*(([A-Z]{2}[0-9]{1,2}[GMC][0-9]{5})|(TRF[0-9]{7})).*/$1/;
    $in_ref->{ 'gene_id' } = $gene_id;

    # do some last quality tests
    if (&_do_quality_checks($in_ref)) {
        $error++;
    }
    
    # check the list provided by tigr to see if this is a TE - only for osa
    if (&is_transposon({
               'filename' => '/home/kebil/plazadata/osa/all.TE-related',
               'full_gene_id' => $in_ref->{ 'gene_id'} . $in_ref->{ 'transcript_nr' },
            })
    ) {
        ### Old gene_type: $in_ref->{ gene_type }
        $in_ref->{ 'gene_type' } = 'te';
    }

    # print it ..
    print $csv_fh $field_encap, $gene_id,                               $field_encap, $field_delim; # gene_id
    print $csv_fh $field_encap, $in_ref->{ 'species' },                 $field_encap, $field_delim; # species
    print $csv_fh $field_encap, $gene_id, $in_ref->{ 'transcript_nr' }, $field_encap, $field_delim; # transcript
    print $csv_fh $field_encap, $in_ref->{ 'cds_coords' },              $field_encap, $field_delim; # coord
    print $csv_fh $field_encap, $in_ref->{ 'start' },                   $field_encap, $field_delim; # start
    print $csv_fh $field_encap, $in_ref->{ 'stop' },                    $field_encap, $field_delim; # stop
    print $csv_fh $field_encap, $in_ref->{ 'tr_coords' },               $field_encap, $field_delim; # coord_transcript
    print $csv_fh $field_encap, $in_ref->{ 'seq' },                     $field_encap, $field_delim; # seq
    print $csv_fh $field_encap, $in_ref->{ 'strand' },                  $field_encap, $field_delim; # strand
    print $csv_fh $field_encap, $in_ref->{ 'chr' },                     $field_encap, $field_delim; # chr
    print $csv_fh $field_encap, $in_ref->{ 'gene_type' },               $field_encap, $field_delim; # type
    print $csv_fh $field_encap, $in_ref->{ 'go_codes' },                $field_encap, $field_delim; # go_code
    print $csv_fh $field_encap, &_escape_delim($in_ref->{ 'desc' }),    $field_encap, $field_delim; # desc
    print $csv_fh $field_encap, &_escape_delim($in_ref->{ 'comment' }), $field_encap, $field_delim; # comment
    print $csv_fh $field_encap, $in_ref->{ 'source_key' },              $field_encap, $field_delim; # source_key
    print $csv_fh "\n";
}

sub _do_quality_checks {
    my ($in_ref) = @_;
    
    my $gene_id = $in_ref->{ 'gene_id' };
    my $error = 0;
    
    # do some last quality checks
    if ($in_ref->{ 'gene_type' } eq 'coding') {

        if (&_check_start_codon(\$in_ref->{ 'seq' }) == -1) {
            $in_ref->{ 'seq' } = &_complement($in_ref->{ 'seq' });
        }

        #### check: length($in_ref->{ seq }) % 3 == 0 && $gene_id
        #### check: substr($in_ref->{ seq }, 0, 3) eq q{ATG} && $gene_id
        if (length($in_ref->{ 'seq' }) % 3 !=0 || substr($in_ref->{ 'seq' }, 0, 3) ne q{ATG}) {
            $error = 1;
        }

        if ($cds_filename) {
            # check if the cds is corresponding with the sequence from the fasta file
            my $equal_with_fasta = &check_cds({ 'cds_filename' => $cds_filename,
                                                'cds_seq_ref' => \$in_ref->{ 'seq' },
                                                'full_gene_id' => $gene_id . $in_ref->{ 'transcript_nr' }
                                             });
            if ($equal_with_fasta == -1) {
                $in_ref->{ 'seq' } = &_complement($in_ref->{ 'seq' });
                $equal_with_fasta = 1;
            }
            #### check: $equal_with_fasta == 1 && $gene_id && $in_ref->{ transcript_nr } && $in_ref->{seq}
            if ($equal_with_fasta == 0) {
                $error = 1;
            }
        }

        if ($pep_filename) {
            # is the encod seq corresponding with the one in the fasta file
            my $equal_with_pep = &check_pep({ 'pep_filename' => $pep_filename,
                                              'cds_seq_ref' => \$in_ref->{ 'seq' },
                                              'full_gene_id' => $gene_id . $in_ref->{ 'transcript_nr' }
                                           });
            #### check: $equal_with_pep == 1 && $gene_id && $in_ref->{ transcript_nr } && $in_ref->{seq}
            if ($equal_with_pep == 0) {
                $error = 1;
            }
        }
    }
    else {

        # check if the sequence is corresponding with the sequence from the fasta file
        my $equal_with_fasta2 = &check_seq({ 'cds_filename' => $seq_filename,
                                             'cds_seq_ref' => \$in_ref->{ 'seq' },
                                             'full_gene_id' => $gene_id . $in_ref->{ 'transcript_nr' }
                                          });
        if ($equal_with_fasta2 == -1) {
            $in_ref->{ 'seq' } = &_complement($in_ref->{ 'seq' });
            $equal_with_fasta2 = 1;
        }
        #### check: $equal_with_fasta2 == 1 && $gene_id && $in_ref->{ transcript_nr } && $in_ref->{seq}
        if ($equal_with_fasta2 == 0) {
            $error = 1;
        }
    }
    return $error;
}

sub print_coding_gene() {
    my ($in_ref) = @_;

    my $transcript_ref = $in_ref->{ 'transcript' };
    my $best_model_ref = $in_ref->{ 'best_model' };

    my %print_value_of = ();
    
    # clear cds sequence of whitespace
    my $process_later = 0;
    if ($best_model_ref->{ $xpath_of{ 'cds' } }) {
        ($print_value_of{ 'seq' } = $best_model_ref->{ $xpath_of{ 'cds' } }) =~ s/\s+//g;     # cds
        $best_model_ref->{ $xpath_of{ 'cds' } } = $print_value_of{ 'seq' };
    }
    else {
        $print_value_of{ 'seq' } = 'NULL';
        $process_later = 1;
    }

    # get the gene_id and the transcript version
    my ($gene_id, $transcript_nr) = split '\.', $best_model_ref->{ $xpath_of{ 'gene_id' } };
    if (length $gene_id == 0) {
        $gene_id = $best_model_ref->{ $xpath_of{ 'gene_id' } };
        $transcript_nr = '1';
    }
    $transcript_nr = q{.} . $transcript_nr; 

    # get the go codes in the right format
    my $go_codes = &_get_GO_codes($transcript_ref);

    # determine if this is a transposon
    my $gene_type = 'coding';
    my $comment = $transcript_ref->{ $xpath_of{ 'pub_comment' } };
    if (defined $comment && $comment =~ /transpos(on|ase)/) {
#        $gene_type = 'te';
        print 'Possible transposon as coding gene: ' . $best_model_ref->{ $xpath_of{ 'gene_id'} } . "\n";
        $te_for_coding++; # count them for DEBUG
    }
#    else {
#        $gene_type = 'coding';
#    }
    
    # check strand
    my $start = $best_model_ref->{ $xpath_of{ '5_cds_start' } };
    my $stop  = $best_model_ref->{ $xpath_of{ '3_cds_start' } };
    my $strand = q{+};
    if ($start > $stop) {
        $strand = q{-};
        ($start,$stop) = ($stop,$start);
    }

    # create the embl-like format out of the cds coords
    my $embl_coords_ref = &_get_embl_coords($best_model_ref);
    $print_value_of{ 'cds_coords'    } = ${ $embl_coords_ref->{ 'cds_coords' } };
    $print_value_of{ 'gene_id'       } = $gene_id;
    $print_value_of{ 'transcript_nr' } = $transcript_nr;
    $print_value_of{ 'species'       } = $species;
    $print_value_of{ 'start'         } = $start;
    $print_value_of{ 'stop'          } = $stop;
    $print_value_of{ 'tr_coords'     } = ${ $embl_coords_ref->{ 'tr_coords' } };
    $print_value_of{ 'strand'        } = $strand;
    $print_value_of{ 'chr'           } = @{ $transcript_ref->{ $xpath_of{ 'chr' } } }[0];
    $print_value_of{ 'gene_type'     } = $gene_type;
    $print_value_of{ 'go_codes'      } = defined $go_codes ? join(',', @{$go_codes}) : 'NULL';
    $print_value_of{ 'desc'          } = $transcript_ref->{ $xpath_of{ 'desc' } };
    $print_value_of{ 'comment'       } = defined $comment ? $comment : 'NULL';
    $print_value_of{ 'source_key'    } = $source_key;

    # check if the sequence is ok, if not, give it a second chance
    if (&_check_start_codon(\$print_value_of{ 'seq' }) == -1) {
        $print_value_of{ 'seq' } = &_complement($print_value_of{ 'seq' });
    }
    if (!$process_later && &_check_seq_codons(\$print_value_of{ 'seq' }) && &_check_start_codon(\$print_value_of{ 'seq' })) {
        &print_plaza_format(\%print_value_of);
    }
    else {
        print 'Added ' . $print_value_of{ 'gene_id' } . " for reprocessing...\n";
        $print_value_of{ 'glue_coords' } = ${ $embl_coords_ref->{ 'cds_coords' } };
        push @unfinished_genes, \%print_value_of; 
    }
}

sub print_pseudogene {
    my ($in_ref) = @_;

    my $transcript_ref = $in_ref->{ 'transcript' };
    my $best_model_ref = $in_ref->{ 'best_model' };

    my %print_value_of = ();

    # get the gene_id and the transcript version
    my ($gene_id, $transcript_nr) = split '\.', $best_model_ref->{ $xpath_of{ 'gene_id' } };
    if (length $gene_id == 0) {
        $gene_id = $best_model_ref->{ $xpath_of{ 'gene_id' } };
        $transcript_nr = '1';
    }
    $transcript_nr = q{.} . $transcript_nr; 

    # check strand
    my $complement = 0;
    my $start = $best_model_ref->{ $xpath_of{ '5_cds_start' } };
    my $stop  = $best_model_ref->{ $xpath_of{ '3_cds_start' } };
    my $strand = q{+};
    if ($start > $stop) {
        $strand = q{-};
        ($start,$stop) = ($stop,$start);
        $complement = 1;
    }

    # determine if this is a transposon - for osysa there is a list :)
    my $gene_type = 'pseudo';
    my $comment = $transcript_ref->{ $xpath_of{ 'pub_comment' } };
    ## next is for ath only ##
#    if ($comment =~ /transpos(on|ase)/) {
#        $gene_type = 'te';
#        $te++; # count them for DEBUG
#    }
#    else {
#        $gene_type = 'pseudo';
#    }

    # determine transcript coords
    my $tr_coords;
    if (!$complement) {
        $tr_coords = 'join(' . $transcript_ref->{ $xpath_of{ '5_transcript' } } . '..' . $transcript_ref->{ $xpath_of{ '3_transcript' } } . ')';
    }
    else {
        $tr_coords = 'complement(join(' . $transcript_ref->{ $xpath_of{ '3_transcript' } } . '..' . $transcript_ref->{ $xpath_of{ '5_transcript' } } . '))';
    }
 
    my $go_codes = &_get_GO_codes($transcript_ref);
    
    $print_value_of{ 'seq'           } = 'NULL';
    $print_value_of{ 'cds_coords'    } = 'NULL';
    $print_value_of{ 'gene_id'       } = $gene_id;
    $print_value_of{ 'transcript_nr' } = $transcript_nr;
    $print_value_of{ 'species'       } = $species;
    $print_value_of{ 'start'         } = $start;
    $print_value_of{ 'stop'          } = $stop;
    $print_value_of{ 'tr_coords'     } = $tr_coords;
    $print_value_of{ 'strand'        } = $strand;
    $print_value_of{ 'chr'           } = @{ $transcript_ref->{ $xpath_of{ 'chr' } } }[0];
    $print_value_of{ 'gene_type'     } = $gene_type;
    $print_value_of{ 'go_codes'      } = defined $go_codes ? join(',', @{$go_codes}) : 'NULL';
    $print_value_of{ 'desc'          } = $transcript_ref->{ $xpath_of{ 'desc' } };
    $print_value_of{ 'comment'       } = defined $comment ? $comment : 'NULL';
    $print_value_of{ 'source_key'    } = $source_key;
    push @unfinished_genes, \%print_value_of;
}

sub print_rna() {
    my ($in_ref) = @_;

    my $current_group_ref = $in_ref->{ 'current_group' };

    # find the correct kind of rna
    my $prefix = q{};
    my @prefixes = ('pre-trna','snrna','snorna','mirna','miscrna','rrna','sirna','slrna','srna');
    PREFIX:
    for(my $i = 0; $i < $#prefixes + 1; $i++) {
        if ($current_group_ref->{ $xpath_of{ $prefixes[$i] . '_5' } }) {
            $prefix = $prefixes[$i];
            last PREFIX;
        }
    }

    # get the gene_id and the transcript version
    my ($gene_id, $transcript_nr) = split '\.', $current_group_ref->{ $xpath_of{ $prefix . '_gene_id' } };
    if (!$gene_id) {
        $gene_id = $current_group_ref->{ $xpath_of{ $prefix . '_gene_id' } };
    }
    if (!$transcript_nr) {
        $transcript_nr = '1';
    }
    $transcript_nr = q{.} . $transcript_nr;

    # check strand
    my $complement = 0;
    my $start = $current_group_ref->{ $xpath_of{ $prefix . '_5' } };
    my $stop  = $current_group_ref->{ $xpath_of{ $prefix . '_3' } };
    my $strand = q{+};
    if ($start > $stop) {
        $strand = q{-};
        ($start,$stop) = ($stop,$start);
        $complement = 1;
    }
 
    my $exon_coords_str = 'NULL';
    my %print_value_of = ();
    
    # the only exception, if pre-trna, bring together exons
    if ($prefix eq 'pre-trna') {
        my $exons_ref = $current_group_ref->{ $xpath_of{ $prefix . '_exon' } };
        my @exon_coords = ();
        
        for my $exon (@{ $exons_ref }) {
            my $three_prime = $exon->{ $xpath_of{ $prefix . '_exon_3' } };
            my $five_prime  = $exon->{ $xpath_of{ $prefix . '_exon_5' } };
            
            if ($complement) {
                push @exon_coords, "$three_prime..$five_prime";
            }
            else {
                push @exon_coords, "$five_prime..$three_prime";
            }
        }

        $exon_coords_str = 'join(' . join(q{,},@exon_coords) . ')';
        if ($complement) {
            $exon_coords_str = "complement($exon_coords_str)";
        }
        $print_value_of{ 'glue_coords'   } = $exon_coords_str;
    }
    else { # determine transcript coords
        if (!$complement) {
            $exon_coords_str = 'join(' . $current_group_ref->{ $xpath_of{ $prefix . '_5' } } . '..' . $current_group_ref->{ $xpath_of{ $prefix . '_3' } } . ')';
        }
        else {
            $exon_coords_str = 'complement(join(' . $current_group_ref->{ $xpath_of{ $prefix . '_3' } } . '..' . $current_group_ref->{ $xpath_of{ $prefix . '_5' } } . '))';
        }
    }

    my $comment = $current_group_ref->{ $xpath_of{ 'pub_comment' } };
 
    $print_value_of{ 'seq'           } = 'NULL';
    $print_value_of{ 'cds_coords'    } = 'NULL';
    $print_value_of{ 'go_codes'      } = 'NULL';
    $print_value_of{ 'gene_id'       } = $gene_id;
    $print_value_of{ 'transcript_nr' } = $transcript_nr;
    $print_value_of{ 'species'       } = $species;
    $print_value_of{ 'start'         } = $start;
    $print_value_of{ 'stop'          } = $stop;
    $print_value_of{ 'tr_coords'     } = $exon_coords_str;
    $print_value_of{ 'strand'        } = $strand;
    $print_value_of{ 'chr'           } =  @{ $current_group_ref->{ $xpath_of{ 'chr' } } }[0];
    $print_value_of{ 'gene_type'     } = 'rna';
    $print_value_of{ 'desc'          } = $current_group_ref->{ $xpath_of{ $prefix . '_desc' } };
    $print_value_of{ 'comment'       } = defined $comment ? $comment : 'NULL';
    $print_value_of{ 'source_key'    } = $source_key;
    push @unfinished_genes, \%print_value_of;
}

sub _get_GO_codes() {
    my ($transcript_ref) = @_;
    
    # transform GO:GO:xxxxxxx to GO:xxxxxxx if necessary
    my $go_codes = $transcript_ref->{ $xpath_of{ 'GO' } };
    if (defined $go_codes && substr($go_codes->[0],0,6) eq 'GO:GO:') {
        @{ $go_codes } = map { $_ = substr($_,3) } @{ $go_codes };
    }
   
    return $go_codes;
}

sub _check_for_delim() {
    my ($input_hash_ref) = @_;
    foreach my $key (keys %$input_hash_ref) {
        $_ = $input_hash_ref->{$key};
        print($_,' ',$input_hash_ref->{ $xpath_of{ 'gene_id' } }, "\n") if /$field_delim/;
    }
}

sub _escape_delim() {
    my ($string) = @_;
    $string =~ s/"/\\"/;
    return $string;
}

sub _get_best_model() {
    my $best_model_ref;
    my $models_ref = &get_current_group->{ $xpath_of{ 'model' }};

    # init
    $best_model_ref = $models_ref->[0];
    my $best_model_cds_len = &_get_cds_length($best_model_ref);

    foreach my $model_ref ( @{ $models_ref } ) {
        my $model_cds_len = &_get_cds_length($model_ref);

        if ($model_cds_len > $best_model_cds_len) {
            $best_model_ref = $model_ref;
        } elsif ($model_cds_len == $best_model_cds_len) {
            $best_model_ref = &_get_longest_transcript( { 'model_ref' => $model_ref, 'best_model_ref' => $best_model_ref } );
            if ($model_ref == $best_model_ref) { # best model has changed
                $best_model_cds_len = $model_cds_len;
            }
        }
    }

    return $best_model_ref;
}

sub _get_cds_length() {
    my ($model_ref) = @_;

    my $cds_length;
    if (!defined $model_ref->{ $xpath_of{ 'cds' } }) {
        foreach my $exon_ref (@{ $model_ref->{ $xpath_of{ 'exon' } } }) {
            my $five_prime  = $exon_ref->{ $xpath_of{ '5_cds' } };
            my $three_prime = $exon_ref->{ $xpath_of{ '3_cds' } };
            if ($five_prime && $three_prime) {
                $cds_length += abs($five_prime - $three_prime) + 1;
            }
        }
    }
    else {
        $cds_length = length $model_ref->{ $xpath_of{ 'cds' } };
    }

    return $cds_length;
}

sub _get_longest_transcript() {
    my ($in_ref) = @_;
    my $model_ref      = $in_ref->{ 'model_ref'      };
    my $best_model_ref = $in_ref->{ 'best_model_ref' };
    my $transcript_len_model = 0;
    my $transcript_len_best_model = 0;
    if (!defined $best_model_ref->{ 'transcript_len' }) {
        $transcript_len_best_model = &_get_transcript_len($best_model_ref);
        $best_model_ref->{ 'transcript_len' } = $transcript_len_best_model;
    }
    else {
        $transcript_len_best_model = $best_model_ref->{ 'transcript_len' };
    }
    $transcript_len_model = &_get_transcript_len($model_ref);

    if ($transcript_len_model > $transcript_len_best_model) {
        $model_ref->{ 'transcript_len' } = $transcript_len_model;
        $best_model_ref = $model_ref;
    }

    return $best_model_ref;
}

sub _get_transcript_len() {
    my ($model_ref) = @_;
    my $total_len = 0;
    my @postfixes = ('_utr_left','_utr_right','_utr_ext');
    # check for extended, left and right utr and count them together
    foreach my $exon_ref (@{ $model_ref->{ $xpath_of{ 'exon' }} }) {
        foreach my $postfix (@postfixes) {
            my $five_prime  = $exon_ref->{ $xpath_of{ '5' . $postfix }};
            my $three_prime = $exon_ref->{ $xpath_of{ '3' . $postfix }};
            if ($five_prime && $three_prime) {
                $total_len += abs($five_prime - $three_prime) + 1;
            }
        }
    }
    return $total_len + &_get_cds_length($model_ref);
}

sub _get_utr_coords {
    my ($in_ref) = @_;

    my $exon_ref      = $in_ref->{ 'exon' };
    my $postfixes_ref = $in_ref->{ 'postfixes' };
    my $complement    = $in_ref->{ 'complement' };

    my $tr_coords;
    
    EXON:
    foreach my $postfix (@{ $postfixes_ref }) {
        my $five_prime  = $exon_ref->{ $xpath_of{ '5' . $postfix } };
        my $three_prime = $exon_ref->{ $xpath_of{ '3' . $postfix } };
        if ($five_prime && $three_prime) {
            $tr_coords = $complement ? "$three_prime..$five_prime"
                                     : "$five_prime..$three_prime";
            last EXON;                            
        }
    }

    return \$tr_coords;
}

sub _by_5_exon {
    $a->{ $xpath_of{ '5_exon' } } <=> $b->{ $xpath_of{ '5_exon' } };
}

sub _get_embl_coords() {
    my ($best_model_ref) = @_;

    my @cds_coords = ();
    my @tr_coords  = ();
    my $complement = 0;

    my $calced_cds_len = 0; #DEBUG

    # first determine if this is on the minus strand or not ..
    if ($best_model_ref->{ $xpath_of{ '5_cds_start' } }  >  $best_model_ref->{ $xpath_of{ '3_cds_start' } }) {
        $complement = 1;
    }
    
    # then append the coords
    foreach my $exon (sort _by_5_exon @{ $best_model_ref->{ $xpath_of{ 'exon' } } }) {

        #first, check for utr
        my @postfixes = ('_utr_ext','_utr_left');
        if ($complement) {
            @postfixes = ('_utr_ext','_utr_right');
        }
        my $utr_coords = ${ &_get_utr_coords({ 'exon' => $exon, 'postfixes' => \@postfixes , 'complement' => $complement }) };
        if ($utr_coords) {
            push @tr_coords, $utr_coords;
        }
       
        # determine the cds coords, if any (if none, it's extended utr)
        my $three_prime = $exon->{ $xpath_of{ '3_cds' } };
        my $five_prime  = $exon->{ $xpath_of{ '5_cds' } };
        
        if ($three_prime && $five_prime) {

            # if 3' < 5' use complement and put them in ascending order
            if ($complement) {
                push @cds_coords, "$three_prime..$five_prime";
                push @tr_coords,  "$three_prime..$five_prime";
            }
            else {
                push @cds_coords, "$five_prime..$three_prime";
                push @tr_coords,  "$five_prime..$three_prime";
            }
            $calced_cds_len += $five_prime - $three_prime > 0 ? $five_prime - $three_prime 
                                                              : $three_prime - $five_prime; # DEBUG
            $calced_cds_len++; # DEBUG
        }

        #last, check for utr
        if (!$utr_coords) { # if we already found an utr in this exon, don't check again
            @postfixes = ('_utr_right','_utr_ext');
            if ($complement) {
                @postfixes = ('_utr_left','_utr_ext');
            }
            $utr_coords = ${ &_get_utr_coords({ 'exon' => $exon, 'postfixes' => \@postfixes , 'complement' => $complement }) };
            if ($utr_coords) {
                push @tr_coords, $utr_coords;
            }
        }
    }

    my $cds_len = &_get_cds_length($best_model_ref);
    #### check: $calced_cds_len == $cds_len && $best_model_ref->{ $xpath_of{ gene_id } }

    my $cds_coords_str = 'join(' . join(q{,}, @cds_coords) . ')';
    my $tr_coords_str  = 'join(' . join(q{,}, @tr_coords)  . ')';
    if ($complement) {
        $cds_coords_str = "complement($cds_coords_str)";
        $tr_coords_str  = "complement($tr_coords_str)";
    }

    return { 'cds_coords' => \$cds_coords_str, 'tr_coords' => \$tr_coords_str };
}


# some quality checks

sub _check_seq_codons {
    my ($seq_ref) = @_;

    # check if the sequence is a multiple of 3
    if (length(${ $seq_ref }) % 3 != 0) {
        return 0;
    }
    return 1;
}

sub _check_start_codon {
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

sub _complement {
    my ($seq) = @_;
    $seq = uc($seq);
    $seq =~ tr/('A','T','G','C')/('T','A','C','G')/;
    return $seq;
}

1;
__END__

=head1 NAME

XPathParserProcessor - Processes the data retrieved from an XML file processed
with XPathParser.

=head1 SYNOPSIS

  use XPathParser;
  use XPathParserProcessor; 

  &process_file({ param => value, param => value});

=head1 DESCRIPTION

XPathParserProcessor will handle the data delivered from the XPathParser
module. It is specifically designed for TiGR xml (or Tair) eventhough the same
principles could easily be used for a similar parser.

Following actions are taken with the data:
- building EMBL like coordinates for coding genes and pre-trna genes
- data sanitation on the sequence:
  - chomp and remove whitespace
  - complementing and reversing if necessery. This happens when a coding gene
    starts with TAC instead of ATG or is on the reverse strand.
  - reformating the gene_id (uppercase, removing of proceeding 'LOC_' string
  - reformating the GO codes
- quality checks: (provided by XPathParserChecker module)
    - cds checked against cds provided by a fasta file
    - seq checked for non-coding genes
    - translated coding sequence is checked with peptide sequence provided by
      a fasta file
    - length of coding sequence should by dividable by 3
- sequence is copied and glued together from the raw sequence provided in the
  xml file.
- determining the gene type:
  - for transposable elements a list could be used (functionality provided by
    XPathParserPost)
  - or a regex to check comments on transpos(on|ase)
- determining the 'best' transcript if miltiple models:
  - the longest cds has to taken
  - if some lengths of cds'es are equal, the model with the longest transcript
    wins.

=head1 EXPORT

    process_file 
    print_plaza_format
    print_gff_format
    group

=head1 EXAMPLES

=head2 EXAMPLE TITLE

  # Indent your example code with two spaces
  use Template; 
  blah blah blah

Example description.
Blah blah blah.

=head1 METHODS

Full description of your module's methods. Use this as a template.

  Title   : process_file
  Usage   : function_name()
  Purpose : Main method of parsing module.
  Returns : nothing (please DO return something!)
  Args    : not stable enough yet

  Title   : group

  Title   : add

  Title   : add_att
  Etc ...

=head1 SEE ALSO

Other useful modules, webpages, man pages, etc ...

=head1 AUTHOR

Kenny Billiau, E<lt>kebil@psb.ugent.beE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Francis Dierick

=cut
