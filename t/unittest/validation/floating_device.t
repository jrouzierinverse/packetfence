#!/usr/bin/perl

=head1 NAME

floating_device

=head1 DESCRIPTION

unit test for floating_device

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

use Test::More tests => 2;

#This test will running last
use Test::NoWarnings;
use pf::validation::floating_device;
my $validator = pf::validation::floating_device->new;

is_deeply(
    $validator->validate(
        {
            "id"        => "11:22:33:44:55:66",
            "ip"        => "1.2.3.4",
            trunkPort   => "yes",
            pvid        => 1,
            taggedVlans => [ 2, 3, 4 ]
        }
    ),
    undef,
    "Valid"
);

is_deeply(
    $validator->validate(
        {
            "ip"        => "1.2.3.4",
            trunkPort   => "yes",
            pvid        => 1,
            taggedVlans => [ 2, 3, 4 ]
        }
    ),
    { message => "", status => 422, errors => [{"field" => "id", message => "id is a required field", status => 422}] },
    "Missing id"
);

is_deeply(
    $validator->validate(
        {
            id          => undef,
            "ip"        => "1.2.3.4",
            trunkPort   => "yes",
            pvid        => 1,
            taggedVlans => [ 2, 3, 4 ]
        }
    ),
    {
        message => "",
        status  => 422,
        errors  => [
            {
                field   => "id",
                message => "id is a required field",
                status  => 422
            }
        ]
    },
    "null id"
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

