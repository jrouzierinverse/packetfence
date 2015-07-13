package pfappserver::Form::Config::PKI_Provider::scep;

=head1 NAME

pfappserver::Form::Config::PKI_Provider

=head1 DESCRIPTION

=cut

use strict;
use warnings;
use HTTP::Status qw(:constants is_error is_success);
use HTML::FormHandler::Moose;
extends 'pfappserver::Base::Form';
with 'pfappserver::Base::Form::Role::Help';

use pf::log;

use pf::factory::pki_provider;

## Definition
has_field 'id' =>
  (
   type => 'Text',
   label => 'PKI Provider Name',
   required => 1,
   messages => { required => 'Please specify the name of the PKI provider' },
   tags => { after_element => \&help,
             help => 'The unique id of the PKI provider'},
  );

has_field 'type' =>
  (
   type => 'Hidden',
   required => 1,
  );

has_field 'url' =>
  (
   type => 'Text',
   tags => { after_element => \&help,
             help => 'The url used to connect to the MS SCEP PKI service'},
  );

has_field 'username' =>
  (
   type => 'Text',
   tags => { after_element => \&help,
             help => 'Username to connect to the MS SCEP PKI Service'},
  );

has_field 'password' =>
  (
   type => 'Password',
   password => 0,
   tags => { after_element => \&help,
             help => 'Password for the username filled in above'},
  );

has_field 'country' =>
  (
   type => 'Country',
   tags => { after_element => \&help,
             help => 'Country for the certificate'},
  );

has_field 'state' =>
  (
   type => 'Text',
   tags => { after_element => \&help,
             help => 'State for the certificate'},
  );

has_field 'organisation' =>
  (
   type => 'Text',
   tags => { after_element => \&help,
             help => 'Organisation for the certificate'},
  );


has_field 'cn_attribute' =>
  (
   type => 'Select',
   label => 'Common name Attribute',
   options => [{ label => 'MAC address', value => 'mac' }, { label => 'Username' , value => 'pid' }],
   default => 'pid',
   tags => { after_element => \&help,
             help => 'Defines what attribute of the node to use as the common name during the certificate generation.' },
  );

has_block definition =>
  (
    render_list => [qw(type url username password country state organisation cn_attribute)],
  );

=head1 COPYRIGHT

Copyright (C) 2005-2015 Inverse inc.

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
