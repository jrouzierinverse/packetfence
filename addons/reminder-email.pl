#!/usr/bin/perl

=head1 NAME

reminder-email.pl add documentation

=head1 DESCRIPTION

reminder-email.pl

=head1 OPTIONS

reminder-email.pl <options>

 Options:
   -h | -? | --help  Show help message
   --man             Show man page
   --expire          The time to expire
   --expire          The time to expire

=cut

use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;

use lib qw(/usr/local/pf/lib);

my %OPTIONS;

GetOptions(
    \%OPTIONS, 
    'help|h|?', 'man', 'expire=s', 'from-email-address=s', 'email-template=s'
) || pod2usage({-verbose => 1, -exitval => 1, -output => \*STDERR});

pod2usage({-verbose => 1, -exitval => 0, -output => \*STDOUT}) if ($OPTIONS{help});

pod2usage({-verbose => 2, -exitval => 0, -output => \*STDOUT}) if ($OPTIONS{man});

my $message = checkOptions(\%OPTIONS);

pod2usage( {-msg => $message, -verbose => 1, -exitval => 2, -output => \*STDERR}) if defined $message;

my @users = getUsersToRemind(\%OPTIONS);

foreach my $user (@users) {
    sendReminderEmail(\%OPTIONS, $user);
}

=head2 getUsersToRemind

=cut

sub getUsersToRemind {
    my ($options) = @_;

}

=head2 getUsersToRemind

=cut

sub getUsersToRemind {
    my ($options, $user) = @_;
}

=head2 checkOptions

=cut

sub checkOptions {
    my ($options) = @_;
    return undef;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2014 Inverse inc.

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

