package SRNA::DBAbstract;

use strict;
use warnings;
use DBI;
use Data::Dumper;

sub new {
    my $inv = shift;
    my $settings = shift;
    my $dbh      = $settings->{ dbh }  || die "A DB handler really is needed to connect to a DB!";
    my $table    = $settings->{ table } || die "A table to bind to really is needed!";

    my $class    = ref $inv || $inv;

    my $self = {
        dbh => $dbh,
        table => $table,
        last_insert_id => 0,
        ids => {},
        new_rows => [],
    };

    return bless $self, $class;
}

sub reset_cache {
    my $self = shift;
    $self->{ last_insert_id } = 0;
    $self->{ ids } = {};
}

sub get_id {
    my $self  = shift;
    my $col   = shift;
    my $value = shift;

    if (exists $self->{ ids }->{ $col }->{ $value }) {
        return $self->{ ids }->{ $col }->{ $value };
    }

    my $rs = $self->{ dbh }->selectcol_arrayref("SELECT id FROM $self->{ table } WHERE $col = ?", { MaxRows => 1 }, ( lc($value) ));

    if (! scalar @$rs) {
        return undef;
    }
    else {
        $self->cache_add_id($col, $value, $rs->[ 0 ]);
        return $rs->[ 0 ];
    }
}

sub get_next_id {
    my $self = shift;

    if (!$self->{ last_insert_id }) {
        $self->{ last_insert_id } = $self->{ dbh }->selectrow_arrayref("SELECT max(id) FROM `$self->{table}`")->[0];
    }

    return ++$self->{ last_insert_id };
}

sub get_cur_id {
    my $self = shift;

    return $self->{ last_insert_id };
}

sub add {
    my $self = shift;
    my $values = shift;

    my $new_id = $self->get_next_id();
    $values->{ id } = $new_id;
    push @{ $self->{ new_rows } }, $values;

    while (my ($name, $val) = each %$values) {
        $self->cache_add_id($name, $val, $new_id); # as we don't know how we'll later query for the id, add all combo's
    }

    return $new_id;
}

sub get_new_rows {
    my $self = shift;

    return $self->{ new_rows };
}

sub get_new_rows_CSV {
    my $self = shift;
    my @order = @_;

    if (! @order ) {
        return $self->{ new_rows };
    }
    my @new_rows = ();
    foreach my $row (@{ $self->{ new_rows } }) {
        my @new_row = ();
        foreach my $col (@order) {
            push @new_row, $row->{ $col };
        }
        push @new_rows, join "\t", @new_row;
    }

    return \@new_rows;
}

sub cache_add_id {
    my $self = shift;
    my $col  = shift;
    my $val  = shift;
    my $id   = shift;

    return $self->{ ids }->{ $col }->{ $val } = $id;
}

1;

__END__
