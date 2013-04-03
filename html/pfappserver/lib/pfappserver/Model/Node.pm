package pfappserver::Model::Node;

=head1 NAME

pfappserver::Model::Node - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=cut

use strict;
use warnings;

use Moose;
use namespace::autoclean;
use Time::localtime;
use Time::Local;

use pf::accounting qw(
    node_accounting_view
    node_accounting_daily_bw node_accounting_weekly_bw node_accounting_monthly_bw node_accounting_yearly_bw
    node_accounting_daily_time node_accounting_weekly_time node_accounting_monthly_time node_accounting_yearly_time
);
use pf::config;
use pf::error qw(is_error is_success);
use pf::node;
use pf::iplog;
use pf::locationlog;
use pf::node;
use pf::os;
use pf::useragent qw(node_useragent_view);
use pf::util;

=head1 METHODS

=over

=item exists

=cut

sub exists {
    my ( $self, $mac ) = @_;

    my $logger = Log::Log4perl::get_logger(__PACKAGE__);
    my ($status, $result) = ($STATUS::OK);

    eval {
        $result = node_exist($mac);
    };
    if ($@) {
        $result = "Can't validate node ($mac) from database.";
        $status = $STATUS::INTERNAL_SERVER_ERROR;
        $logger->error($@);
    }
    unless ($result) {
        $result = "Node $mac was not found.";
        $status = $STATUS::NOT_FOUND;
        $logger->warn($result);
    }

    return ($status, $result);
}

=item field_names

=cut

sub field_names {
    return [qw(mac computer_name pid status dhcp_fingerprint)];
}

=item countAll

=cut

sub countAll {
    my ( $self, %params ) = @_;

    my $logger = Log::Log4perl::get_logger(__PACKAGE__);
    my ($status, $status_msg);

    my $count;
    eval {
        my @result = node_count_all(undef, %params);
        $count = pop @result;
    };
    if ($@) {
        $status_msg = "Can't count nodes from database.";
        $logger->error($status_msg);
        return ($STATUS::INTERNAL_SERVER_ERROR, $status_msg);
    }

    return ($STATUS::OK, $count->{nb});
}

=item search

=cut

sub search {
    my ( $self, %params ) = @_;

    my $logger = Log::Log4perl::get_logger(__PACKAGE__);
    my ($status, $status_msg);

    my @nodes;
    eval {
        @nodes = node_view_all(undef, %params);
        @nodes = grep { keys %$_ ? $_ : undef } @nodes;
    };
    if ($@) {
        $status_msg = "Can't fetch nodes from database.";
        $logger->error($status_msg);
        return ($STATUS::INTERNAL_SERVER_ERROR, $status_msg);
    }

    return ($STATUS::OK, \@nodes);
}

=item read

From pf::lookup::node::lookup_node()

=cut

