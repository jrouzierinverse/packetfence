#!/usr/bin/perl

=head1 NAME

tie add documentation

=cut

=head1 DESCRIPTION

tie

=cut

use strict;
use warnings;
use lib qw(/usr/local/pf/lib);
use pf::LMDB::Config;
use pf::LMDB::Config::Hash;
use Benchmark qw(:all);
use LMDB_File qw(:all);
use Sereal::Decoder qw(sereal_decode_with_object sereal_decode_with_header_with_object);
use DDP;
my $DECODER = Sereal::Decoder->new;

tie our %SwitchConfig, 'pf::LMDB::Config::Hash' => {dbName => 'switches.conf'};
my @keys = keys %SwitchConfig;
my $key_length = @keys;

timethese(
    -5,
    {
        'Tie' => sub {my $switch = $SwitchConfig{$keys[int(rand($key_length))]}},
        'direct' => sub {
            my $key = $keys[int(rand($key_length))];
            my $switch;
            my $txn = $pf::LMDB::Config::ENV->BeginTxn(MDB_RDONLY);
            my $db  = $txn->OpenDB('switches.conf');
            $db->ReadMode(1);
            $db->get($key, my $sereal_data);
            if( $LMDB_File::last_err == MDB_SUCCESS ) {
                sereal_decode_with_header_with_object($DECODER, $sereal_data, $switch, my $header);
            }
        }
    }
);

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

