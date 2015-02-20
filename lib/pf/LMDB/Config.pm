package pf::LMDB::Config;
=head1 NAME

pf::LMDB::Config add documentation

=cut

=head1 DESCRIPTION

pf::LMDB::Config

=cut

use strict;
use warnings;
use LMDB_File qw(MDB_RDONLY MDB_NOTLS MDB_NOMEMINIT);
use Sereal::Decoder;
use Data::Swap;
use Moo;
$LMDB_File::die_on_err = 0;

our $DECODER = Sereal::Decoder->new;

our $LMDB_ENV;

openEnv();

sub openEnv {
    unless (defined $LMDB_ENV) {
        $LMDB_ENV = LMDB::Env->new(
            "/usr/local/pf/var/cache",
            {   mapsize    => 25 * 1024 * 1024,    # Plenty space, don't worry
                maxdbs     => 20,                  # Some databases should be determined at run time
                mode       => 0660,
                #Do not initialize memory before using it
                #Store lock data in the txn itself instead of the thread tls
                flags      => MDB_NOTLS | MDB_NOMEMINIT,
                maxreaders => 1022,
            }
        );
        die unless defined $LMDB_ENV;
    }
}

sub closeEnv {
    $LMDB_ENV = undef;
}

=head2 resetEnv

closes and reopen the global env

=cut

sub resetEnv {
    closeEnv();
    openEnv();
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

