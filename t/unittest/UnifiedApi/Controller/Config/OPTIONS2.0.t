#!/usr/bin/perl

=head1 NAME

OPTIONS2.0

=head1 DESCRIPTION

unit test for OPTIONS2.0

=cut

use strict;
use warnings;
#
use lib '/usr/local/pf/lib';

BEGIN {
    #include test libs
    use lib qw(/usr/local/pf/t);
    #Module for overriding configuration paths
    use setup_test_config;
}

use Test::More tests => 4;

#This test will running last
use Test::Mojo;
use Test::NoWarnings;
my $t = Test::Mojo->new('pf::UnifiedApi');

my $false = bless( do{\(my $o = 0)}, 'JSON::PP::Boolean');
my $true = bless( do{\(my $o = 1)}, 'JSON::PP::Boolean' );

$t->options_ok("/api/v2/config/floating_devices")
    ->status_is(200)
    ->json_is(
    {
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
        status => 200
    }
);

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

