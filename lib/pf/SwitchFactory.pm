package pf::SwitchFactory;

=head1 NAME

pf::SwitchFactory - Object oriented factory to instantiate objects

=head1 SYNOPSIS

The pf::SwitchFactory module implements an object oriented factory to
instantiate objects of type pf::Switch or subclasses of this. This module
is meant to read in a switches.conf configuration file containing all
the necessary information needed to actually instantiate the objects.

=cut

use strict;
use warnings;

use Carp;
use pf::log;
use pf::util;
use pf::freeradius;
use pf::file_paths;
use Module::Load;
use Time::HiRes qw(gettimeofday);
use Benchmark qw(:all);
use List::Util qw(first);
use List::MoreUtils qw(any);
use pf::CHI;
use pfconfig::cached_hash;
use pfconfig::cached_array;
use NetAddr::IP;
use pf::StatsD;
use pf::util::statsd qw(called);

our %SwitchConfig;
tie %SwitchConfig, 'pfconfig::cached_hash', 'config::Switch';
my @SwitchRanges;
tie @SwitchRanges, 'pfconfig::cached_array', 'resource::switches_ranges';

#Loading all the switch modules ahead of time
use Module::Pluggable
  search_path => [qw(pf::Switch)],
  'require' => 1,
  sub_name    => 'modules';

our @MODULES;
our %TYPE_TO_MODULE;
our %VENDORS;

=head1 METHODS

=over

=item hasId

Checks if switch id exists

=cut

sub hasId { exists $SwitchConfig{$_[0]} }

=item instantiate - create new pf::Switch (or subclass) object

  $switch = SwitchFactory->instantiate( <switchIdentifier> );

=cut

sub instantiate {
    my ( $class, $switchRequest ) = @_;
    my $start = Time::HiRes::gettimeofday();
    my $logger = get_logger();
    my @requestedSwitches;
    my $requestedSwitch;
    my $switch_ip;
    my $switch_mac;
    my $switch_overlay_cache = pf::CHI->new(namespace => 'switch.overlay');

    if(ref($switchRequest) eq 'HASH') {
        if(exists $switchRequest->{switch_mac} && defined $switchRequest->{switch_mac}) {
            $switch_mac = $switchRequest->{switch_mac};
            push @requestedSwitches,$switch_mac;
        }
        if(exists $switchRequest->{switch_ip} && defined $switchRequest->{switch_ip}) {
            $switch_ip = $switchRequest->{switch_ip};
            push @requestedSwitches,$switch_ip;
        }
    } else {
        @requestedSwitches = ($switchRequest);
        if(valid_ip($switchRequest)) {
            $switch_ip = $switchRequest;
        } elsif (valid_mac($switchRequest)) {
            $switch_mac = $switchRequest;
        }
    }

    my $switch_data;
    foreach my $search (@requestedSwitches){
        if($SwitchConfig{$search}){
            $requestedSwitch = $search;
            $switch_data = $SwitchConfig{$search};
            last;
        }
    }
    if (!$requestedSwitch) {
        #Switch ranges is an order array of [NetAddr::IP object of switch,switch_id]
        if(@SwitchRanges) {
            foreach my $search (@requestedSwitches) {
                next unless (valid_ip($search));
                my $ip = NetAddr::IP->new($search);
                #Find the first switch that matches it's network range
                if (my $rangeConfig = first { $ip->within($_->[0]) } @SwitchRanges) {
                    $requestedSwitch = $search;
                    $switch_data     = $SwitchConfig{$rangeConfig->[1]};
                    last;
                }
            }
        }
    }
    unless (defined($requestedSwitch)) {
        $logger->error("WARNING ! Unknown switch(es) ". join(" ",@requestedSwitches));
        $pf::StatsD::statsd->end(called() . ".timing" , $start, 0.1 );
        return 0;
    }


    if( $switch_mac && $requestedSwitch eq $switch_mac && ref($switchRequest) eq 'HASH' && !defined ($switch_data->{controllerIp}) ) {
        my $switch = $switch_overlay_cache->get($switch_mac) || {};
        my $controllerIp = $switchRequest->{controllerIp};
        if($controllerIp && (  !defined $switch->{controllerIp} || $controllerIp ne $switch->{controllerIp} )) {
            $switch_overlay_cache->set(
                $switch_mac,
                {
                    controllerIp => $controllerIp,
                    ip => $switch_ip
                }
            );
        }
    }


    my $switchOverlay;
    # find the module to instantiate
    $switchOverlay = $switch_overlay_cache->get($requestedSwitch) || {};
    my ($module, $type);
    $type = untaint_chain( $switch_data->{'type'} );
    if ($requestedSwitch ne 'default') {
        $module = getModule($type);
    } else {
        $module = "pf::Switch";
    }
    unless ($module) {
        $logger->error("Can not load perl module for switch $requestedSwitch, type: $type. "
                  . "The type is unknown or the perl module has compilation errors. ");
        $pf::StatsD::statsd->increment(called() . ".error" );
        $pf::StatsD::statsd->end(called() . ".timing" , $start);
        return 0;
    }
    $module = untaint_chain($module);
    # load the module to instantiate

    my $result;
    $logger->debug("creating new $module object");
    $result = $module->new({
         id => $requestedSwitch,
         ip => $switch_ip,
         switchIp => $switch_ip,
         switchMac => $switch_mac,
         %$switch_data,
         %$switchOverlay,
    });

    $pf::StatsD::statsd->end(called() . ".timing" , $start, 0.1 );
    return $result;
}

sub config {
    my %temp = %SwitchConfig;
    return \%temp;
}

=item getModule

Get the module from the type

=cut

sub getModule {
    my ($type) = @_;
    unless(exists $TYPE_TO_MODULE{$type}) {
        my $module = "pf::Switch::$type";
        eval {
            load($module);
        };
        if($@) {
            get_logger->error("Failed to load module $module: @_");
            return undef;
        }
        $TYPE_TO_MODULE{$type} = $module;
    }
    return $TYPE_TO_MODULE{$type};
}

=item buildVendorsList

Build the vendor list

=cut

sub buildVendorsList {
    for my $module (@MODULES) {
        my $switch = $module;
        $switch =~ s/^pf::Switch:://;
        my @p = split /::/, $switch;
        my $vendor = shift @p;
        #Include only concrete classes indictated by the existence of the description method
        if ($module->can('description')) {
            $VENDORS{$vendor} = {} unless ($VENDORS{$vendor});
            $VENDORS{$vendor}->{$switch} = $module->description;
        }
    }
}

=item preLoadModules

pre load modules

=cut

sub preLoadModules {
    unless (@MODULES) {
        require pf::Switch;
        @MODULES        = __PACKAGE__->modules;
        buildTypeToModuleMap();
        buildVendorsList();
    }
}

=item buildTypeToModuleMap

builds the type to module map

=cut

sub buildTypeToModuleMap {
    %TYPE_TO_MODULE = map {
        my $type = $_;
        $type =~ s/^pf::Switch:://;
        $type => $_
      }
      #Include only concrete classes indictated by the existence of the description method
      grep { $_->can('description') } @MODULES;
}

=back

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

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:
