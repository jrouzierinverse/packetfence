package pf::ConfigStore::IniFilesCached::FloatingDevice;

=head1 NAME

pf::ConfigStore::IniFilesCached::FloatingDevice add documentation

=cut

=head1 DESCRIPTION

pf::ConfigStore::IniFilesCached::FloatingDevice;

=cut

use Moo;
use namespace::autoclean;
use pf::file_paths;

extends qw(pf::ConfigStore::IniFilesCached);

has '+configFile' => (default => sub {$floating_devices_config_file}, coerce => sub {$floating_devices_config_file});
has 'storeNameSpace' => ( is => 'rw', default => sub { 'Config::FloatingDevice' } );

=head1 METHODs

=head2 prepareHashForStorage

=cut

sub prepareHashForStorage {
    my ($self, $hash) = @_;
    foreach my $floating_device (values %$hash) {
        if (defined($floating_device->{"trunkPort"})
            && $floating_device->{"trunkPort"} =~ /^\s*(y|yes|true|enabled|1)\s*$/i) {
            $floating_device->{"trunkPort"} = '1';
        }
        else {
            $floating_device->{"trunkPort"} = '0';
        }
    }
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

