package pfappserver::Controller::Configuration;

=head1 NAME

pfappserver::Controller::Configuration - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=cut

use strict;
use warnings;

use Date::Parse;
use HTTP::Status qw(:constants is_error is_success);
use Moose;
use namespace::autoclean;
use POSIX;
use URI::Escape;

use pf::authentication;
use pf::os;
use pf::util qw(load_oui download_oui);
# imported only for the $TIME_MODIFIER_RE regex. Ideally shouldn't be
# imported but it's better than duplicating regex all over the place.
use pf::config;
use pfappserver::Form::Config::Pf;

BEGIN {extends 'pfappserver::Base::Controller::Base'; }

=head1 METHODS

=cut

=head2 _process_section

=cut

sub _process_section :Private {
    my ($self, $c) = @_;
    my $section = $c->action->name;
    my ($params, $form);

    $c->stash->{section} = $section;
    $c->stash->{template} = 'configuration/section.tt';

    my $model = $c->model('Config::Cached::Pf')->new;
    $model->readConfig();

    if ($c->request->method eq 'POST') {
        $form = pfappserver::Form::Config::Pf->new(ctx => $c,
                                                   section => $section);
        $form->process(params => $c->req->params);
        if ($form->has_errors) {
            $c->response->status(HTTP_BAD_REQUEST);
            $c->stash->{status_msg} = $form->field_errors; # TODO: localize error message
        }
        else {
            $model->update($section, $form->value);
            $model->rewriteConfig();
        }
    }
    else {
        my ($status,$params) = $model->read($section);
        $form = pfappserver::Form::Config::Pf->new(
            ctx => $c,
            section => $section
        );
        $form->process(init_object => $params);
        $c->stash->{form} = $form;
    }
}

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    $c->response->redirect($c->uri_for($c->controller('Configuration')->action_for('general')));
    $c->detach();
}

=head2 general

=cut

sub general :Local {
    my ($self, $c) = @_;

    $self->_process_section($c);
}

=head2 network

=cut

sub network :Local {
    my ($self, $c) = @_;

    $self->_process_section($c);
}

=head2 trapping

=cut

sub trapping :Local {
    my ($self, $c) = @_;

    $self->_process_section($c);
}

=head2 registration

=cut

sub registration :Local {
    my ($self, $c) = @_;

    $self->_process_section($c);
}

=head2 guests_self_registration

=cut

sub guests_self_registration :Local {
    my ($self, $c) = @_;

    $self->_process_section($c);
}

=head2 billing

=cut

sub billing :Local {
    my ($self, $c) = @_;

    $self->_process_section($c);
}

=head2 alerting

=cut

sub alerting :Local {
    my ($self, $c) = @_;

    $self->_process_section($c);
}

=head2 scan

=cut

sub scan :Local {
    my ($self, $c) = @_;

    $self->_process_section($c);
}

=head2 expire

=cut

sub expire :Local {
    my ($self, $c) = @_;

    $self->_process_section($c);
}

=head2 services

=cut

sub services :Local {
    my ($self, $c) = @_;

    $self->_process_section($c);
}

=head2 vlan

=cut

sub vlan :Local {
    my ($self, $c) = @_;

    $self->_process_section($c);
}

=head2 inline

=cut

sub inline :Local {
    my ($self, $c) = @_;

    $self->_process_section($c);
}

=head2 servicewatch

=cut

sub servicewatch :Local {
    my ($self, $c) = @_;

    $self->_process_section($c);
}

=head2 captive_portal

=cut

sub captive_portal :Local {
    my ($self, $c) = @_;

    $self->_process_section($c);
}

=head2 advanced

=cut

sub advanced :Local {
    my ($self, $c) = @_;

    $self->_process_section($c);
}

=head2 provisioning

=cut

sub provisioning :Local {
    my ($self, $c) = @_;

    $self->_process_section($c);
}

=head2 interfaces

=cut

sub interfaces :Local {
    my ($self, $c) = @_;

    $c->go('Controller::Interface', 'index');
}

=head2 switches

=cut

sub switches :Local {
    my ($self, $c) = @_;

    $c->go('Controller::Configuration::Switch', 'index');
}

=head2 floating_devices

=cut

sub floating_devices :Local {
    my ($self, $c) = @_;

    $c->go('Controller::Configuration::FloatingDevice', 'index');
}

=head2 authentication

=cut

sub authentication :Local {
    my ($self, $c) = @_;

    $c->go('Controller::Authentication', 'index');
}

=head2 users

=cut

sub users :Local {
    my ($self, $c) = @_;

    $c->go('Controller::User', 'create');
}

=head2 violations

=cut

sub violations :Local {
    my ( $self, $c ) = @_;

    $c->stash->{template} = 'configuration/violations.tt';

    my ($status, $result) = $c->model('Config::Violations')->read_violation('all');
    if (is_success($status)) {
        $c->stash->{violations} = $result;
        ($status, $result) = $c->model('Config::Cached::Profile')->readAllIds();
        if (is_success($status)) {
            $c->stash->{profiles} = ['default',@$result];
        }
    }
    else {
        $c->response->status($status);
        $c->stash->{status_msg} = $result;
        $c->stash->{current_view} = 'JSON';
    }
}

=head2 soh

=cut

sub soh :Local {
    my ( $self, $c ) = @_;

    $c->stash->{template} = 'configuration/soh.tt';

    my ($status, $result) = $c->model('SoH')->filters();
    if (is_success($status)) {
        $c->stash->{filters} = $result;

        ($status, $result) = $c->model('Config::Violations')->read_violation('all');
        if (is_success($status)) {
            $c->stash->{violations} = $result;
        }
    }
    if (is_error($status)) {
        $c->stash->{error} = $result;
    }
}

=head2 roles

=cut

sub roles :Local {
    my ( $self, $c ) = @_;

    $c->stash->{template} = 'configuration/roles.tt';

    my ($status, $result) = $c->model('Roles')->list();
    if (is_success($status)) {
        $c->stash->{roles} = $result;
    }
    else {
        $c->stash->{error} = $result;
    }
}


=head1 COPYRIGHT

Copyright (C) 2012-2013 Inverse inc.

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
