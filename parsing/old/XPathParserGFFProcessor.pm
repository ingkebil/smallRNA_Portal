package PLAZA::XML::XPathParserGFFProcessor;

use strict;
use warnings;
use PLAZA::XML::XPathParser;
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
print_gene
group
);

our $VERSION = '0.01';

# Preloaded methods go here.

# Comments : prepend internal methods with _

my %xpath_of;
my $gff_fh;
my %line_of;

sub process_file() {
    my ($init_params_ref) = @_;

    #### <now> Started parsing ...
    # remember these values
    %xpath_of     = %{ $init_params_ref->{ 'xpath_of'     } };
    my $gfffile   = ${ $init_params_ref->{ 'gfffile'      } };

    # open the output files
    open GFFFILE, ">$gfffile" or die "Cannot open $gfffile";
    $gff_fh = *GFFFILE;

    &parse_file($init_params_ref);
    &print_to_file;

    # close the output files
    close GFFFILE;

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
            &print_gene($current_group_ref);
            last SWITCH;
        };
        #    my $quoted_rna = quotemeta('/TIGR/PSEUDOCHROMOSOME/ASSEMBLY/GENE_LIST/RNA_GENES/');
        #    $xpath =~ m/$quoted_rna(PRE\-TRNA|SNRNA|SNORNA|MIRNA|MISCRNA|RRNA|SIRNA|SLRNA|SRNA)/ && do {
        #        &print_rna({ 'current_group' => &get_current_group });
        #        $rna++;
        #        last SWITCH;
        #    };
    }
    &rm_subgroup($xpath);
}

sub print_gene {
    my ($tu_ref) = @_;
    
    my $is_pseudogene = $tu_ref->{ $xpath_of{ 'pseudogene' } };
    if (!$is_pseudogene) { # skip all pseudogenes and RNA genes (RNA genes will cause errors)

        # we only need a limited amount of data to build a gff file.
        # the format is:
        # seq_id    source  type    start   stop    score   strand  phase   attr

        # get the general information
        my $asml_id = ${ $tu_ref->{ $xpath_of{ 'chr' } } }[0];
        my $gene_line = q{};
        my $mrna_line = q{};
        my $exon_line = q{};
        my $cds_line  = q{};

        # make the track for the gene
#        my $start = $tu_ref->{ $xpath_of{ '5_transcript' } };
#        my $stop  = $tu_ref->{ $xpath_of{ '3_transcript' } };
#        my $strand = q{+};
#        if ($start > $stop) {
#            $strand = q{-};
#            ($start,$stop) = ($stop,$start);
#        }
#        my $model_id = $tu_ref->{ $xpath_of{ 'gene_id' } };
#        my ($gene_id,$transcript_nr) = split /\./, $model_id;
#        my $name = $tu_ref->{ $xpath_of{ 'desc' } };
#        my $note = $tu_ref->{ $xpath_of{ 'pub_comment' } };

#        $gene_line = "$asml_id\tTAIR\tgene\t$start\t$stop\t.\t$strand\t.\tname \"$gene_id\";\n";
#        &store($gene_line, $start);

        # now for all models, construct their exon lines..
        foreach my $model_ref (@{ $tu_ref->{ $xpath_of{ 'model' } } }) {

#            # construct the track for the model
#            $mrna_line = q{};
#            my $start = $model_ref->{ $xpath_of{ '5_cds_start' } };
#            my $stop  = $model_ref->{ $xpath_of{ '3_cds_start' } };
#            my $strand = q{+};
#            if ($start > $stop) {
#                $strand = q{-};
#                ($start,$stop) = ($stop,$start);
#            }
            my $model_id = $model_ref->{ $xpath_of{ 'gene_id' } };
#
#            $mrna_line = "$asml_id\t.\tmRNA\t$start\t$stop\t.\t$strand\t.\tID=$model_id;parent=$gene_id\n";
#            &store($mrna_line, $start);

            foreach my $exon_ref(@{ $model_ref->{ $xpath_of{ 'exon' } } }) {
                # construct the track for the exon
                $exon_line = q{};
                my $start = $exon_ref->{ $xpath_of{ '5_exon' } };
                my $stop  = $exon_ref->{ $xpath_of{ '3_exon' } };
                my $strand = q{+};
                if ($start > $stop) {
                    $strand = q{-};
                    ($start,$stop) = ($stop,$start);
                }
                #my $model_id = $model_ref->{ $xpath_of{ 'gene_id' } };

                $exon_line = "$asml_id\tTAIR\texon\t$start\t$stop\t.\t$strand\t.\tname \"$model_id\"\n";
                &store($exon_line, $start);

                # construct the track for the CDS
                $cds_line = q{};
                $start = $exon_ref->{ $xpath_of{ '5_cds' } };
                $stop  = $exon_ref->{ $xpath_of{ '3_cds' } };
                if ($start && $stop) { # it could be extended UTR
                    my $strand = q{+};
                    if ($start > $stop) {
                        $strand = q{-};
                        ($start,$stop) = ($stop,$start);
                    }

                    $cds_line = "$asml_id\tTAIR\tCDS\t$start\t$stop\t.\t$strand\t.\tname \"$model_id\"\n";
                    &store($cds_line, $start);
                }
            }
        }
    }
}

