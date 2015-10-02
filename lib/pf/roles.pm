package pf::roles;

=head1 NAME

pf::roles - OO module that performs the roles lookups for nodes

=head1 SYNOPSIS

The pf::roles OO module implements default roles lookups for nodes.
All the behavior contained here can be overridden in lib/pf/roles/custom.pm.

=head1 EXPERIMENTAL

This module is considered experimental. For example not a lot of information
is provided to make the role decisions. This is expected to change in the
future at the cost of API changes.

You have been warned!

=head1 DEVELOPER NOTES

The Class Singleton patterns means you cannot not keep state within this module.

=cut

use strict;
use warnings;

use pf::config;
use pf::node qw(node_attributes);
use pf::violation qw(violation_count_trap);
use pf::log;

our $VERSION = 0.90;

=head1 METHODS

=over

=item getRoleForNode

Returns the proper role for a given node.

=cut

sub getRoleForNode {
    my ($class, $mac, $switch) = @_;
    my $logger = $class->logger();

    # Violation first
    my $open_violation_count = violation_count_trap($mac);
    if ($open_violation_count != 0) {
        $logger->info("MAC: $mac has $open_violation_count open violations(s) with action=trap; no role returned");
        return;
    }

    # looking at the node's registration status
    my $node_attributes = node_attributes($mac);
    if (!$node_attributes) {
        $logger->debug("MAC: $mac doesn't have a node entry; no role returned");
        return;
    }

    my $n_status = $node_attributes->{'status'};
    if ($n_status eq $pf::node::STATUS_UNREGISTERED || $n_status eq $pf::node::STATUS_PENDING) {
        $logger->debug("MAC: $mac is of status $n_status; no role returned");
        return;
    }

    # At this point, we are registered, we don't have a violation: perform Role lookup
    return $class->performRoleLookup($node_attributes, $switch);
}

=item performRoleLookup

This sub is meant to be overridden in lib/pf/roles/custom.pm if the default
version doesn't do the right thing for you.

By default it will return the role according to switch configuration based
on the node category. Otherwise a default global role based on the node
category is returned.

In other words, node category = global role. Then per switch role will be
looked up based on global role.

=cut

sub performRoleLookup {
    my ($class, $node_attributes, $switch) = @_;
    my $logger = $class->logger();

    my $mac = $node_attributes->{'mac'};

    $logger->trace("MAC: $mac should get a role.");
    my $globalRoleName = $class->_assignRoleFromCategory($node_attributes);
    return if (!defined($globalRoleName));

    my $switchRoleName = $switch->getRoleByName($globalRoleName);
    return if (!defined($switchRoleName));

    $logger->debug("MAC: $mac is assigned the $switchRoleName role.");
    return $switchRoleName;
}

=item _assignRoleFromCategory

Return node category if defined.

=cut

sub _assignRoleFromCategory {
    my ($class, $node_attributes) = @_;
    return $node_attributes->{'category'} if (defined($node_attributes->{'category'}));
    my $logger = $class->logger();

    $logger->warn("MAC: $node_attributes->{mac} is not categorized; no role returned");
    return;
}

sub logger {
    my ($proto) = @_;
    my $class = ref($proto) || $proto;
    return get_logger($class);
}

=back

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

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

1;
