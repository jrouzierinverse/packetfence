package pfappserver::Model::Config::Cached::FloatingDevice;
=head1 NAME

pfappserver::Model::Config::Cached::FloatingDevice add documentation

=cut

=head1 DESCRIPTION

pfappserver::Model::Config::Cached::Profile

=cut

use Moose;
use namespace::autoclean;
use pf::config::cached;
use pf::config;

extends 'pfappserver::Base::Model::Config::Cached';


=head2 Methods

=over

=item _buildCachedConfig

=cut

sub _buildCachedConfig {
    my ($self) = @_;
    return pf::config::cached->new(-file => $pf::config::floating_devices_config_file);
}

#=item remove
#
#Delete an existing item
#
#=cut
#
#sub remove {
#    my ($self,$id) = @_;
#    if($id eq 'default') {
#        return ($STATUS::INTERNAL_SERVER_ERROR, "Cannot delete this item");
#    }
#    return $self->SUPER::remove($id);
#}

#=item cleanupAfterRead
#
#=cut
#
#sub cleanupAfterRead {
#    my ( $self,$id, $switch ) = @_;
#}
#
#=item cleanupBeforeCommit
#
#=cut
#
#sub cleanupBeforeCommit {
#    my ( $self, $id, $switch ) = @_;
#}

__PACKAGE__->meta->make_immutable;

=back

=head1 COPYRIGHT

Copyright (C) 2013 Inverse inc.

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

