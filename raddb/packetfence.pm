#!/usr/bin/perl

=head1 NAME

packetfence.pm - FreeRADIUS PacketFence integration module

=head1 DESCRIPTION

This module forwards normal RADIUS requests to PacketFence.

=head1 NOTES

Note1:

Our pf::config package is loading all kind of stuff and should be reworked a bit. We need to use that package to load
configuration parameters from the configuration file. Until the package is cleaned, we will define the configuration
parameter here.

Once cleaned:

- Uncommented line: use pf::config

- Remove line: use constant SOAP_PORT => '9090';

- Remove line: $curl->setopt(CURLOPT_URL, 'http://127.0.0.1:' . SOAP_PORT);

- Uncomment line: $curl->setopt(CURLOPT_URL, 'http://127.0.0.1:' . $Config{'ports'}{'soap'});

Search for 'note1' to find the appropriate lines.

=cut

use strict;
use warnings;


use lib '/usr/local/pf/lib/';

#use pf::config; # TODO: See note1
use pf::radius::packetfence::custom;
# This is very important! Without this, the script will not get the filled hashes from FreeRADIUS.
our (%RAD_REQUEST, %RAD_REPLY, %RAD_CHECK);

=head1 SUBROUTINES

=over

=item * authorize

RADIUS calls this method to authorize clients.

=cut

sub authorize {
    pf::radius::packetfence::custom->authorize(\%RAD_REQUEST, \%RAD_REPLY, \%RAD_CHECK);
}

=item * post_auth

Once we authenticated the user's identity, we perform PacketFence's Network Access Control duties

=cut

sub post_auth {
    pf::radius::packetfence::custom->post_auth(\%RAD_REQUEST, \%RAD_REPLY, \%RAD_CHECK);
}

#
# --- Unused FreeRADIUS hooks ---
#

# Function to handle authenticate
sub authenticate {
    pf::radius::packetfence::custom->authenticate(\%RAD_REQUEST, \%RAD_REPLY, \%RAD_CHECK);
}

# Function to handle preacct
sub preacct {
    pf::radius::packetfence::custom->authenticate(\%RAD_REQUEST, \%RAD_REPLY, \%RAD_CHECK);
}

# Function to handle accounting
sub accounting {
    pf::radius::packetfence::custom->accounting(\%RAD_REQUEST, \%RAD_REPLY, \%RAD_CHECK);
}

# Function to handle checksimul
sub checksimul {
    pf::radius::packetfence::custom->checksimul(\%RAD_REQUEST, \%RAD_REPLY, \%RAD_CHECK);
}

# Function to handle pre_proxy
sub pre_proxy {
    pf::radius::packetfence::custom->pre_proxy(\%RAD_REQUEST, \%RAD_REPLY, \%RAD_CHECK);
}

# Function to handle post_proxy
sub post_proxy {
    pf::radius::packetfence::custom->post_proxy(\%RAD_REQUEST, \%RAD_REPLY, \%RAD_CHECK);
}

# Function to handle xlat
sub xlat {
    pf::radius::packetfence::custom->xlat(\%RAD_REQUEST, \%RAD_REPLY, \%RAD_CHECK);
}

# Function to handle detach
sub detach {
    pf::radius::packetfence::custom->detach(\%RAD_REQUEST, \%RAD_REPLY, \%RAD_CHECK);
}

=back

=head1 SEE ALSO

L<http://wiki.freeradius.org/Rlm_perl>

=head1 COPYRIGHT

Copyright (C) 2002  The FreeRADIUS server project

Copyright (C) 2002  Boian Jordanov <bjordanov@orbitel.bg>

Copyright (C) 2006-2010, 2013 Inverse inc.

=head1 LICENSE

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

=cut

1;
