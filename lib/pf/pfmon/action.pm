package pf::pfmon::action;

=head1 NAME

pf::pfmon::action - the base class for pf::pfmon::action

=cut

=head1 DESCRIPTION

pf::pfmon::action

=cut

use strict;
use warnings;
use Moo;
use pf::config;

has name => (isa => 'rw', required => 1);

has interval_key => (isa => 'rw', lazy => 1, builder => 1);

sub run {
    die "run is not implemented";
}

sub _build_interval_key {
    my ($proto) = @_;
    my $key = ref ($proto) || $proto;
    $key =~ s/^pf::pfmon::action:://;
    return $key;
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
