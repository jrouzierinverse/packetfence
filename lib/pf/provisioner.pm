package pf::provisioner;
=head1 NAME

pf::provisioner add documentation

=cut

=head1 DESCRIPTION

pf::provisioner

=cut

use strict;
use warnings;
use Module::Pluggable search_path => __PACKAGE__, sub_name => 'provisioners' , require => 1;
use List::MoreUtils qw(any);
use pf::ConfigStore::Provisioning;

my @PROVISIONERS = __PACKAGE__->provisioners;

sub new {
    my ($class,$name) = @_;
    my $provisioner;
    my $configStore = pf::ConfigStore::Provisioning->new;
    my $data = $configStore->read($name,'id');
    if ($data) {
        my $type = $data->{type};
        die "type is not defined for $name" unless defined $type;
        my $subclass = "${class}::${type}";
        die "$type is not a valid type" unless any { $_ eq $subclass  } @PROVISIONERS;
        $provisioner = $subclass->new($data);
    }
    return $provisioner;
}


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2013 Inverse inc.

=head1 LICENSE

This program is free software; you can redistribute it and::or
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

