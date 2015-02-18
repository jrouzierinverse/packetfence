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
use pf::ConfigStore::Switch;
use Tie::Hash;
use Data::Swap;

my $decoder = Sereal::Decoder->new;

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
my $db  = $txn->OpenDB("SwitchConfig");
$db->ReadMode(1);
#preload the data
for(1 .. 10) {
    $db->get('SwitchConfig', my $sereal_data);
}

$SwitchConfig{__version} = 0;

my $results = timethese(
    -5,
    {   "ZeroCopy" => sub {
            $db->get('SwitchConfig', my $sereal_data);
            Sereal::Decoder::sereal_decode_with_object($decoder, $sereal_data, my $data);
            Data::Swap::swap(\%SwitchConfig, $data);
            undef $data;
        },
       "ZeroCopy No swap" => sub {
            $db->get('SwitchConfig', my $sereal_data);
            Sereal::Decoder::sereal_decode_with_object($decoder, $sereal_data, my $data);
            %SwitchConfig = %$data;
            undef $data;
        },
       "ZeroCopy no undef" => sub {
            $db->get('SwitchConfig', my $sereal_data);
            Sereal::Decoder::sereal_decode_with_object($decoder, $sereal_data, my $data);
            Data::Swap::swap(\%SwitchConfig, $data);
        },
        "Copy" => sub {
            my $sereal_data = $db->get('SwitchConfig');
            Sereal::Decoder::sereal_decode_with_object($decoder, $sereal_data, my $data);
            Data::Swap::swap(\%SwitchConfig, $data);
            undef $data;
            undef $sereal_data;
        },
        "Copy no undef" => sub {
            my $sereal_data = $db->get('SwitchConfig');
            Sereal::Decoder::sereal_decode_with_object($decoder, $sereal_data, my $data);
            Data::Swap::swap(\%SwitchConfig, $data);
        },
        "ZeroCopy Version" => sub {
            $db->get('SwitchConfig', my $sereal_data);
            my $version = Sereal::Decoder::sereal_decode_only_header_with_object($decoder, $sereal_data);
            if($version != $SwitchConfig{__version}) {
                Sereal::Decoder::sereal_decode_with_object($decoder, $sereal_data, my $data);
                Data::Swap::swap(\%SwitchConfig, $data);
                undef $data;
            }
        },
        "ZeroCopy Version no undef" => sub {
            $db->get('SwitchConfig', my $sereal_data);
            my $version = Sereal::Decoder::sereal_decode_only_header_with_object($decoder, $sereal_data);
            if($version != $SwitchConfig{__version}) {
                Sereal::Decoder::sereal_decode_with_object($decoder, $sereal_data, my $data);
                Data::Swap::swap(\%SwitchConfig, $data);
            }
        },
        "Copy Version" => sub {
            my $sereal_data = $db->get('SwitchConfig');
            my $version = Sereal::Decoder::sereal_decode_only_header_with_object($decoder, $sereal_data);
            if($version != $SwitchConfig{__version}) {
                Sereal::Decoder::sereal_decode_with_object($decoder, $sereal_data, my $data);
                Data::Swap::swap(\%SwitchConfig, $data);
                undef $data;
                undef $sereal_data;
            }
        },
        "Copy Version No undef" => sub {
            my $sereal_data = $db->get('SwitchConfig');
            my $version = Sereal::Decoder::sereal_decode_only_header_with_object($decoder, $sereal_data);
            if($version != $SwitchConfig{__version}) {
                Sereal::Decoder::sereal_decode_with_object($decoder, $sereal_data, my $data);
                Data::Swap::swap(\%SwitchConfig, $data);
            }
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

