package PLAZA::XML::XPathParserPost;

use strict;
use warnings;
use Data::Dumper;
use Smart::Comments;

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
is_transposon
);

our $VERSION = '0.01';

# Preloaded methods go here.

# Comments : prepend internal methods with _
{

    my %transposon_of;

    sub is_transposon {
        my ($in_ref) = @_;

        my $filename = $in_ref->{ 'filename' };
        my $gene_id  = $in_ref->{ 'full_gene_id' };

        if (!%transposon_of) {
            &_read_transposon_file($filename);
        }

        if (exists $transposon_of{ $gene_id }) {
            return 1;
        }
        else {
            return 0;
        }
    }

    sub _read_transposon_file {
        my ($filename) = @_;

        open(TRANSPOSON, $filename) or die ("Cannot open $filename");

        my $gene_id = q{};
        while(my $line = <TRANSPOSON>) {
            chomp($line);
            my @split_line = split /\s+/, $line;
            $line = uc($split_line[2]);
            ($gene_id = $line) =~ s/LOC_(([A-Z]{2}[0-9]{1,2}[GMC][0-9]{5}(\.[0-9]{1,2}))|(TRF[0-9]{7})).*/$1/;
            $transposon_of{ $gene_id } = 1;
        }
        #print Dumper \%transposon_of;
    }

}

1;
