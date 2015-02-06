package pfappserver::Authentication::Credential::Proxy;

=head1 NAME

pfappserver::Authentication::Credential::Proxy -

=cut

=head1 DESCRIPTION

pfappserver::Authentication::Credential::Proxy

=cut

use strict;
use warnings;
use Moose;
use namespace::autoclean;
use pfappserver::Authentication::Store::PacketFence::User;
use pf::authentication;
use List::Util qw(first);

has realm => (is => 'rw');
has _config => (is => 'rw');

sub BUILDARGS {
    my ($class, $config, $app, $realm) = @_;

    return { _config => $config, realm => $realm};
}

sub authenticate {
    my ($self, $c, $realm, $authinfo) = @_;

    #Find the first AdminProxy if none reject
    my @sources = grep { $_->{type} eq 'AdminProxy' } @{getAllAuthenticationSources()};
    return unless @sources;
    my $request = $c->req;
    my $address = $request->address;
    my $headers = $request->headers;
    #Use the address headers as the username and password refactor this to just pass a hash instead authenticate({},@sources)
    my ($result, $message, $source_id) = &pf::authentication::authenticate($address, $headers, @sources);
    unless ($result) {
        $c->log->debug(sub { "Unable to authenticate in realm " . $realm->name . " Error $message" });
        return;
    }
    my $source = getAuthenticationSource($source_id);
    my $username = $source->getUserFromHeader($headers);
    my $group = $source->getGroupFromHeader($headers);
    my $value = &pf::authentication::match($source_id, {username => $username, group_header => $group}, $Actions::SET_ACCESS_LEVEL);
    # No roles found cannot login
    return unless $value;
    my $roles = [split /\s*,\s*/,$value] if defined $value;
    $c->session->{user_roles} = $roles;
    my $user = $realm->find_user( { username => $username }, $c  );
    return $user;
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

