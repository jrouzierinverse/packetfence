package pf::validation::floating_device;

=head1 NAME

pf::validation::floating_device -

=head1 DESCRIPTION

pf::validation::floating_device

=cut

use strict;
use warnings;

sub new {
    my ($proto) = @_;
    my $class = ref($proto) || $proto;
    return bless({}, $class);
}

sub validate {
    my ($self, $data) = @_;
    my $fields = $self->fields;
    my @errors;
    for my $field (@$fields) {
        my $name = $field->{name};
        if ($field->{required}) {
            
        }
    }
}

sub inflate {

}

sub deflate {

}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2019 Inverse inc.

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

