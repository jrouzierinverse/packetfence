package pf::ConfigStore::IniFilesCached::Realm;

=head1 NAME

pf::ConfigStore::IniFilesCached::Realm

=cut

=head1 DESCRIPTION

pf::ConfigStore::IniFilesCached::Realm;

=cut

use Moo;
use namespace::autoclean;
use pf::file_paths;

extends qw(pf::ConfigStore::IniFilesCached);

has '+configFile' => (default => sub {$realm_config_file}, coerce => sub {$realm_config_file});
has '+storeNameSpace' => (default => sub {'Config::Realm'}, coerce => sub {'Config::Realm'});

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

