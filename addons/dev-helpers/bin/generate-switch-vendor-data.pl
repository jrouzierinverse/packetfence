#!/usr/bin/perl
use strict;
use warnings;
use lib qw(/usr/local/pf/lib);
use pf::file_paths qw($install_dir);
use Module::Pluggable
  'search_path' => [qw(pf::Switch)],
  'require'     => 1,
  'sub_name'    => 'modules',
  'inner'       => 0, 
;

use Template;
use Data::Dumper;

sub buildOptionsList {
    my %group;
    for my $module (sort __PACKAGE__->modules) {
        my $switch = $module;
        $switch =~ s/^pf::Switch:://;
        my ($vendor, undef) = split /::/, $switch, 2;
        #Include only concrete classes indictated by the existence of the description method
        if ($module->can('description')) {
            $group{$vendor} //= {group => $vendor, value => '', options => []};
            push @{$group{$vendor}{options}}, {value => $switch, label => $module->description};
        }
    }

    return [
        {group => '', value => '', options => [{value => '', label => ''}]},
        (sort { $a->{group} cmp $b->{group} } values %group),
    ];
}

my $options = buildOptionsList();
my $d = Data::Dumper->new([$options], ["*SWITCH_OPTIONS"]);
$d->Indent(1);
$d->{xpad} = "    ";
my $content = "our " . $d->Dump();
my $tt = Template->new({
    OUTPUT_PATH  => "$install_dir",
    INCLUDE_PATH => "$install_dir/addons/dev-helpers/templates",
});

$tt->process(
    "class-wrapper.tt",
    {
        content    => $content,
        class      => "pf::constants::switch_options",
        class_name => "pf::constants::switch_options",
        class_description => '',
    },
    "lib/pf/constants/switch_options.pm",
) or die $tt->error();


