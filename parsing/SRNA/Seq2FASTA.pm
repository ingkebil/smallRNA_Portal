#!/usr/bin/perl
package SRNA::Seq2FASTA;

use strict;
use warnings;
use Settings qw/:DB/;
use DBI;
use Smart::Comments;

&run() unless caller();

sub run {
    new SRNA::Seq2FASTA()->get_seqs(\&fprint);
}

sub new {
    my $inv = shift;
    my $class = ref $inv || $inv;

    my $db = shift || DB;
    my $user = shift || USER;
    my $pass = shift || PASS;

    my $dbi = DBI->connect('dbi:mysql:database='.$db, $user, $pass);

    return bless { 
        dbi => $dbi,
        writebuffer => 1_000_000,
    }, $class;
}

sub get_seqs {
    my $self = shift;
    my $callback = shift; # what to do with the collected results?

    ### Executing the query ...
    my $sth = $self->{ dbi }->prepare('SELECT s.id, seq, srnas.id FROM sequences s JOIN srnas ON s.id = srnas.sequence_id');
    my $rs  = $sth->execute();

    my $i = 0; # resulset counter
    my $j = 0; # buffer iteration counter
    my $structs = {}; # { id => { ids => [], seq => 'acgt' } }

    ### Building the struct ...
    while (my $row = $sth->fetchrow_arrayref()) {
        if (! exists $structs->{ $row->[0] }) {
            $structs->{ $row->[0] } = { seq => q{}, ids => []};
        }
        $structs->{ $row->[0] }->{ seq } = $row->[1];
        push @{  $structs->{ $row->[0] }->{ ids }  },  $row->[2];

        $i++;
        print "$i\r"; # some sign that the program is working
        if ($i == $self->{ writebuffer }) {
            $j++;
            &$callback("/home/billiau/tmp/arath/seq2fasta.$j", $structs);
            #$self->fprint('~/tmp/arath/seq2fasta',  $self->make_fasta($structs)); # replace by callback
            $structs = {};
            $i = 0;
            print "\n";
        }
    }
    $j++;
    &$callback("/home/billiau/tmp/arath/seq2fasta.$j", $structs);
    #$self->fprint('~/tmp/arath/seq2fasta',  $self->make_fasta($structs));
}

sub fprint {
    #my $self = shift;
    my $file = shift;
    my $content = shift;

    $content = join "\n", @{ &make_fasta($content) };

    if (open(FF, '>', $file)) {
        print FF $content;
        close FF;
    }
    else {
        warn "Failed to write to $file!";
    }
}

sub make_fasta {
    # my $self = shift; # this ain't part of this class, it's a callback function
    my $structs = shift;

    my @lines = ();
    while (my ($seq_id, $struct) = each %$structs) {
        push @lines, '>'.$seq_id.' | '.join q{, }, @{ $struct->{ ids } };
        push @lines, $struct->{ seq };
    }

    return \@lines;
}



1;

__END__

=head1 SYNOPSIS

Used to dump the sequences table into a multi fasta file. This file could then be used to create a custom blast database to help improve string searching.

The format of the header of the multifasta file is:
> sequence_id | srna_id [, srna_id[, srna_id]]
