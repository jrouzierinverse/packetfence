package pf::Base::RoseDB::Switch::Manager;

use strict;

use base qw(pf::Base::RoseDB::Object::Manager);

use pf::Base::RoseDB::Switch;

sub object_class { 'pf::Base::RoseDB::Switch' }

__PACKAGE__->make_manager_methods('switches');

1;