sub print_to_file {
    foreach my $start (sort {$a <=> $b } keys %line_of) { #### processed %
        foreach my $line (@{ $line_of{ $start } }) {
            print $gff_fh $line;
        }
    }
}

sub store {
    my $line = $_[0];
    my $start = $_[1];

    # a simple system to make a sort easy
    if (defined $line_of{ $start }) {
        my $lines_ref = $line_of{ $start };
        push @{ $lines_ref }, $line;
    }
    else {
       $line_of{ $start } = [$line];
    }
}

1;
__END__

=head1 NAME

XPathParserGFFProcessor - A TAIR/TIGR XML to GFF converter.

=head1 SYNOPSIS

Provides an easy way to generate a GFF3 file out of an XML file.

=head1 DESCRIPTION

This module makes use of the XPathParser module to get an uniform
datastructure. XPaths are provided by the invoking perl script and should
break up the XML file into transcriptional units (TU). The invoking script
and this module are working closely together. The only reason why this is a
module is to provide an easy way to have the same functionality for different
XPaths.

(Possible solution is to provide the XPaths through an external file.)

The principle is similar to the workings of the XPathParserProcessor module.
Everytime a TU is finished by the XPathParser, the group subroutine is
invoked. Herein the print_gene subroutine is invoked. This method will print
out a track for the gene and several tracks for the exons and CDS'es.

The current setup is to sort the created tracks on the starting coordinate.

=head1 EXPORT

  process_file
  group
  print_gene

=head1 EXAMPLES

none.
  
=head1 METHODS

Full description of your module's methods. Use this as a template.

  Title   : process_file
  Usage   : process_file({ init => params })
  Purpose : Main method of parsing module.
  Returns : Nothing.
  Args    : It expects one input hash with following keys:
        These keys are needed for the XPathParser module:
            attributes: A hashref which maps the XPaths of the attributes to the (exported) att_add function.
            elements  : A hashref which maps the XPaths of the elements to the (exported) add function.
            subgroups : A hashref which maps the XPaths of the subgroups to the (exported) subgroup function.
            groups    : A hashref which maps the XPaths of the groups to the (exported) group function.
            filename  : A reference to the name of the file to parse.
            See also Ath_TiGR_Parser for more information about the inputted hashrefs.
        These keys are needed by this module:
            gfffile : A reference to the name of the gff-file that will be
                      produced.
            xpath_of: A reference to a hashref with names mapped to the
                      XPaths. This hash will be used to key the returned hash
                      by the XPathParser module. See the XPathParser module
                      for an example.

  Title   : group
  Usage   : group()
  Purpose : Callback function for XML::Twig used in XPathParser. Is called
            everytime the group element is closed.
            This function gets the current information and calls the correct
            handling function. In this case only one exists: print_gine
  Returns : Nothing.
  Args    : A twig and the name of the element.

  Title   : print_gene
  Usage   : print_gene(\%tu)
            
  
=head1 SEE ALSO

XPathParser : https://bioinformatics.psb.ugent.be/knowledge/wiki-bioinformatics/XPathParser

=head1 AUTHOR

Kenny Billiau, E<lt>kebil@psb.ugent.beE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C)

=cut