sub read {
    my ($self, $mac) = @_;

    my $logger = Log::Log4perl::get_logger(__PACKAGE__);
    my ($status, $status_msg);

    my $node = {};
    eval {
        $node = node_view($mac);
        $node->{vendor} = oui_to_vendor($mac);
        for my $date (qw(regdate unregdate)) {
            my $timestamp = "${date}_timestamp";
            if ($node->{$timestamp}) {
                my @date_data = CORE::localtime($node->{$timestamp});
                $node->{$date} = POSIX::strftime("%Y-%m-%d %H:%M", @date_data);
            }
        }
        foreach (qw[regdate unregdate]) {
            $node->{$_} = '' if exists $node->{$_} &&  $node->{$_} eq '0000-00-00 00:00:00';
        }

        # Show 802.1X username only if connection is of type EAP
        my $connection_type = str_to_connection_type($node->{last_connection_type}) if ($node->{last_connection_type});
        unless ($connection_type && ($connection_type & $EAP) == $EAP) {
            delete $node->{last_dot1x_username};
        }

        # Fetch IP information
        $node->{iplog} = iplog_view_open_mac($mac);

        # Fetch the IP activity of the past 14 days
        my $start_time = time() - 14 * 24 * 60 * 60;
        my $end_time = time();
        my @iplog_history = iplog_history_mac($mac,
                                              (start_time => $start_time, end_time => $end_time));
        $node->{iplog}->{history} = \@iplog_history;
        _graphIplogHistory($node, $start_time, $end_time);

        if ($node->{iplog}->{'ip'}) {
            $node->{iplog}->{active} = 1;
        } else {
            my $last_iplog = pop @iplog_history;
            $node->{iplog}->{ip} = $last_iplog->{ip};
            $node->{iplog}->{end_time} = $last_iplog->{end_time};
        }

        #my @locationlog_history = locationlog_history_mac($mac,
        #                                                  (start_time => $start_time, end_time => $end_time));

        # Fetch user-agent information
        if ($node->{user_agent}) {
            $node->{useragent} = node_useragent_view($mac);
        }

        # Fetch DHCP fingerprint information
        if ($node->{'dhcp_fingerprint'}) {
            my @fingerprint_info = dhcp_fingerprint_view( $node->{'dhcp_fingerprint'} );
            $node->{dhcp} = pop @fingerprint_info;
        }

        #    my $node_accounting = node_accounting_view($mac);
        #    if (defined($node_accounting->{'mac'})) {
        #        my $daily_bw = node_accounting_daily_bw($mac);
        #        my $weekly_bw = node_accounting_weekly_bw($mac);
        #        my $monthly_bw = node_accounting_monthly_bw($mac);
        #        my $yearly_bw = node_accounting_yearly_bw($mac);
        #        my $daily_time = node_accounting_daily_time($mac);
        #        my $weekly_time = node_accounting_weekly_time($mac);
        #        my $monthly_time = node_accounting_monthly_time($mac);
        #        my $yearly_time = node_accounting_yearly_time($mac);
        #    }
    };
    if ($@) {
        $status_msg = "Can't retrieve node ($mac) from database.";
        $logger->error($@);
        return ($STATUS::INTERNAL_SERVER_ERROR, $status_msg);
    }

    use Data::Dumper; print Dumper $node;

    return ($STATUS::OK, $node);
}

=item update

=cut

sub update {
    my ( $self, $mac, $node_ref ) = @_;

    my $logger = Log::Log4perl::get_logger(__PACKAGE__);
    my ($status, $status_msg) = ($STATUS::OK);

    unless (node_modify($mac, %{$node_ref})) {
        $status = $STATUS::INTERNAL_SERVER_ERROR;
        $status_msg = 'An error occurred while saving the node.';
    }

    return ($status, $status_msg);
}

=item delete

=cut

sub delete {
    my ($self, $mac) = @_;

    my $logger = Log::Log4perl::get_logger(__PACKAGE__);
    my ($status, $status_msg) = ($STATUS::OK);

    unless (node_delete($mac)) {
        $status = $STATUS::INTERNAL_SERVER_ERROR;
        $status_msg = "The node can't be deleted.";
    }

    return ($status, $status_msg);
}

=item availableStatus

=cut

sub availableStatus {
    my ( $self ) = @_;

    return [ $pf::node::STATUS_REGISTERED,
             $pf::node::STATUS_UNREGISTERED,
             $pf::node::STATUS_PENDING,
             $pf::node::STATUS_GRACE ];
}

=item _graphIplogHistory

=cut

