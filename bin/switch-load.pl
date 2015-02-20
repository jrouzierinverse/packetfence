#!/usr/bin/perl
=head1 NAME

load add documentation

=cut

=head1 DESCRIPTION

load

=cut

use strict;
use warnings;
use lib qw(/usr/local/pf/lib);
use pf::ConfigStore::Switch;
use pf::RoseDB::Switch;

while (my ($id, $sw) = each %SwitchConfig) {
    for my $f (keys %$sw) {
        if ($f =~ /(Vlan|Role|AccessList)$/) {
            delete $sw->{$f};
            next;
        }
        my $v = $sw->{$f};
        if (ref( $v) eq 'ARRAY') {
            $sw->{$f} = join(",",@$v);
            next;
        }
        if (ref( $v) eq 'HASH') {
            $sw->{$f} = join(",",%$v);
            next;
        }
    }
    my $switch = pf::RoseDB::Switch->new(%$sw, id => $id);
    $switch->load( speculative => 1);
    $switch->save;
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

