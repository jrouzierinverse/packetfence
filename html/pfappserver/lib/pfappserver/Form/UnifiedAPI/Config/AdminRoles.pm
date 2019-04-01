package pfappserver::Form::UnifiedAPI::Config::AdminRoles;

=head1 NAME

pfappserver::Form::UnifiedAPI::Config::AdminRoles -

=head1 DESCRIPTION

pfappserver::Form::UnifiedAPI::Config::AdminRoles

=cut

use strict;
use warnings;

use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Config::AdminRoles';

has_field 'allowed_access_durations' => (
   type => 'CSV',
   multiple => 1,
   id => 'allowed_access_durations',
   label => 'Allowed user access durations',
   tags => { after_element => \&help,
             help => 'A comma seperated list of access durations available to the admin user. If none are provided then the default access durations are used'},
   input_param => 'allowed_access_durations',
   accessor => 'allowed_access_durations',
);

has_field 'allowed_access_durations.contains' => (
    type => 'Duration',
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

