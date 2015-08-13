package pf::factory::condition::vlanfilter;

=head1 NAME

pf::factory::condition::vlanfilter

=cut

=head1 DESCRIPTION

pf::factory::condition::vlanfilter

=cut

use strict;
use warnings;
use Module::Pluggable search_path => 'pf::condition', sub_name => '_modules' , require => 1;

our @MODULES;

sub factory_for {'pf::condition'};

our %VLAN_FILTER_TYPE_TO_CONDITION_TYPE = (
    'is'        => 'pf::condition::equals',
    'is_not'    => 'pf::condition::not_equals',
    'match'     => 'pf::condition::matches',
    'match_not' => 'pf::condition::not_matches',
);

our %VLAN_FILTER_KEY_TYPES = (
    'node_info'      => 1,
    'switch'         => 1,
    'owner'          => 1,
    'radius_request' => 1,
);

sub modules {
    my ($class) = @_;
    unless(@MODULES) {
        @MODULES = $class->_modules;
    }
    return @MODULES;
}

__PACKAGE__->modules;

sub instantiate {
    my ($class, $data) = @_;
    my $filter = $data->{filter};
    if ($filter eq 'time') {
        my $c = pf::condition::time_period->new({value => $data->{value}});
        if ($data->{operator} eq 'is_not') {
            return pf::condition::not->new({condition => $c});
        }
        return $c;
    }
    my $sub_condition;
    if (exists $VLAN_FILTER_KEY_TYPES{$filter}) {
        $sub_condition = pf::condition::key->new({
                key       => $data->{attribute},
                condition => _build_sub_condition($data)
        });
    }
    else {
        $sub_condition = _build_sub_condition($data);
    }

    return pf::condition::key->new({
        key => $filter,
        condition => $sub_condition,
    });
}

sub _build_sub_condition {
    my ($data) = @_;
    my $condition_class;
    $condition_class = $VLAN_FILTER_TYPE_TO_CONDITION_TYPE{$data->{operator}};
    return $condition_class->new({value => $data->{value}}) if $condition_class;
    return undef;
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
