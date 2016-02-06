package pf::StatsD;

=head1 NAME

pf::StatsD - PacketFence StatsD support

=cut

=head1 DESCRIPTION

pf::StatsD  contains the code necessary to create a Global StatsD object.


=head1 CONFIGURATION AND ENVIRONMENT

Read the following configuration files: F<pf.conf.defaults>

=cut

use strict;
use warnings;
use Carp;
use base "Etsy::StatsD";
use Sys::Hostname;
use POSIX;
use Readonly;

our $VERSION = 1.000000;
our @EXPORT = qw($statsd);
our $statsd;

Readonly my $GRAPHITE_DELIMITER => ".";
Readonly my $STATSD_DELIMITER   => ":";
Readonly my $STATSD_HOST   => "127.0.0.1";
Readonly my $STATSD_PORT   => 8125;

initStatsd();

# we override new to add a "hostname" attribute.
sub new {
    my ( $class, $host, $port, $sample_rate ) = @_;
    $host = $STATSD_HOST unless defined $host;
    $port = $STATSD_PORT unless defined $port;
    my $hostname = hostname;
    $hostname =~ s/\Q$GRAPHITE_DELIMITER\E/_/g; # replace dots with underscores

    my $sock = new IO::Socket::INET(
        PeerAddr => $host,
        PeerPort => $port,
        Proto    => 'udp',
    ) or croak "Failed to initialize socket: $!";

    bless { hostname => $hostname, socket => $sock, sample_rate => $sample_rate }, $class;
}

sub initStatsd {
    my $host = $STATSD_HOST;
    my $port = $STATSD_PORT;

    # we need to make sure the host and port are not tainted.
    ($host) = $host =~ m/^(.*)$/;
    ($port) = $port =~ m/^(.*)$/;

    $statsd = __PACKAGE__->new( $host, $port, );
}

=head2 closeStatsd

Close the statsd socket

=cut

sub closeStatsd {
    if(defined $statsd) {
        $statsd->{'socket'}->close();
        $statsd = undef;
    }
}


sub CLONE {
    initStatsd;
}

=head1 METHODS

=over

=item end(STAT, START_TIME, SAMPLE_RATE)

Convenience method to log timing information.
This one wraps timing() by taking a start time and automatically calculating the elapsed time since.
=cut

sub end {
    my ( $self, $stat, $start_time, $sample_rate ) = @_;
    my $end          = Time::HiRes::gettimeofday();
    my $elapsed_time = $end - $start_time;
    $self->timing( $stat, 1000 * $elapsed_time, $sample_rate );
}


=item timing(STAT, TIME, SAMPLE_RATE)

Log timing information

=cut

sub timing {
    my ( $self, $stats, $time, $sample_rate ) = @_;
    $time = ceil $time; # make sure it is at lease == 1
    $self->_prep_and_send($stats, $time, 'ms', $sample_rate);
}

=item increment(STATS, SAMPLE_RATE)

Increment one of more stats counters.

=cut

sub increment {
    my ( $self, $stats, $sample_rate ) = @_;
    $self->_prep_and_send($stats, 1, 'c', $sample_rate);
}

=item decrement(STATS, SAMPLE_RATE)

Decrement one of more stats counters.

=cut

sub decrement {
    my ( $self, $stats, $sample_rate ) = @_;
    $self->_prep_and_send($stats, -1, 'c', $sample_rate);
}

=item gauge(STATS, GAUGE, SAMPLE_RATE)

Set the gauge one or more stats gauge.

=cut

sub gauge {
    my ($self, $stats, $gauge, $sample_rate) = @_;
    $self->_prep_and_send($stats, $gauge, 'g', $sample_rate);
}

=item update(STATS, DELTA, SAMPLE_RATE)

=cut

sub update {
    my ($self, $stats, $delta, $sample_rate) = @_;
    $self->_prep_and_send($stats, $delta, 'c', $sample_rate);
}

=item _prep_and_send

Normalize stats data and send

=cut

sub _prep_and_send {
    my ($self, $stats, $number, $type, $sample_rate) = @_;
    $stats = [$stats] if ref ($stats) ne 'ARRAY';
    return unless @$stats;
    my %data;
    my $prefix = $self->{hostname} . ".";
    my $value = "$number|$type";
    foreach my $stat (@$stats) {
        $stat =~ s/\Q$STATSD_DELIMITER\E/_/g;
        my $key = "${prefix}${stat}";
        $data{$key} = $value;
    }
    $self->send(\%data, $sample_rate);
}

=back

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2016 Inverse inc.

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

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:
