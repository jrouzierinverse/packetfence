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
use pf::stash;
use pf::CHI;
use pf::SwitchFactory();

use Apache2::Const -compile => 'OK';

sub handler {
    my $r = shift;
    stash_clear();
    pf::config::cached::ReloadConfigs();
    return Apache2::Const::OK;
}

=head2 child_init

Initialize the child process
Reestablish connections to global connections
Refresh any configurations

=cut

sub child_init {
    my ($child_pool, $s) = @_;
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
    my ($conf_pool, $log_pool, $temp_pool, $s) = @_;
    pf::StatsD->closeStatsd;
    db_disconnect();
    pf::CHI->clear_memoized_cache_objects;
    pf::SwitchFactory::preLoadModules();
    return Apache2::Const::OK;
}

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

