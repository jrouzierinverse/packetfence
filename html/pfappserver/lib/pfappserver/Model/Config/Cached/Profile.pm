package pfappserver::Model::Config::Cached::Profile;
=head1 NAME

pfappserver::Model::Config::Cached::Profile add documentation

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

sub _buildCachedConfig { $cached_profiles_config }

=item remove

Delete an existing item

=cut

sub remove {
    my ($self,$id) = @_;
    if($id eq 'default') {
        return ($STATUS::INTERNAL_SERVER_ERROR, "Cannot delete this item");
    }
    return $self->SUPER::remove($id);
}
=item cleanupAfterRead

Clean up switch data

=cut

sub cleanupAfterRead {
    my ( $self,$id, $profile ) = @_;
    my $logger = Log::Log4perl::get_logger(__PACKAGE__);
    $self->expand_list($profile, qw(guest_modes));
}

=item cleanupBeforeCommit

Clean data before update or creating

=cut

sub cleanupBeforeCommit {
    my ( $self,$id, $profile ) = @_;
    my $logger = Log::Log4perl::get_logger(__PACKAGE__);
    $self->flatten_list($profile, qw(guest_modes));

}

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

