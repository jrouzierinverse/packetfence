package pfappserver::Form::Config::Authentication::Source::Billing;

=head1 NAME

pfappserver::Form::Config::Authentication::Source::Billing;

=cut

=head1 DESCRIPTION

pfappserver::Form::Authentication::Source::Billing

=cut

use strict;
use warnings;
use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Config::Authentication::Source';
with 'pfappserver::Base::Form::Role::Help';

has_field currency => (
    type => 'Select',
    default => 'USD',
    options_method => \&options_currency,
);

has_field 'create_local_account' => (
    type => 'Toggle',
    checkbox_value => 'yes',
    unchecked_value => 'no',
    label => 'Create Local Account',
    default => pf::Authentication::Source::BillingSource->meta->get_attribute('create_local_account')->default,
    tags => {
        after_element => \&help,
        help => 'Create a local account on the PacketFence system based on the account email address provided.',
    },
);

has_field 'local_account_logins' => (
    type => 'PosInteger',
    label => 'Amount of logins for the local account',
    default => pf::Authentication::Source::BillingSource->meta->get_attribute('local_account_logins')->default,
    tags => {
        after_element => \&help_list,
        help => 'The amount of times, the local account can be used after its created. 0 means infinite.'
    },
);

has_field test_mode => (
    type => 'Checkbox',
    checkbox_value => '1',
    unchecked_value => '0',
);

has_field 'send_email_confirmation' => (
   type => 'Toggle',
   label => 'Send billing confirmation',
   checkbox_value => 'enabled',
   unchecked_value => 'disabled',
);

=head2 options_currency

Currencies options for the a billing sources

=cut

sub options_currency {
    my ($field) = @_;
    my $form = $field->form;
    map {{value => $_, label => $_}} $form->currencies;
}

=head2 currencies

The list of currencies for the billing source

=cut

sub currencies { qw(USD CAD) }

# Form fields

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

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
