#!/usr/bin/perl

=head1 NAME

podcoverage - 

=cut

=head1 DESCRIPTION

podcoverage

=cut

use strict;
use warnings;
use lib qw(/usr/local/pf/t);
use lib qw(/usr/local/pf/lib);
use podcoverage;

my $dbh = podcoverage::open_coverage_db();
podcoverage::save_current_coverage_state($dbh, "b6e63ba54cf4bf70d7837d47080bc50f1c00d8b8");


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2017 Inverse inc.

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

