package pf::cmd::pf::violationconfig;
=head1 NAME

pf::cmd::pf::violationconfig add documentation

=head1 SYNOPSIS

 pfcmd violationconfig get <all|defaults|vid>
       pfcmd violationconfig add <vid> [assignments]
       pfcmd violationconfig edit <vid> [assignments]
       pfcmd violationconfig delete <vid>

query/modify violations.conf configuration file

=head1 DESCRIPTION

pf::cmd::pf::violationconfig

=cut

use strict;
use warnings;
use pf::ConfigStore::Violations;
use base qw(pf::base::cmd::config_store);

our @FIELDS = qw(
  vid desc enabled actions user_mail_message
  vclose target_category priority whitelisted_roles
  trigger auto_enable max_enable grace
  window_dynamic window delay_by template
  button_text vlan redirect_url external_command
);

our %VALID_FIELDS = map { $_ => 1  } @FIELDS;

sub configStoreName { "pf::ConfigStore::Violations" }

sub display_fields { @FIELDS }

sub is_valid_field {
    my ($self, $field_name, $value) = @_;
    return defined $field_name && exists $VALID_FIELDS{$field_name};
}

sub idKey { 'vid' }

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

Minor parts of this file may have been contributed. See CREDITS.

=head1 COPYRIGHT

Copyright (C) 2005-2016 Inverse inc.

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

