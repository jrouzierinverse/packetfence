package pfconfig::namespaces::FilterEngine::AccessScopes;

=head1 NAME

pfconfig::namespaces::FilterEngine::AccessScopes

=cut

=head1 DESCRIPTION

pfconfig::namespaces::FilterEngine::AccessScopes

=cut

use strict;
use warnings;
use pf::log;
use pfconfig::namespaces::config;
use pf::factory::condition::access_filter;
use pf::filter;
use pf::filter_engine;
use pf::condition_parser qw(parse_condition_string);

use base 'pfconfig::namespaces::resource';

sub parentConfig {
    my ($self) = @_;
}


sub build {
    my ($self)            = @_;
    my $config   = $self->parentConfig;
    my %AccessFiltersConfig = %{$config->build};
    $self->{prebuilt_conditions} = {};
    my (%AccessScopes, @filter_data, %filters_scopes);
    foreach my $rule (@{$config->{ordered_sections}}) {
        my $logger = get_logger();
        my $data = $AccessFiltersConfig{$rule};
        if ($rule =~ /^\w+:(.*)$/) {
            $logger->info("Building rule '$rule'");
            my ($parsed_conditions, $msg) = parse_condition_string($1);
            next unless defined $parsed_conditions;
            push @filter_data, [$parsed_conditions, $data];
        }
        else {
            $logger->info("Building condition '$rule'");
            $self->{prebuilt_conditions}{$rule} = pf::factory::condition::access_filter->instantiate($data);
        }
    }

    foreach my $filter_data (@filter_data) {
        $self->build_filter(\%filters_scopes, @$filter_data);
    }
    while (my ($scope, $filters) = each %filters_scopes) {
        $AccessScopes{$scope} = pf::filter_engine->new({filters => $filters});
    }
    return \%AccessScopes;
}

sub build_filter {
    my ($self, $filters_scopes, $parsed_conditions, $data) = @_;
    push @{$filters_scopes->{$data->{scope}}}, pf::filter->new({
        answer    => $self->build_answer($data),
        condition => $self->build_filter_condition($parsed_conditions)
    });
}

sub build_answer {
    my ($self, $data) = @_;
    return $data;
}

sub build_filter_condition {
    my ($self, $parsed_condition) = @_;
    if (ref $parsed_condition) {
        local $_;
        my ($type, @parsed_conditions) = @$parsed_condition;
        my $conditions = [map {$self->build_filter_condition($_)} @parsed_conditions];
        if($type eq 'NOT' ) {
            return pf::condition::not->new({condition => $conditions->[0]});
        }
        my $module = $type eq 'AND' ? 'pf::condition::all' : 'pf::condition::any';
        return $module->new({conditions => $conditions});
    }
    else {
        return $self->{prebuilt_conditions}->{$parsed_condition};
    }
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
