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

=head2 _format_section

=cut

sub _format_section :Private {
    my ($self, $entries_ref) = @_;

    for (my $i = 0; $i < scalar @{$entries_ref}; $i++) {
        my $entry_ref = $entries_ref->[$i];

        # Try to be smart. Description that refers to a comma-delimited list must be bigger.
        if ($entry_ref->{type} eq "text" && $entry_ref->{description} =~ m/comma[-\s](delimite|separate)/si) {
            $entry_ref->{type} = 'text-large';
        }

        # Value should always be defined for toggles (checkbox and select) and times (duration)
        elsif ($entry_ref->{type} eq "toggle" ||
               $entry_ref->{type} eq "time") {
            $entry_ref->{value} = $entry_ref->{default_value} unless ($entry_ref->{value});
        }

        elsif ($entry_ref->{type} eq "date") {
            my $time = str2time($entry_ref->{value} || $entry_ref->{default_value});
            # Match date format of Form::Widget::Theme::Pf
            $entry_ref->{value} = POSIX::strftime("%Y-%m-%d", localtime($time));
        }

        # Limited formatting from text to html
        $entry_ref->{description} =~ s/</&lt;/g; # convert < to HTML entity
        $entry_ref->{description} =~ s/>/&gt;/g; # convert > to HTML entity
        $entry_ref->{description} =~ s/(\S*(&lt;|&gt;)\S*)\b/<code>$1<\/code>/g; # enclose strings that contain < or >
        $entry_ref->{description} =~ s/(\S+\.(html|tt|pm|pl|txt))\b(?!<\/code>)/<code>$1<\/code>/g; # enclose strings that ends with .html, .tt, etc
        $entry_ref->{description} =~ s/^ \* (.+?)$/<li>$1<\/li>/mg; # create list elements for lines beginning with " * "
        $entry_ref->{description} =~ s/(<li>.*<\/li>)/<ul>$1<\/ul>/s; # create lists from preceding substitution
        $entry_ref->{description} =~ s/\"([^\"]+)\"/<i>$1<\/i>/mg; # enclose strings surrounded by double quotes
        $entry_ref->{description} =~ s/\[(\S+)\]/<strong>$1<\/strong>/mg; # enclose strings surrounded by brakets
        $entry_ref->{description} =~ s/(https?:\/\/\S+)/<a href="$1">$1<\/a>/g; # make links clickable
    }
}

=head2 _update_section

=cut

sub _update_section :Private {
    my ($self, $c, $form) = @_;

    my $entries_ref = $c->model('Config::Pf')->read($c->action->name);
    my $data = {};

    foreach my $section (keys %$form) {
        foreach my $field (keys %{$form->{$section}}) {
            $data->{$section.'.'.$field} = $form->{$section}->{$field};
        }
    }

    my ($status, $message) = $c->model('Config::Pf')->update($data);

    if (is_error($status)) {
        $c->response->status($status);
    }
    $c->stash->{status_msg} = $message;
    $c->stash->{current_view} = 'JSON';
}

=head2 _process_section

=cut

sub _process_section :Private {
    my ($self, $c) = @_;
    my $section = $c->action->name;
    my ($params, $form);

    $c->stash->{section} = $section;
    $c->stash->{template} = 'configuration/section.tt';

    $params = $c->model('Config::Pf')->read($section);
    $self->_format_section($params);

    if ($c->request->method eq 'POST') {
        $form = pfappserver::Form::Config::Pf->new(ctx => $c,
                                                   section => $params);
        $form->process(params => $c->req->params);
        if ($form->has_errors) {
            $c->response->status(HTTP_BAD_REQUEST);
            $c->stash->{status_msg} = $form->field_errors; # TODO: localize error message
        }
        else {
            $self->_update_section($c, $form->value);
        }
    }
    else {
        $form = pfappserver::Form::Config::Pf->new(ctx => $c,
                                                   section => $params);
        $form->process;
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

    $c->forward('Controller::Interface', 'index');
}

=head2 switches

=cut

sub switches :Local {
    my ($self, $c) = @_;

    $c->go('Controller::Configuration::Switch', 'index');
}

=head2 authentication

=cut

sub authentication :Local {
    my ($self, $c) = @_;

    $c->forward('Controller::Authentication', 'index');
}

=head2 users

=cut

sub users :Local {
    my ($self, $c) = @_;

    $c->forward('Controller::User', 'create');
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
