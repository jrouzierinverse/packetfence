package captiveportal::Controller::Eduroam;
=head1 NAME

captiveportal::Controller::Eduroam add documentation

=cut

=head1 DESCRIPTION

captiveportal::Controller::Eduroam

=cut

use strict;
use warnings;
use Moose;
BEGIN { extends 'captiveportal::Base::Controller'; }

our $EDUROAM_SOURCE = 'eduroam';

=head2 index

index

=cut

sub index : Path : Args(0) {
    my ( $self, $c ) = @_;
    $c->stash->{template} = 'eduroam.html';
}

=head2 login

Template variable txt_auth_error on auth error 

=cut

sub login : Local : Args(0) {
    my ($self, $c) = @_;
    my $request  = $c->request;
    my $username = $request->param("username");
    my $password = $request->param("password");
    if (   defined $username && $username ne '' && defined $password && $password ne '') {
        $c->forward('authenticationLogin');
        if ($c->has_errors) {
            $c->stash->{txt_auth_error} = join(' ', grep { ref ($_) eq '' } @{$c->error});
            $c->clear_errors;
            $c->delete_session;
        }
    }
    $c->forward('index');
}


sub authenticationLogin : Private {
    my ( $self, $c ) = @_;
    my $logger  = $c->log;
    my $session = $c->session;
    my $request = $c->request;
    my $profile = $c->profile;
    my $portalSession = $c->portalSession;
    my $mac           = $portalSession->clientMac;
    my @sources = (pf::authentication::getAuthenticationSource($EDUROAM_SOURCE));

    my $username = $request->param("username");
    my $password = $request->param("password");

    # validate login and password
    my ( $return, $message, $source_id ) =
      pf::authentication::authenticate( $username, $password, @sources );
    if ( defined($return) && $return == 1 ) {
        # save login into session
        $c->session->{"username"} = $username;
        $c->session->{source_id} = $source_id;
    } else {
        $c->error($message);
    }
}
 
=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2014 Inverse inc.

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

