package pfconfig::namespaces::FilterEngine::ScanScopes;

=head1 NAME

pfconfig::namespaces::FilterEngine::ScanScopes

=cut

=head1 DESCRIPTION

pfconfig::namespaces::FilterEngine::ScanScopes

=cut

use strict;
use warnings;
use pf::log;
use pfconfig::namespaces::config;
use pfconfig::namespaces::config::ScanFilters;
use pf::condition_parser qw(parse_condition_string);

use base 'pfconfig::namespaces::FilterEngine::AccessScopes';

sub parentConfig {
    my ($self) = @_;
    return pfconfig::namespaces::config::ScanFilters->new($self->{cache});
}

sub build_answer {
    my ($self, $answer) = @_;
    if($answer->{wmi_request_rule}) {
        my ($parsed_condition, $msg) = parse_condition_string($answer->{wmi_request_rule});
        if($parsed_condition) {
            $answer->{engine} = pf::filter_engine->new({
                filters => [pf::filter->new({
                    answer    => $answer,
                    condition => $self->build_filter_condition($parsed_condition)
                })],
            });
        } else {
           get_logger->error("Cannot parse rule '$parsed_condition' : '$msg'");
        }
    }
    return $answer;
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
