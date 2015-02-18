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
use Sereal::Encoder qw(encode_sereal);
use Benchmark qw(:all :hireswallclock);
use Memory::Usage;
use Devel::Size qw(total_size);
use Data::Swap;
our %SwitchConfig;
my $decoder = Sereal::Decoder->new;
my $last_txn_id = 0;
$SwitchConfig{__version} = 0;
my $mu = Memory::Usage->new;
{

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
    my $txn = $env->BeginTxn(MDB_RDONLY);       # Open a new transaction
    my $db = $txn->OpenDB("SwitchConfig");
    $db->ReadMode(1);
    $db->get('SwitchConfig', my $sereal_data);
    Sereal::Decoder::sereal_decode_with_object($decoder, $sereal_data, my $data);
    Data::Swap::swap(\%SwitchConfig, $data);
    undef $data;

}
$mu->record("Parent Process");
print total_size(\%SwitchConfig),"\n";
my $pid = fork;

exit 1 unless defined $pid;

if($pid) {
    $mu->dump;
    wait;
    exit 0;
}


$mu->record("Before open env");

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

$mu->record("Before open transaction");

my $txn = $env->BeginTxn(MDB_RDONLY);       # Open a new transaction

$mu->record("Before open db");

my $db = $txn->OpenDB("SwitchConfig");
$db->ReadMode(1);

$mu->record("Before reload config");

my $txn_id = $txn->id;
if( $last_txn_id != $txn_id) {
    $last_txn_id = $txn_id;
    $db->get('SwitchConfig', my $sereal_data);
    my $version = Sereal::Decoder::sereal_decode_only_header_with_object($decoder, $sereal_data);
    if($version != $SwitchConfig{__version}) {
        Sereal::Decoder::sereal_decode_with_object($decoder, $sereal_data, my $data);
        Data::Swap::swap(\%SwitchConfig, $data);
        undef $data;
    }
}

$mu->record("After reload config");

$mu->dump();

print total_size(\%SwitchConfig),"\n";

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

