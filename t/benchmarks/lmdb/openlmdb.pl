#!/usr/bin/perl
=head1 NAME

openlmdb add documentation

=cut

=head1 DESCRIPTION

openlmdb

=cut

use strict;
use warnings;
use lib qw(/usr/local/pf/lib);
use LMDB_File qw(MDB_CREATE MDB_RDONLY MDB_NEXT MDB_FIRST);
use Benchmark qw(:all);
my $env = LMDB::Env->new(
    "/usr/local/pf/var/cache",
    {   mapsize    => 200 * 1024 * 1024,    # Plenty space, don't worry
        maxdbs     => 20,                   # Some databases
        mode       => 0600,
        flags      => MDB_RDONLY,
        maxreaders => 1022,
        # More options
    }
);
my $txn = $env->BeginTxn(MDB_RDONLY);     # Open a new transaction
$txn->reset();
my $last_txn_id = 0;

cmpthese(timethese(
    -5,
    {
        'Opening a transaction' =>
        sub {
            $txn->renew();
            $txn->reset();
        },
        'Opening a database' =>
        sub {
            $txn->renew();
            my $txn_id = $txn->id;
            if( $last_txn_id != $txn_id) {
                $last_txn_id = $txn_id;
                my $db  = $txn->OpenDB("SwitchConfig");
                $db->ReadMode(1);
            }
            $txn->reset();
        }
    }
));

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

