package pf::WebAPI::InitHandler;
=head1 NAME

pf::WebAPI::InitHandler

=cut

=head1 DESCRIPTION

pf::WebAPI::InitHandler

=cut

use strict;
use warnings;

use Apache2::RequestRec ();
use pf::config::cached;
use pf::StatsD qw($statsd);
use pf::db;
use pf::LDAP;
use pf::CHI;
use pf::SwitchFactory();

use Apache2::Const -compile => 'OK';

sub handler {
    my $r = shift;
    pf::config::cached::ReloadConfigs();
    return Apache2::Const::OK;
}

=head2 child_init

Initialize the child process
Reestablish connections to global connections
Refresh any configurations

=cut

sub child_init {
    my ($class, $child_pool, $s) = @_;
    #Avoid child processes having the same random seed
    srand();
    pf::StatsD->initStatsd;
    #The database initialization can fail on the initial install
    eval {
        db_connect();
    };
    return Apache2::Const::OK;
}

=head2 post_config

Cleaning before forking child processes
Close connections to avoid any sharing of sockets

=cut

sub post_config {
    my ($class, $conf_pool, $log_pool, $temp_pool, $s) = @_;
    pf::StatsD->closeStatsd;
    pf::LDAP::CLONE();
    db_disconnect();
    preloadSwitches();
    pf::CHI->clear_memoized_cache_objects;
    return Apache2::Const::OK;
}

=head2 preloadSwitches

Preload switches in the post_config

=cut

sub preloadSwitches {
    my ($class) = @_;
    pf::SwitchFactory->preloadConfiguredModules();
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

