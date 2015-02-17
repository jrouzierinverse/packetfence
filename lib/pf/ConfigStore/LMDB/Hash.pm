package pf::ConfigStore::LMDB::Hash;
=head1 NAME

pf::ConfigStore::LMDB::Hash add documentation

=cut

=head1 DESCRIPTION

pf::ConfigStore::LMDB::Hash

=cut

use strict;
use warnings;
use Tie::Hash;
use Moo;
use LMDB_File qw(MDB_RDONLY MDB_FIRST MDB_NEXT MDB_SUCCESS);
use pf::ConfigStore::LMDB;
use Sereal::Decoder qw(sereal_decode_with_object sereal_decode_with_header_with_object);

my $DECODER = Sereal::Decoder->new;

has dbName => ( is => 'ro', required => 1);


sub TIEHASH {
    my ($class,@args) = @_;
    return $class->new(@args);
}


=head2 STORE DELETE CLEAR SCALAR

These methods are noops

=cut

sub STORE  { }

sub DELETE { }

sub CLEAR { }

sub SCALAR { }


sub FETCH {
    my ($self,$key) = @_;
    my ($txn,$db,$cursor) = @{$self->{_cursor} || []};
    unless($txn) {
        $txn = $pf::ConfigStore::LMDB::ENV->BeginTxn(MDB_RDONLY);
        $db = $txn->OpenDB($self->dbName);
        $db->ReadMode(1);
    }
    $db->get($key, my $sereal_data);
    return if $LMDB_File::last_err;
    sereal_decode_with_header_with_object($DECODER, $sereal_data, my $value, my $header);
    return $value;
}

sub FIRSTKEY {
    my ($self) = @_;
    my $txn = $pf::ConfigStore::LMDB::ENV->BeginTxn(MDB_RDONLY);
    my $db = $txn->OpenDB($self->dbName);
    my $cursor = $db->Cursor;
    $cursor->get( my $key, my $sereal_data, MDB_FIRST);
    return if $LMDB_File::last_err;
    $self->{_cursor} = [$txn,$db,$cursor];
    return $key;
}

sub NEXTKEY {
    my ($self,$last_key) = @_;
    my ($txn,$db,$cursor) = @{$self->{_cursor}};
    $cursor->get(my $key, my $sereal_data, MDB_NEXT);
    if($LMDB_File::last_err) {
        delete $self->{_cursor};
        $cursor = undef;
        $db = undef;
        $txn = undef;
        return;
    }
    return $key;
}

sub EXISTS {
    my ($self,$key) = @_;
    my $txn = $pf::ConfigStore::LMDB::ENV->BeginTxn(MDB_RDONLY);
    my $db = $txn->OpenDB($self->dbName);
    $db->ReadMode(1);
    $db->get($key, my $sereal_data);
    $db = undef;
    $txn = undef;
    return $LMDB_File::last_err == 0;
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

