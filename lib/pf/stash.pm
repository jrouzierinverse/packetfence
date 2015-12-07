package pf::stash;

=head1 NAME

pf::stash -

=cut

=head1 DESCRIPTION

pf::stash

=cut

use strict;
use warnings;

our $STASH = pf::stash->new;

BEGIN {
    use Exporter ();
    our ( @ISA, @EXPORT );
    @ISA = qw(Exporter);
    # Categorized by feature, pay attention when modifying
    @EXPORT = qw(add_to_stash);
}

=head2 $stash = pf::stash->new;

=cut

sub new {
    my ($proto) = @_;
    my $class = ref($proto) || $proto;
    my $self = bless {}, $class;
    return $self;
}

=head2 stash

Stash for holding information that needs to pass between calls

=cut

sub stash {
    my ($self, @args) = @_;
    if (@args) {
        my $new_stash = @args > 1 ? {@args} : $args[0];
        croak('stash takes a hash or hashref') unless ref $new_stash;
        foreach my $key ( keys %$new_stash ) {
          $self->{$key} = $new_stash->{$key};
        }
    }

    return $self;
}

sub add_to_stash {
    $STASH->stash(@_);
}


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2015 Inverse inc.

=head1 LICENSE

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301,
USA.

=cut

1;

