package pf::LMDB::Config;
=head1 NAME

pf::LMDB::Config add documentation

=cut

=head1 DESCRIPTION

pf::LMDB::Config

=cut

use strict;
use warnings;
use LMDB_File qw(MDB_RDONLY MDB_NOTLS);
use Sereal::Decoder;
use Data::Swap;
use Moo;
$LMDB_File::die_on_err = 0;

my $DECODER = Sereal::Decoder->new;

our $LAST_TXN_ID = 0;

our $LMDB_ENV;

openEnv();

sub openEnv {
    unless (defined $LMDB_ENV) {
        $LMDB_ENV = LMDB::Env->new(
            "/usr/local/pf/var/cache",
            {   mapsize    => 200 * 1024 * 1024,    # Plenty space, don't worry
                maxdbs     => 20,                   # Some databases
                mode       => 0660,
                flags      => MDB_NOTLS,
                maxreaders => 1022,
                # More options
            }
        );
    }
}

sub closeEnv {
    $LMDB_ENV = undef;
}

sub getFromDb {
    my ($txn, $dbname, $key) = @_;
    my $db = $txn->OpenDB($dbname);
    $db->ReadMode(1);
    $db->get($key, my $sereal_data);
    if ($sereal_data) {
        Sereal::Decoder::sereal_decode_with_object($DECODER, $sereal_data, my $value);
        return $value;
    }
    return;
}

sub updateHashFromDb {
    my ($txn,$dbname,$key,$hashref) = @_;
    my $last_txn_id = $hashref->{__last_txn_id} || 0;
    my $txn_id = $txn->id;
    if ($last_txn_id != $txn_id) {
        my $db = $txn->OpenDB($dbname);
        $db->ReadMode(1);
        $db->get($key, my $sereal_data);
        if ($sereal_data) {
            my $version = Sereal::Decoder::sereal_decode_only_header_with_object($DECODER, $sereal_data);
            if ($version != $hashref->{__version}) {
                Sereal::Decoder::sereal_decode_with_object($DECODER, $sereal_data, my $value);
                Data::Swap::swap($hashref, $value);
                undef $value;
            }
            $hashref->{__last_txn_id} = $txn_id;
        }
    }
}

=head2 updateValueInCacheFromDb

Updates the entry in the in memory hash if the value was changed

=cut

sub updateValueInCacheFromDb {
    my ($txn, $dbname, $key, $cachehash) = @_;
    my $sereal_data;
    my $txn_id = $txn->id;
    if (exists $cachehash->{$key}) {
        my $value = $cachehash->{$key};
        #Check if the transaction has since last time
        if ($value->{__last_txn_id} != $txn_id) {
            my $db = $txn->OpenDB($dbname);

            $db->get($key, my $data);
            if ($data) {
                #Get the version of the data from the sereal header
                my $version = Sereal::Decoder::sereal_decode_only_header_with_object($DECODER, $data);
                #If the version does not match then update the hash
                if ($value->{__version} != $version) {
                    Sereal::Decoder::sereal_decode_with_object($DECODER, $sereal_data, my $new_value);
                    #Swap the contents of the hash
                    Data::Swap::swap($value, $new_value);
                }
                #Update the last txn id so we do not need to check this entry again for the same transaction
                $value->{__last_txn_id} = $txn_id;
            } else {
                delete $cachehash->{$key};
            }
        }
    }
    else {
        my $db = $txn->OpenDB($dbname);
        $db->get($key, my $data);
        if ($data) {
            Sereal::Decoder::sereal_decode_with_object($DECODER, $data, my $value);
            $value->{__last_txn_id} = $txn_id;
            $cachehash->{$key} = $value;
        }
    }
}

END {
    $LMDB_ENV = undef;
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

