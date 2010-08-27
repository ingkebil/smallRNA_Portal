package SRNA::Correct_rev_compl;

use strict;
use warnings;
use DBI;
use Pod::Usage;
use Getopt::Long;
use Smart::Comments;
use Settings qw/:DB/;
use SRNA::DNAUtils;

&run() unless caller();

my $dbi = undef;

sub run {
    my ($user, $pass, $db) = q{};
    my ($exp_id, $writebuffer) = 0;
    my $opts = GetOptions(
        user => \$user,
        pass => \$pass,
        db   => \$db ,
        writebuffer => \$writebuffer,
    );
    my $path = $ARGV[0];

    $user ||= USER;
    $pass ||= PASS;
    $db   ||= DB;

    $dbi = DBI->connect("dbi:mysql:database=$db", $user, $pass);

    my $utils = new SRNA::DNAUtils;

    # following block of code parses the GFF file in chuncks to prevent out of memory errors :)
    $writebuffer ||= 300_000;
    my $i = 0;
    my $j = 0;
    my @return = ();
    foreach my $annot (@{ &get_seqs() }) { ### Making output [%]
        my $seq = reverse $annot->[1];
        $seq = ${ $utils->full_complement(\$seq) };
        push @return, "UPDATE annotations SET seq = '$seq' WHERE id = $annot->[0];";
        $i++;
        if ($i == $writebuffer) {
            &export_to_CSV(\@return, $path, ++$j); # export to file

            @return = ();
            $i = 0;
        }
    }
    if (@return) { 
        &export_to_CSV(\@return, $path, ++$j); # export to file
    }
    ### tried $j times ...
}


sub export_to_CSV {
    my $results = shift;
    my $path = shift;
    my $suff = shift;

    &fprint("$path/seq_rev_compl.$suff.sql", join "\n", @$results );
}

sub fprint {
    my $file = shift;
    my $content = shift;

    if (open(FF, '>', $file)) {
        print FF $content;
        close FF;
    }
    else {
        warn "Failed to write to $file!";
    }
}

sub get_seqs {
    return $dbi->selectall_arrayref(q{ SELECT id, seq FROM `annotations` WHERE strand = '-' });
}

1;

__END__

=head1 SYNOPSIS

Oops. I forgot to reverse complement the negative strand for the annotations!
