package pf::services::manager::httpd_aaa;

=head1 NAME

pf::services::manager::httpd_aaa

=cut

=head1 DESCRIPTION

pf::services::manager::httpd_aaa

=cut

use strict;
use warnings;
use Moo;
use pf::config;

extends 'pf::services::manager::httpd_webservices';

has '+name' => (default => sub { 'httpd.aaa' } );

sub port {
    return $Config{ports}{aaa};
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2016 Inverse inc.

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
