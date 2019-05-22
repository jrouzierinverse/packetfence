package pf::UnifiedApi::Controller::Config::FloatingDevices;

=head1 NAME

pf::UnifiedApi::Controller::Config::FloatingDevices - 

=cut

=head1 DESCRIPTION

Configure floating devices

=cut

use strict;
use warnings;

use Mojo::Base qw(pf::UnifiedApi::Controller::Config);

has 'config_store_class' => 'pf::ConfigStore::FloatingDevice';
has 'form_class' => 'pfappserver::Form::Config::FloatingDevice';
has 'primary_key' => 'floating_device_id';

use pf::ConfigStore::FloatingDevice;
use pfappserver::Form::Config::FloatingDevice;
 
=head2 optionsv2

optionsv2

=cut

sub optionsv2 {
    my ($self) = @_;
    my $false = bless( do{\(my $o = 0)}, 'JSON::PP::Boolean');
    my $true = bless( do{\(my $o = 1)}, 'JSON::PP::Boolean' );
    $self->render(
        json => {
            fields => [
                {
                    name    => "id",
                    pattern => {
                        message => "Mac Address",
                        regex =>
                          "[0-9A-Fa-f][0-9A-Fa-f](:[0-9A-Fa-f][0-9A-Fa-f]){5}"
                    },
                    required => $true,
                    type     => "string"
                },
                {
                    min_value => 0,
                    name      => "pvid",
                    required  => $true,
                    type      => "integer"
                },
                {
                    name     => "ip",
                    required => $false,
                    type     => "string"
                },
                {
                    item => {
                        type => "string"
                    },
                    name     => "taggedVlans",
                    required => $false,
                    type     => "array"
                },
                {
                    name     => "trunkPort",
                    required => $false,
                    type     => "string"
                }
            ],
        }
    );
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2019 Inverse inc.

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
