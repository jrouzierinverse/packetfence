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
use LMDB_File qw(MDB_CREATE MDB_RDONLY MDB_NEXT MDB_FIRST MDB_NOTLS);
use Sereal::Decoder qw(sereal_decode_with_object sereal_decode_with_header_with_object);
use Sereal::Encoder qw(encode_sereal);
use Benchmark qw(:all :hireswallclock);
use pf::ConfigStore::Switch;
use Tie::Hash;

$LMDB_File::die_on_err = 0;

my $decoder = Sereal::Decoder->new;

my $env = LMDB::Env->new(
    "/usr/local/pf/var/cache",
    {   mapsize    => 200 * 1024 * 1024,    # Plenty space, don't worry
        maxdbs     => 20,                   # Some databases
        mode       => 0600,
        flags      => MDB_RDONLY | MDB_NOTLS,
        maxreaders => 1022,

        # More options
    }
);

my $txn = $env->BeginTxn(MDB_RDONLY);       # Open a new transaction
#my $resettxn = $env->BeginTxn(MDB_RDONLY);
#$resettxn->reset();

my $db = $txn->OpenDB("SwitchConfig");
$db->ReadMode(1);

our %ZeroCopyCache;
our %CopyCache;

tie our %TieHash,'Tie::StdHash';
%{tied(%TieHash)} = %SwitchConfig;

our %AltSwitchConfig = %SwitchConfig;
$AltSwitchConfig{__version} = 0;
my $last_txn_id = 0;

my @KEYS = keys %SwitchConfig;
my $KEYS_COUNT = @KEYS;

my $results = timethese(
    -5,
    {
    'Zerocopy' => sub {
           $db->get($KEYS[int (rand $KEYS_COUNT)], my $data);
           if($data) {
               Sereal::Decoder::sereal_decode_with_object($decoder, $data, my $switch);
           }
       },
       'Copy' => sub {
           my $data = $db->get($KEYS[int (rand $KEYS_COUNT)]);
           if($data) {
               Sereal::Decoder::sereal_decode_with_object($decoder, $data, my $switch);
           }
       },
       'ZerocopyWithCache' => sub {
           my $switch;
           my $key = $KEYS[int (rand $KEYS_COUNT)];
           my $data;
           if (exists $ZeroCopyCache{$key}) {
               my $value = $ZeroCopyCache{$key};
               my $txn_id = $txn->id;
               if($value->{__last_txn_id} != $txn_id) {
                   #Get the version of the data from the sereal header
                   $db->get($key, $data);
                   if($data) {
                       my $version = Sereal::Decoder::sereal_decode_only_header_with_object($decoder, $data);
                       #If the version matches we are good
                       if ($value->{__version} == $version) {
                           $switch = $value;
                           #Update the last txn id so we do not need to check it again
                           $switch->{__last_txn_id} = $txn_id;
                       }
                   }
               } else {
                   $switch = $value;
               }
           }
           unless ($switch) {
               $db->get($key, $data) unless $data;
               if($data) {
                   Sereal::Decoder::sereal_decode_with_object($decoder, $data, $switch);
                   $switch->{__last_txn_id} = $txn->id;
                   $ZeroCopyCache{$key} = $switch;
               }
           }
       },
       'CopyWithCache' => sub {
           my $switch;
           my $key = $KEYS[int (rand $KEYS_COUNT)];
           my $data;
           if (exists $CopyCache{$key}) {
               my $value = $CopyCache{$key};
               my $txn_id = $txn->id;
               #Check the data against the current transaction
               if($value->{__last_txn_id} != $txn_id) {
                   #Get the version of the data from the sereal header
                   $data  = $db->get($key);
                   if($data) {
                       my $version = Sereal::Decoder::sereal_decode_only_header_with_object($decoder, $data);
                       #If the version matches we are good
                       if ($value->{__version} == $version) {
                           $switch = $value;
                           #Update the last txn id so we do not need to check it again
                           $switch->{__last_txn_id} = $txn_id;
                       }
                   }
               } else {
                   $switch = $value;
               }
           }
           unless ($switch) {
               $data = $db->get($key) unless $data;
               if($data) {
                   Sereal::Decoder::sereal_decode_with_object($decoder, $data, $switch);
                   $switch->{__last_txn_id} = $txn->id;
                   $CopyCache{$key} = $switch;
               }
           }
       },
        'MemoryHash' => sub {
            my $switch = $SwitchConfig{$KEYS[int (rand $KEYS_COUNT)]};
        },
        'TiedMemoryHash' => sub {
            my $switch = $TieHash{$KEYS[int (rand $KEYS_COUNT)]};
        },
        "ZeroCopy Whole Version" => sub {
            if( $last_txn_id != $txn->id) {
                $last_txn_id = $txn->id;
                $db->get('SwitchConfig', my $sereal_data);
                if($sereal_data) {
                    my $version = Sereal::Decoder::sereal_decode_only_header_with_object($decoder, $sereal_data);
                    if($version != $AltSwitchConfig{__version}) {
                        Sereal::Decoder::sereal_decode_with_object($decoder, $sereal_data, my $value);
                        Data::Swap::swap(\%AltSwitchConfig, $value);
                        undef $value;
                    }
                }
            }
            my $switch = $AltSwitchConfig{$KEYS[int (rand $KEYS_COUNT)]};
        },
    }
);

cmpthese($results);

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

