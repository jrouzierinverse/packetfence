#!/usr/bin/perl

=head1 NAME

store-switches-in-lmdb add documentation

=cut

=head1 DESCRIPTION

store-switches-in-lmdb

=cut

use strict;
use warnings;
use lib qw(/usr/local/pf/lib);
use LMDB_File qw(MDB_CREATE MDB_APPEND);
use pf::ConfigStore::Switch;
use Sereal::Encoder qw(sereal_encode_with_object);

my $encoder = Sereal::Encoder->new();

my $env = LMDB::Env->new(
    "/usr/local/pf/var/cache",
    {   mapsize    => 200 * 1024 * 1024,    # Plenty space, don't worry
        maxdbs     => 20,                   # Some databases
        mode       => 0600,
        maxreaders => 1022,

        # More options
    }
);

my $txn = $env->BeginTxn();                 # Open a new transaction

print "got txn\n";
my $dbi = $txn->open("SwitchConfig", MDB_CREATE| MDB_APPEND);

print "$dbi\n";
my $db = LMDB_File->new($txn, $dbi);

my $txn_id = $txn->id;

my @kvs;

while(my ($key,$value) = each %SwitchConfig) {
    print "storing $key\n";
    $value->{__version} = $txn_id;
    my $data = sereal_encode_with_object($encoder, $value, $txn_id);
    push @kvs ,[$key,$data];
}

my $data = sereal_encode_with_object($encoder, {%SwitchConfig,'__version' => $txn_id}, $txn_id);
push @kvs, ["SwitchConfig",$data];

@kvs = sort { $a->[0] cmp $b->[0] } @kvs;

for my $kv (@kvs) {
    print "storing $kv->[0]\n";
    $db->put(@$kv)
}


$txn->commit();

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

