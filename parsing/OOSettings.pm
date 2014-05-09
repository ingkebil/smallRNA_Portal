package OOSettings;

use strict;
use warnings;

use constant USER => 'kebil';
use constant PASS => 'kebil';
use constant DB   => 'smallrna_arath';

sub new {
    my $self = shift;
    my $class = ref $self || $self;

    return bless {}, $class;
}

sub get_conds_dirs {
    return {
        arath => {
            dirs => {
                fasta_file => '"$cond_dir/$cond/$cond.unique.fas"', # add the double quotes as these strings get eval'd lateron
                mapp_file  => '"$mapp_dir/$cond/tair9/genome/${cond}_on_genome.100.gff"',
            },
            conds => {
                #smallrna  => [ qw/ P P+3h N N+3h FN FN2 C2 C303 C3h5 / ],
                degradome => [ qw/ D-P D-P12 / ],
            },
        },
        medtr => {
            dirs => {
                fasta_file => '"$cond_dir/$cond/sequences/$cond.unique.fas"', # add the double quotes as these strings get eval'd lateron
                mapp_file  => '"$mapp_dir/$cond/evaluation/mt3/${cond}_on_mt3.100.gff"',
            },
            conds => {
                smallrna => [ qw/ GDN-1 GDN-2 / ],
                degradome => [ qw/ GDN-3 GDN-4 / ],
            },
        }
    };
}

1;

__END__

untested and unused at this moment!
