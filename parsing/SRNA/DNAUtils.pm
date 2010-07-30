package SRNA::DNAUtils;

sub new {
    my $inv = shift;

    return bless {}, ref $inv || $inv;
}

    sub complement {
        my ($self, $seq_ref) = @_;
        my $seq = ${ $seq_ref };
        $seq =~ tr/('A','T','G','C')/('T','A','C','G')/;
        return \$seq;
    }


    sub full_complement {
        my ($self, $seq_ref) = @_; 
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


1;

__END__

=head1 SYNOPSIS


=head1 METHODS

=head2 Complement

=head1 AUTHOR

Kenny Billiau

