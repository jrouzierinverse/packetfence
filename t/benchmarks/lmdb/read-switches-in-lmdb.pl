#!/usr/bin/perl
=head1 NAME

read-switches-in-lmdb add documentation

=cut

=head1 DESCRIPTION

store-switches-in-lmdb

=cut

use strict;
use warnings;
use lib qw(/usr/local/pf/lib);
use LMDB_File qw(MDB_CREATE MDB_RDONLY MDB_NEXT MDB_FIRST);
use Sereal::Decoder qw(sereal_decode_with_object sereal_decode_with_header_with_object);
use DDP;
use Time::HiRes qw(sleep);

my $decoder = Sereal::Decoder->new;

my $env = LMDB::Env->new(
    "/usr/local/pf/var/cache",
    {   mapsize => 200 * 1024 * 1024,    # Plenty space, don't worry
        maxdbs  => 20,                          # Some databases
        mode    => 0600,
        flags   => MDB_RDONLY,
        maxreaders => 1022,

        # More options
    }
);

my $txn = $env->BeginTxn(MDB_RDONLY);    # Open a new transaction
print "Got txn\n";


my $info = $env->info;
while(1) {
    my $db = $txn->OpenDB( "SwitchConfig");
    $db->ReadMode(1);
    print "txn id : ", $txn->id,"\n";
    $db->get('default', my $data);
    sereal_decode_with_header_with_object($decoder, $data, my $switch, my $header);
    print $switch->{__version}, " : ",$switch->{description},"\n";
    $txn->reset();
    sleep(0.10);
    $txn->renew();
}


#cmpthese(
#    -10,
#    {   'Zerocopy' => sub {
#            $db->get('default', my $data);
#            my $switch = decode_sereal($data);
#        },
#        'Copy' => sub {
#            my $data   = $db->get('default');
#            my $switch = decode_sereal($data);
#          }
#    }
#);

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

