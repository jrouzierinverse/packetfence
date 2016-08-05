package pf::Switch::Ruckus;

=head1 NAME

pf::Switch::Ruckus

=head1 SYNOPSIS

The pf::Switch::Ruckus module implements an object oriented interface to
manage Ruckus Wireless Controllers

=head1 STATUS

Developed and tested on ZoneDirector 1100 running firmware 9.3.0.0 build 83

=over

=item Supports

=over

=item Deauthentication with RADIUS Disconnect (RFC3576)

=back

=back

=head1 BUGS AND LIMITATIONS

=over

No Dynamic VLAN assigments using Mac Authentication.  The module support for mac-auth is disabled for now.

=back

=cut

use strict;
use warnings;

use base ('pf::Switch');

use pf::accounting qw(node_accounting_dynauth_attr);
use pf::constants;
use pf::config qw(
    $MAC
    $SSID
);
use pf::util;

sub description { 'Ruckus Wireless Controllers' }

=head1 SUBROUTINES

=over

=cut

# CAPABILITIES
# access technology supported
sub supportsWirelessDot1x { return $TRUE; }
sub supportsWirelessMacAuth { return $FALSE; }
sub supportsExternalPortal { return $TRUE; }
# inline capabilities
sub inlineCapabilities { return ($MAC,$SSID); }

=item supportsWebFormRegistration

Will be activated only if HTTP is selected as a deauth method

=cut

sub supportsWebFormRegistration {
    my ($self) = @_;
    return $self->{_deauthMethod} eq $SNMP::HTTP;
}

#
# %TRAP_NORMALIZERS
# A hash of Ruckus trap normalizers
# Use the following convention when adding a normalizer
# <nameOfTrapNotificationType>TrapNormalizer
#
our %TRAP_NORMALIZERS = (
    '1.3.6.1.4.1.25053.2.2.1.4' => 'ruckusZDEventRogueAPTrapTrapNormalizer'
);

=item getVersion

obtain image version information from switch

=cut

sub getVersion {
    my ($self)       = @_;
    my $oid_ruckusVer = '1.3.6.1.4.1.25053.1.2.1.1.1.1.18';
    my $logger       = $self->logger;
    if ( !$self->connectRead() ) {
        return '';
    }
    $logger->trace("SNMP get_request for sysDescr: $oid_ruckusVer");

    # sysDescr sample output:
    # 9.3.0.0 build 83

    my $result = $self->{_sessionRead}->get_request( -varbindlist => [$oid_ruckusVer] );
    if (defined($result)) {
        return $result->{$oid_ruckusVer};
    }

    # none of the above worked
    $logger->warn("unable to fetch version information");
}

=item parseTrap

All traps ignored

=cut

sub parseTrap {
    my ( $self, $trapString ) = @_;
    my $trapHashRef;
    my $logger = $self->logger;

    # Handle WIPS Trap
    if ( $trapString =~ /\.1\.3\.6\.1\.4\.1\.25053\.2\.2\.2\.20 = STRING: \"([a-f0-9]{2}:[a-f0-9]{2}:[a-f0-9]{2}:[a-f0-9]{2}:[a-f0-9]{2}:[a-f0-9]{2})/ ) {
        $trapHashRef->{'trapType'}    = 'wirelessIPS';
        $trapHashRef->{'trapMac'} = clean_mac($1);
    } else {
        $logger->debug("trap currently not handled.  TrapString was: $trapString");
        $trapHashRef->{'trapType'} = 'unknown';
    }
    return $trapHashRef;
}

=item deauthenticateMacDefault

De-authenticate a MAC address from wireless network (including 802.1x).

New implementation using RADIUS Disconnect-Request.

=cut

sub deauthenticateMacDefault {
    my ( $self, $mac, $is_dot1x ) = @_;
    my $logger = $self->logger;

    if ( !$self->isProductionMode() ) {
        $logger->info("not in production mode... we won't perform deauthentication");
        return 1;
    }

    #Fetching the acct-session-id
    my $dynauth = node_accounting_dynauth_attr($mac);

    $logger->debug("deauthenticate $mac using RADIUS Disconnect-Request deauth method");
    return $self->radiusDisconnect(
        $mac, { 'Acct-Session-Id' => $dynauth->{'acctsessionid'}, 'User-Name' => $dynauth->{'username'} },
    );
}

=item deauthTechniques

Return the reference to the deauth technique or the default deauth technique.

=cut

sub deauthTechniques {
    my ($self, $method) = @_;
    my $logger = $self->logger;
    my $default = $SNMP::RADIUS;
    my %tech = (
        $SNMP::RADIUS => 'deauthenticateMacDefault',
    );

    if (!defined($method) || !defined($tech{$method})) {
        $method = $default;
    }
    return $method,$tech{$method};
}

=item parseUrl

This is called when we receive a http request from the device and return specific attributes:

client mac address
SSID
client ip address
redirect url
grant url
status code

=cut

sub parseUrl {
    my($self, $req) = @_;
    my $logger = $self->logger;
    return (clean_mac($$req->param('client_mac')),$$req->param('ssid'),defined($$req->param('uip')) ? $$req->param('uip') : undef,$$req->param('url'),undef,undef);
}

=item getAcceptForm

Creates the form that should be given to the client device to trigger a reauthentication.

=cut

sub getAcceptForm {
    my ( $self, $mac , $destination_url, $cgi_session) = @_;
    my $logger = $self->logger;
    $logger->debug("Creating web release form");

    my $client_ip = $cgi_session->param("ecwp-original-param-uip");
    my $controller_ip = $self->{_ip};

    my $html_form = qq[
        <form name="weblogin_form" action="http://$controller_ip:9997/login" method="POST" style="display:none">
          <input type="text" name="ip" value="$client_ip" />
          <input type="text" name="username" value="$mac" />
          <input type="text" name="password" value="$mac"/>
          <input type="submit">
        </form>

        <script language="JavaScript" type="text/javascript">
        window.setTimeout('document.weblogin_form.submit();', 1000);
        </script>
    ];

    $logger->debug("Generated the following html form : ".$html_form);
    return $html_form;
}

=item _findTrapNormalizer

Find the normalizer method for the trap for Ruckus switches

=cut

sub _findTrapNormalizer {
    my ($self, $snmpTrapOID, $pdu, $variables) = @_;
    if (exists $TRAP_NORMALIZERS{$snmpTrapOID}) {
        return $TRAP_NORMALIZERS{$snmpTrapOID};
    }
    return undef;
}


=item ruckusZDEventRogueAPTrapTrapNormalizer

Trap normalizer for the ruckusZDEventRogueAPTrap

=cut

sub ruckusZDEventRogueAPTrapTrapNormalizer {
    my ($self, $snmpTrapOID, $pdu, $variables) = @_;
    my $ruckusZDEventRogueMacAddr_oid = ".1.3.6.1.4.1.25053.2.2.2.20";
    my ($variable) = $self->findTrapVarWithBase($variables, $ruckusZDEventRogueMacAddr_oid);
    return undef unless $variable;
    return undef unless $variable->[1] =~ /STRING: \"([a-f0-9]{2}:[a-f0-9]{2}:[a-f0-9]{2}:[a-f0-9]{2}:[a-f0-9]{2}:[a-f0-9]{2})/;
    return {
        trapType => 'wirelessIPS',
        trapMac => clean_mac($1),
    };
}

=back

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

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:
