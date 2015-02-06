package pfappserver::Controller::Admin;

=head1 NAME

pfappserver::Controller::Admin - The customizable

=head1 DESCRIPTION

=cut

use Moose;
use pfappserver::Authentication::Store::PacketFence::User;

BEGIN { extends 'pfappserver::PacketFence::Controller::Admin'; }

=head1 METHODS

=head2 auto

Allow only authenticated users

=cut

sub auto :Private {
    my ($self, $c, @args) = @_;

    # Make sure the 'enforcements' session variable doesn't exist as it affects the Interface controller
    delete $c->session->{'enforcements'};
    #The configurator user is not allowed to access the admin admin
    if($c->user_in_realm('configurator')) {
        $c->logout( );
        $c->delete_session();
    }

    unless ($c->action->name eq 'login' || $c->action->name eq 'logout' || $c->user_exists || $c->authenticate({}, 'proxy') ) {
        $c->stash->{'template'} = 'admin/login.tt';
        unless ($c->action->name eq 'index') {
            $c->stash->{status_msg} = $c->loc("Your session has expired.");
            $c->stash->{'redirect_action'} = $c->uri_for($c->action, @args);
        }
        $c->delete_session();
        $c->detach();
        return 0;
    }

    return 1;
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

__PACKAGE__->meta->make_immutable;

1;
