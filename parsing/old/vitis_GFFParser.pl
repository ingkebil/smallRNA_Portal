#!/usr/bin/perl

use FindBin qw{$Bin};
use lib '$Bin/../../modules';
use PLAZA;
use strict;
use warnings;
use Data::Dumper;
use Smart::Comments;
use Getopt::Long;
use Pod::Usage;
use PLAZA::XML::XPathParserChecker;
use PLAZA::PLAZA_utils;

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
my $names_table = q{};

# Holds fasta data
my %transcripts;
my %proteins;
my %chromosomes;
my %names;

# get the options
my $options_ok = GetOptions(
    'input|i=s' => \$gff_filename,
    'output|o=s' => \$csv_filename,
    'tr-filename|t=s' => \$tr_filename,
    'pep-filename|p=s' => \$pep_filename,
    'genome-filename|g=s' => \$genome_filename,
    'names_table|n=s' => \$names_table,
    
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
#my $tr_filename = '/home/sepro/plazadata/vitis/vitis_transcripts_06092007.fa'; | sepro: just here as reference, pass this file through command line
#my $pep_filename   = '/home/sepro/plazadata/vitis/vitis_peptides_06092007.fa';
#my $genome_filename = '/home/sepro/plazadata/vitis/vitis_full_genome_06092007.fasta';

my $species = 'vvi'; # the species PLAZA name | sepro: changed from popular tree parser
my $source_key = '4'; # the source key in the PLAZA db | sepro: changed form popular tree parser + added this id in db
my $transcript_nr = '.1'; # the default transcript nr
my $gene_type = 'coding'; # the default gene type

my %exons_of = (); # where to store the exons of each gene in

my $chr; #the chromosome name
my $chr_nr; #the chromosome number

&set_id_regex({ 'regex' => '>(.*)', 'filename' => $pep_filename});
&set_id_regex({ 'regex' => '>(.*)', 'filename' => $genome_filename});

# first step, parse the gff file into something we can work with

LINE:
while (<GFFFILE>)
{
	chomp;
	my @split_line = split /\t/;
	
	$chr = $split_line[0];
	#next LINE if $chr !~ m/random/; #ignore random stuff
	next LINE if !($split_line[2] =~ m/cds/i || $split_line[2] =~ m/utr/i); #only use utr en cds
	#next LINE if ($split_line[8] !~ m/GSVIVT00000001001/); #debug use only 1 gene
	
	#we can use this line, move on
	
	$chr_nr = $chr;
	
	if ($chr !~ m/random/)
	{
		$chr_nr =~ s/\D*//; #cut text, only leaves the number
		$chr_nr = $chr_nr <= 9 ? "0$chr_nr" : "$chr_nr";
	}
	
	$split_line[8] =~ m/(GSVIVT\d*)/;
	my $transcript_id = $1;
	my $protein_id = $transcript_id;
	$protein_id =~ s/GSVIVT/GSVIVP/;
	
	my $exon_ref = {
		'prot_id' => $protein_id,
		'tr_id'   => $transcript_id, 
		'start'   => $split_line[3],
		'stop'    => $split_line[4],
		'strand'  => $split_line[6],
		'cds'     => $split_line[2] =~ m/cds/i ? 1 : 0,
		'desc'    => $transcript_id,			#sepro: id is hier ook beschrijving
		'chr'     => $chr,
		'chr_nr'  => $chr_nr,
		'phase'   => $split_line[7],
    };
	
    # add them to the general hash ..
    if (!defined $exons_of{ $transcript_id }) {
        $exons_of{ $transcript_id } = [];
    }
    push @{ $exons_of{ $transcript_id } }, $exon_ref;
		
}

my @keys = keys %exons_of;
my $size = @keys;
printf STDERR ("Found %d genes\n",  $size);

close GFFFILE;

#Load transcripts & proteins & genome perform tests

printf STDERR ("Reading transcripts $tr_filename\n");
open(TR_FILE,'<' . $tr_filename);

my $current_transcript = '';

while (<TR_FILE>)
{
	chomp;
	if (m/^>(GSVIVT\d*)/)
	{
		$current_transcript = $1;
	}
	else
	{
		if (!defined $transcripts{ $current_transcript })
		{
			$transcripts{ $current_transcript } = $_;
		}
		else
		{
			$transcripts{ $current_transcript } = $transcripts{ $current_transcript } . $_;
		}
	}
	
}

close TR_FILE;

printf STDERR ("Reading genome $genome_filename\n");

my %chroms = ();
my @chrom_names = @{ &get_all_fasta_id({ 'filename' => $genome_filename }) };
foreach my $chrom_name (@chrom_names) {
		$chroms{ $chrom_name } = &get_seq({ 'id' => $chrom_name, 'filename' => $genome_filename});
		#printf STDERR ("Reading chromosome: %s\n", $chrom_name);
}

#Do tests

my $error_count = 0;

#check is lenght from combined CDS sequences is equal to transcript length
#if not raise an error message

foreach my $key (keys %exons_of)
{
	my $cds_length= 0;
	my $transcript_length = 0;
	foreach my $exon (@{$exons_of{$key}})
	{
		if ($exon->{'cds'} == 1)
		{
			$cds_length = $cds_length + abs($exon->{'stop' } - $exon->{'start'}) + 1;
		}
	}
	
	if (defined $transcripts{$key})
	{
		$transcript_length = length $transcripts{$key};
	}
	if (!($cds_length == $transcript_length))
	{
		#printf STDERR ("Difference in length of CDS and transcript: %s %d %d\n", $key, $cds_length,$transcript_length);
		$error_count++;
	}
}	

printf STDERR ("Found %d transcripts with wrong length.\n", $error_count);

open(NAMES,'<' . $names_table);

while (<NAMES>)
{
	chomp;
	my @split_lines = split /\t/;
	
	$names{$split_lines[0]} = $split_lines[1];
	
}

close NAMES;

foreach my $key (keys %exons_of) 
{	
	my $genomesequence = "";
	my $tr_id = "";
	my @comments = ();
	my @coords_out = ();
	my $cds_coords = '';
	my @coords_out_tr = ();
	my $tr_coords = '';
	my $complement = 0;
	my $start = 1000000000000000; #really large number
	my $stop = 0;
	my $strand;
	my $chr;


	my @sorted_exons = sort {$a->{'start'} <=> $b->{'start'}} @{$exons_of{$key}};
	
	foreach my $exon (@sorted_exons)
	{
		$strand = $exon->{'strand'};
		$chr = $exon->{'chr'};
		if ($strand eq '-' || $complement eq 1)
		{
			$complement = 1;
		}
		if ($exon->{'cds'} eq 1)
		{
			my $temp = substr $chroms{$exon->{'chr'}}, $exon->{ 'start' }-1, (($exon->{ 'stop' } - $exon->{ 'start' }) + 1);
			$genomesequence = $genomesequence . $temp;
			my $segment = "$exon->{ 'start' }" . ".." . "$exon->{ 'stop' }";
			push (@coords_out, $segment);
			push (@coords_out_tr, $segment);
			if ($exon->{ 'start' }  < $start)
			{
				$start = $exon->{ 'start' };
			}
			if ($exon->{ 'stop' }  > $stop)
			{
				$stop = $exon->{ 'stop' };
			}			
		}
		else
		{
			my $segment = "$exon->{ 'start' }" . ".." . "$exon->{ 'stop' }";
			push (@coords_out_tr, $segment);
		}
		$tr_id = $exon->{'tr_id'};
		#printf ("%s\t%d\t%d -> %d\n", $key,$exon->{'cds'}, $exon->{ 'start' },$exon->{ 'stop' });
	}
	
	$cds_coords = join ',', @coords_out;
	$tr_coords = join ',', @coords_out_tr;
	
	$cds_coords = "join(" . $cds_coords . ")";
	$tr_coords = "join(" . $tr_coords . ")";
	
	if ($complement eq 1)
	{
		$cds_coords = "complement(" . $cds_coords . ")";
		$tr_coords = "complement(" . $tr_coords . ")";
		$genomesequence = ${ &_full_complement(\$genomesequence) };
		$genomesequence = reverse $genomesequence;
		push @comments, "compl=1";
	}
	
	if ($genomesequence ne $transcripts{$tr_id}) 
	{
		push @comments, "transcript=ne";
	}
	else
	{
		push @comments, "tid=".$tr_id;	
	}
			my $pep_id = $tr_id;
			$pep_id =~ s/GSVIVT/GSVIVP/;
			
			my $check_pep = &check_pep_vitis({ 'pep_filename' => $pep_filename, 'cds_seq_ref' => \$genomesequence, 'full_gene_id' => $pep_id });
			
			if ($check_pep > 0)
			{
				push @comments, "prot=eq";
				push @comments, "pid=".$pep_id;
				if ($check_pep == 2) {
                    			push @comments, 'stops=1';
				}
			}
			else
			{
				if ($check_pep == 0)
				{
					push @comments, "prot=none";
				}
				else
				{
					push @comments, "prot=ne";

				}
			}
	
	my $gene_id = $key;
	$gene_id =~ s/GSVIVT/GSVIVG/;
	my $new_gene_id = $names{$gene_id};
	if (not defined $new_gene_id)
	{
		#should not happen but check anyway
		$new_gene_id = $gene_id;
	}
	
    &print_plaza_format({
        'gene_id'       => $new_gene_id,
        'species'       => $species,
        'transcript_nr' => $new_gene_id . $transcript_nr,
        'cds_coords'    => $cds_coords,
        'start'         => $start,
        'stop'          => $stop,
        'tr_coords'     => $tr_coords,
        'seq'           => $genomesequence,
        'strand'        => $strand,
        'chr'           => $chr,
        'gene_type'     => 'coding',
        'go_codes'      => 'NULL',
        'desc'          => 'NULL',
        'comment'       => join(q{;}, @comments),
        'source_key'    => $source_key,
        'csv_fh'        => *CSVFILE,
    });


}


__END__

=head1 NAME

vitis_GFFParser.pl - Parses the Vitis GFF file into a PLAZA csv format for the db.

=head1 SYNOPSIS

./vitis_GFFParser.pl -i poptr.gff -o annotation.csv 
               -t transcripts.fasta
               -p peptides.fasta
               -g genome.fasta
               -n names.list
  
=head1 DESCRIPTION

First parses the Vitis GFF file into a useable hash format. It groups the exons of a
gene on the 'name' attribute in attribute column of the GFF file.

Hereafter the genes are sorted according to chromosome and coordinates. An
internal gene_id will be given to each gene. This is obtained from a lookup table in
the names.list

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
  If it is equal, it will be noted with ''.
  If no protein is found it will be noted with 'prot=none'.
 
=head1 ARGUMENTS

  none

=head1 OPTIONS

  -i, --input       : The input GFF file. This must be valid GFF3.
  -o, --output      : The name of the CSV file to output.
  -t, --tr-filename : The name of the fasta file with the transcript
                      sequences.
  -p, pep-filename  : The name of the fasta file with the peptide sequences.
  -g, seq-filename  : The name of the fasta file with the sequence of the
                      chromosome.
  -nm names-list	: The name of the file with a conversion table for the 
  					  names, this list can be generated with new_gene_id_vitis.pl
  -u, --usage       : Print this.
  -h, --help        : Print the help.


=head1 SEE ALSO

GFF3: http://www.sanger.ac.uk/Software/formats/GFF/GFF_Spec.shtml

=head1 AUTHOR

Kenny Billiau, E<lt>kebil@psb.ugent.beE<gt>
Sebastian Proost, E<lt>sepro@psb.ugent.beE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Francis Dierick

=cut
