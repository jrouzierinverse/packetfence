package pfappserver::Base::Controller::Crud::Config;
=head1 NAME

pfappserver::Base::Controller::Crud::Config add documentation

=cut

=head1 DESCRIPTION

PortalProfile

=cut

use strict;
use warnings;
use HTTP::Status qw(:constants is_error is_success);
use MooseX::MethodAttributes::Role;
use namespace::autoclean;
use Log::Log4perl qw(get_logger);

with 'pfappserver::Base::Controller::Crud';

=head2 Methods

=over

=cut

after [qw(update remove rename_item)] => sub {
    my ($self,$c) = @_;
    if(is_success($c->response->status) ) {
        $self->getModel($c)->rewriteConfig();
    }
};

after create => sub {
    my ($self,$c) = @_;
    if(is_success($c->response->status) && $c->request->method eq 'POST' ) {
        my $model = $self->getModel($c);
        my ($status,$message) = $model->rewriteConfig();
        if(is_error($status)) {
            my $logger = get_logger();
            $c->stash(
                current_view => 'JSON',
                status_msg => $message,
            );
            $logger->info("rolling back");
            $model->rollback();
        }
        $get_logger->info($message);
        $c->response->status($status);
    }
};


=back

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

1;

