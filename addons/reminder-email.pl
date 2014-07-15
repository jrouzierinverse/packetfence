#!/usr/bin/perl

=head1 NAME

reminder-email.pl add documentation

=head1 DESCRIPTION

reminder-email.pl

=head1 OPTIONS

reminder-email.pl <options>

 Options:
   -h | -? | --help              Show help message
   --man                         Show man page
   --expire                      How long before the node expires to send the email
   --from-email-address          The from email address
   --email-template              The file path of the email template

=cut

use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use lib qw(/usr/local/pf/lib);
use pf::config;
use Email::Valid;
use Template;
use Template::Parser;
use File::Slurp;
use MIME::Lite::TT;

my %OPTIONS = (
    expire => '1h',
    'from-email-address' => $Config{'alerting'}{'fromaddr'} || 'root@' . $fqdn,
    smtpserver => $Config{'alerting'}{'smtpserver'},
    subject => 'Your time is almost up',
    timeout => 20,
);

GetOptions(\%OPTIONS, 
    'help|h|?', 'man', 'expire=s', 'from-email-address=s',
    'email-template=s', 'subject=s', 'smtpserver=s'
) || pod2usage({-verbose => 1, -exitval => 1, -output => \*STDERR});

pod2usage({-verbose => 1, -exitval => 0, -output => \*STDOUT}) if ($OPTIONS{help});

pod2usage({-verbose => 2, -exitval => 0, -output => \*STDOUT}) if ($OPTIONS{man});

my $message = checkOptions(\%OPTIONS);

pod2usage( {-msg => $message, -verbose => 1, -exitval => 2, -output => \*STDERR}) if defined $message;

my @users = getUsersToRemind(\%OPTIONS);

foreach my $user (@users) {
    sendReminderEmail(\%OPTIONS, $user);
}

=head1 SUBROUTINES

=head2 getUsersToRemind

=cut

sub getUsersToRemind {
    my ($options) = @_;

}

=head2 sendReminderEmail

=cut

sub sendReminderEmail {
    my ($options, $user) = @_;
    my $subject = $options->{subject};

    my $msg = MIME::Lite::TT->new(
        From        =>  $options->{'from-email-address'},
        To          =>  $user->{'email'},
        Subject     =>  encode("MIME-Q", $subject),
        Template    =>  $options->{'email-template'},
        TmplParams  =>  { user => $user },
        TmplUpgrade =>  1,
    );
    $msg->send('smtp', $options->{smtpserver}, Timeout => $options->{timeout});
}

=head2 checkOptions

=cut

sub checkOptions {
    my ($options) = @_;
    my $message;
    my @messages;
    if (exists $options->{'email-template'}) {
        my $email_template = $options->{'email-template'};
        if(-f $email_template) {
            my $parser = Template::Parser->new;
            my $text = read_file($email_template);
            push @messages, "cannot parse template $email_template", $parser->error unless $parser->parse($text);
            
        } else {
            push @messages,"$email_template does not exist";
        }
    } else {
        push @messages,"--email-template is required";
    }
    $message = join("\n",@messages,"") if @messages;
    foreach my $timespec (qw(expire timeout)) {
        $options->{$timespec} = normalize_time($options->{$timespec});
        push @messages,"$timespec is not a valid time spec" unless defined $options->{$timespec};
    }
    my $from_address = $options->{'from-email-address'};
    push @messages, "$from_address is an invaild email address" unless Email::Valid->address($from_address);
    return $message;
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