sub _graphIplogHistory {
    my ($node_ref, $start_time, $end_time) = @_;

    my $logger = Log::Log4perl::get_logger(__PACKAGE__);

    if ($node_ref->{iplog}->{history} && scalar @{$node_ref->{iplog}->{history}}) {
        my $now = localtime();
        my @xlabels = ();
        my @ylabels = ('AM', 'PM');
        my %dates = ();
        my %series = ();

        my ($log, $start_tm, $end_tm);
        foreach $log (@{$node_ref->{iplog}->{history}}) {
            $start_tm = localtime($log->{start_timestamp});
            $end_tm = localtime($log->{end_timestamp});

            $end_tm = $now if (!$log->{end_timestamp} ||
                               $end_tm->year > $now->year ||
                               $end_tm->year == $now->year && $end_tm->mon > $now->mon ||
                               $end_tm->year == $now->year && $end_tm->mon == $now->mon && $end_tm->mday > $now->mday);

            # Split periods in half-days:
            #   AM = 0:00 - 11:59
            #   PM = 12:00 - 23:59
            my $last_hday;
            do {
                $last_hday = 0;
                my $hday = 'AM';
                my $until = 12;

                if ($start_tm->hour >= 12) {
                    $hday = 'PM';
                    $until = 24;
                }
                if ($start_tm->mday == $end_tm->mday &&
                    $start_tm->mon  == $end_tm->mon  &&
                    $start_tm->year == $end_tm->year &&
                    $until > $end_tm->hour) {
                    # This is the last half-day
                    $until = $end_tm->hour;
                    $last_hday = 1;
                }

                my $nb_hours = $until - $start_tm->hour;
                $nb_hours++ unless ($nb_hours > 0);

                my $day = sprintf "%d-%02d-%02d", $start_tm->year+1900, $start_tm->mon+1, $start_tm->mday;
                $dates{$day}          = {} unless ($dates{$day});
                $dates{$day}->{$hday} = 0  unless ($dates{$day}->{$hday});
                $dates{$day}->{$hday} += $nb_hours;

                unless ($last_hday) {
                    # Compute next half-day
                    # The time manipulation is required to not be affected by DST changes
                    my $TIME = timelocal(0, 59, ($until - 1), $start_tm->mday, $start_tm->mon, $start_tm->year+1900);
                    $TIME = $TIME + 60;
                    $start_tm = localtime($TIME);
                }
            } while ($last_hday == 0);
        }

        # Fill the gaps for the period
        $start_tm = localtime($start_time);
        $end_tm = localtime($end_time);

        my $day = sprintf "%d-%02d-%02d", $start_tm->year+1900, $start_tm->mon+1, $start_tm->mday;
        my $end_day = sprintf "%d-%02d-%02d", $end_tm->year+1900, $end_tm->mon+1, $end_tm->mday;

        $series{'AM'} = [];
        $series{'PM'} = [];

        my $last = 0;
        do {
            push(@xlabels, $day);

            foreach my $hday (@ylabels) {
                $dates{$day} = {} unless ($dates{$day});
                unless ($dates{$day}->{$hday}) {
                    $dates{$day}->{$hday} = 0;
                }
                elsif ($dates{$day}->{$hday} > 12) {
                    $dates{$day}->{$hday} = 12 ;
                }
                push(@{$series{$hday}}, $dates{$day}->{$hday});
                $logger->debug("$day $hday : " . $dates{$day}->{$hday});
            }
            if ($day ne $end_day) {
                # Compute next day
                my $TIME = timelocal(0, 0, 12, $start_tm->mday, $start_tm->mon, $start_tm->year+1900);
                $TIME = $TIME + 24 * 60 * 60;
                $start_tm = localtime($TIME);
                $day = sprintf "%d-%02d-%02d", $start_tm->year+1900, $start_tm->mon+1, $start_tm->mday;
            }
            else {
                $last = 1;
            }
        } while ($last == 0);

        $node_ref->{iplog}->{xlabels} = \@xlabels;
        $node_ref->{iplog}->{ylabels} = \@ylabels;
        $node_ref->{iplog}->{series} = \%series;
        delete $node_ref->{iplog}->{history};
    }
}

=back

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2013 Inverse inc.

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

__PACKAGE__->meta->make_immutable;

1;
