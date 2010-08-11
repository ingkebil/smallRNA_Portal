package SRNA::Normabun;

use strict;
use warnings;
use DBI;
use Pod::Usage;
use Getopt::Long;
use Smart::Comments;
use Settings qw/:DB/;

&run() unless caller();

my $dbi = undef;

sub run {
    my ($user, $pass, $db) = q{};
    my ($exp_id, $writebuffer) = 0;
    my $opts = GetOptions(
        user => \$user,
        pass => \$pass,
        db   => \$db ,
        'exp-id:i' => \$exp_id,
        writebuffer => \$writebuffer,
    );
    my $path = $ARGV[0];

    $user ||= USER;
    $pass ||= PASS;
    $db   ||= DB;

    $dbi = DBI->connect("dbi:mysql:database=$db", $user, $pass);

    my $total_ab = &get_ab_count($exp_id);
    ### Totalabun: $total_ab

    # following block of code parses the GFF file in chuncks to prevent out of memory errors :)
    $writebuffer ||= 300_000;
    my $i = 0;
    my $j = 0;
    my @return = ();
    foreach my $srna (@{ &get_abs($exp_id) }) { ### Making output [%]
        my $norm_ab = $srna->[ 1 ] * 1_000_000 / $total_ab;
        push @return, "UPDATE srnas SET normalized_abundance = $norm_ab WHERE id = $srna->[0];";
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

    &fprint("$path/normabun.$suff.sql", join "\n", @$results );
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

sub get_abs {
    my $exp_id = shift;

    return $dbi->selectall_arrayref(q{ SELECT id, abundance FROM `srnas` WHERE experiment_id = ? }, {}, ($exp_id));
}

sub get_ab_count {
    my $exp_id = shift;

    my $rs = $dbi->selectrow_arrayref(q{ SELECT count(abundance) FROM `srnas` WHERE experiment_id = ? }, {}, ($exp_id));

    if (defined $rs) {
        return $rs->[0];
    }

    return undef;
}

1;

__END__

=head1 SYNOPSIS
