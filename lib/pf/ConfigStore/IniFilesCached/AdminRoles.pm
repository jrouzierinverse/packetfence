package pf::ConfigStore::IniFilesCached::AdminRoles;

=head1 NAME

pf::ConfigStore::IniFilesCached::AdminRoles

=cut

=head1 DESCRIPTION

pf::ConfigStore::IniFilesCached::AdminRoles;

=cut

use Moo;
use namespace::autoclean;
use pf::file_paths;
use pf::constants::admin_roles;

extends qw(pf::ConfigStore::IniFilesCached);

has '+configFile' => (default => sub {$admin_roles_config_file}, coerce => sub {$admin_roles_config_file});
has '+storeNameSpace' => (default => sub {'Config::AdminRoles'}, coerce => sub {'Config::AdminRoles'});

=head2 prepareHashForStorage

=cut

sub prepareHashForStorage {
    my ( $self, $hash ) = @_;

    foreach my $data (values %$hash) {
        my $actions = $data->{actions} || '';
        my %action_data = map {$_ => undef} split /\s*,\s*/, $actions;
        $data->{ACTIONS} = \%action_data;
    }
    $hash->{NONE}{ACTIONS} = { };
    $hash->{ALL}{ACTIONS} = { map {$_ => undef} @ADMIN_ACTIONS };
}

__PACKAGE__->meta->make_immutable;

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

