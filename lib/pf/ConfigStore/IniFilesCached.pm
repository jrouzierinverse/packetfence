package pf::ConfigStore::IniFilesCached;

=head1 NAME

pf::ConfigStore::IniFilesCached

=cut

=head1 DESCRIPTION

pf::ConfigStore::IniFilesCached

Is the Base class for using

=cut

use Moo;
use namespace::autoclean;
use pf::IniFiles;
use Log::Log4perl qw(get_logger);
use List::MoreUtils qw(uniq);
use pf::LMDB::Config;
use LMDB_File qw(MDB_CREATE MDB_SUCCESS);
use Sereal::Encoder qw(sereal_encode_with_object);
use Scalar::Util qw(refaddr reftype tainted blessed);
use List::MoreUtils qw(any firstval uniq);
use JSON::XS;

my $ENCODER = Sereal::Encoder->new();

=head1 FIELDS

=head2 inifileConfig

=cut

has inifileConfig =>
  (
   is => 'ro',
   lazy => 1,
   isa => sub {pf::IniFile->isa($_[0])},
   builder => '_build_inifileConfig',
);

has configFile => ( is => 'ro');

has default_section => ( is => 'ro');

has storeNameSpace => ( is => 'ro', required => 1);


=head1 METHODS

=head2 validId

validates id

=cut

sub validId { 1; }

=head2 validParam

validate parameter

=cut

sub validParam { 1; }

=head2 _build_inifileConfig

Build the pf::IniFile object

=cut

sub _build_inifileConfig {
    my ($self) = @_;
    my @args = (-file => $self->configFile, -allowempty => 1);
    push @args, -default => $self->default_section if defined $self->default_section;
    return pf::IniFiles->new(@args);
}

=head2 rollback

Rollback changes that were made

=cut

sub rollback {
    my ($self) = @_;
}

=head2 rewriteConfig

Save the cached config

=cut

sub rewriteConfig {
    my ($self) = @_;
    my $config = $self->inifileConfig;
    return $config->RewriteConfig();
}

=head2 readAllIds

Get all the sections names

=cut

sub readAllIds {
    my ($self,$itemKey) = @_;
    my @sections = $self->_Sections();
    return \@sections;
}

=head2 readAll

Get all the sections as an array of hash refs

=cut

sub readAll {
    my ($self,$idKey) = @_;
    my $config = $self->inifileConfig;
    my $default_section = $config->{default} if exists $config->{default};
    my @sections;
    foreach my $id ($self->_Sections()) {
        my $section = $self->read($id,$idKey);
        if (defined $default_section &&  $id eq $default_section ) {
            unshift @sections, $section;
        } else {
            push @sections,$section;
        }
    }
    return \@sections;
}

=head2 _Section

The sections for the configurations

=cut

sub _Sections {
    my ($self) = @_;
    return $self->inifileConfig->Sections();
}

=head2 hasId

If config has a section

=cut

sub hasId {
    my ($self, $id ) = @_;
    my $config = $self->inifileConfig;
    $id = $self->_formatId($id);
    return $config->SectionExists($id);
}

=head2 _formatId

format the id

=cut

sub _formatId { return $_[1]; }

=head2 read

reads a section

=cut

sub read {
    my ($self, $id, $idKey ) = @_;
    my $data;
    my $config = $self->inifileConfig;
    $id = $self->_formatId($id);
    if ( $config->SectionExists($id) ) {
        $data = {};
        my @default_params = $config->Parameters($config->{default}) if exists $config->{default};
        $data->{$idKey} = $id if defined $idKey;
        foreach my $param (uniq $config->Parameters($id),@default_params) {
            my $val;
            my @vals = $config->val($id, $param);
            if (@vals == 1 ) {
                $val = $vals[0];
            } else {
                $val = \@vals;
            }
            $data->{$param} = $val;
        }
        $self->cleanupAfterRead($id,$data);
    }
    return $data;
}

=head2 update

Update/edit/modify an existing section

=cut

sub update {
    my ($self, $id, $assignments) = @_;
    my $result;
    if ($id ne 'all') {
        my $config = $self->inifileConfig;
        my $real_id = $self->_formatId($id);
        if ( $result = $config->SectionExists($real_id) ) {
            $self->cleanupBeforeCommit($id, $assignments);
            $self->_update_section($real_id, $assignments);
        }
    }
    return $result;
}

sub _update_section {
    my ($self, $section, $assignments) = @_;
    my $config = $self->inifileConfig;
    my $default_section = $config->{default} if exists $config->{default};
    my $imported = $config->{imported} if exists $config->{imported};
    my $use_default = $default_section && $section ne $default_section;
    while ( my ($param, $value) = each %$assignments ) {
        my $param_exists = $config->exists($section, $param);
        my $default_value = $config->val($default_section,$param) if ($use_default);
        if(defined $value ) { #If value is defined the update or add to section
            if ( $param_exists ) {
                #If value is defined the update or add to section
                #Only set the value if not equal to the default value otherwise delete it
                if ( defined $default_value && $default_value eq $value) {
                    $config->delval($section, $param, $value);
                } else {
                    $config->setval($section, $param, $value);
                }
            } else {
                #If the value is the same as the default value then do not add
                next if defined $default_value && $default_value eq $value;
                $config->newval($section, $param, $value);
            }
        } else { #Handle deleting param from section
            #if the param exists in the imported config then use that the value in the imported file
            if ( defined $default_value ) {
                $config->setval($section, $param, $default_value);
            } elsif ( $imported && $imported->exists($section, $param) ) {
                $config->setval($section, $param, $imported->val($section, $param));
            } elsif ( $param_exists ) {
                #
                $config->delval($section, $param);
            }
        }
    }
}


=head2 create

To create new section

=cut

sub create {
    my ($self, $id, $assignments) = @_;
    my $config = $self->inifileConfig;
    my $result;
    if ($self->validId($id)) {
        my $real_id = $self->_formatId($id);
        if($result = !$config->SectionExists($id) ) {
            $self->cleanupBeforeCommit($id, $assignments);
            $config->AddSection($real_id);
            $self->_update_section($real_id, $assignments);
        }
    }
    return $result;
}

=head2 update_or_create

=cut

sub update_or_create {
    my ($self, $id, $assignments) = @_;
    if ( $self->hasId($id) ) {
        return $self->update($id, $assignments);
    } else {
        return $self->create($id, $assignments);
    }
}


=head2 remove

Removes an existing item

=cut

sub remove {
    my ($self, $id) = @_;
    return $self->inifileConfig->DeleteSection($self->_formatId($id));
}

=head2 Copy

Copies a section

=cut

sub copy {
    my ($self,$from,$to) = @_;
    my $result;
    if ($self->validId($to)) {
        $result = $self->inifileConfig->CopySection($self->_formatId($from),$self->_formatId($to));
    }
    return $result;
}

=head2 renameItem

=cut

sub renameItem {
    my ( $self, $old, $new ) = @_;
    my $result;
    if ($self->validId($new)) {
        $result = $self->inifileConfig->RenameSection($self->_formatId($old),$self->_formatId($new));
    }
    return $result;
}

=head2 sortItems

Sorting the items

=cut

sub sortItems {
    my ( $self, $sections ) = @_;
    return $self->inifileConfig->ResortSections(map { $_ = $self->_formatId($_) } @$sections);
}

=head2 cleanupAfterRead

=cut

sub cleanupAfterRead { }

=head2 cleanupBeforeCommit

=cut

sub cleanupBeforeCommit { }

=head2 expand_list

=cut

sub expand_list {
    my ( $self,$object,@columns ) = @_;
    foreach my $column (@columns) {
        if (exists $object->{$column}) {
            $object->{$column} = [ $self->split_list($object->{$column}) ];
        }
    }
}

sub split_list {
    my ($self,$list) = @_;
    return split(/\s*,\s*/,$list);
}

sub join_list {
    my ($self,@list) = @_;
    return join(',',@list);
}

=head2 flatten_list

=cut

sub flatten_list {
    my ( $self,$object,@columns ) = @_;
    foreach my $column (@columns) {
        if (exists $object->{$column} && ref($object->{$column}) eq 'ARRAY') {
            $object->{$column} = $self->join_list(@{$object->{$column}});
        }
    }
}

=head2 commit

=cut

sub commit {
    my ($self) = @_;
    my $result;
    eval {
        $result = $self->rewriteConfig();
        $self->populateCache();
    };
    get_logger->error($@) if $@;
    unless($result) {
        $self->rollback();
    }
    return $result;
}

=head2 search

=cut

sub search {
    my ($self, $field, $value) = @_;
    return grep { exists $_->{$field} && defined $_->{$field} && $_->{$field} eq $value  } @{$self->readAll};

}

=head2 populateCache

=cut

sub populateCache {
    my ($self) = @_;
    my %hash;
    $self->populateHash(\%hash);
    $self->storeIntoCache(\%hash);
}

=head2 populateHash

populate a hash with all the section and data and cleaning up the whitespace

=cut

sub populateHash {
    my ($self, $hash) = @_;
    my $inifileConfig = $self->inifileConfig;
    $self->toHash($inifileConfig, $hash);
    $self->cleanupWhitespace($hash);
    $self->prepareHashForStorage($hash);
}

=head2 prepareHashForStorage

prepares/messages the data in hash before it is stored

=cut

sub prepareHashForStorage {
    my ($self,$hash) = @_;
    return ;
}

=head2 toHash

Copy configuration to a hash

=cut

sub toHash {
    my ($self, $inifileConfig, $hash) = @_;
    %$hash = ();
    my @default_parms;
    if (exists $inifileConfig->{default} ) {
        @default_parms = $inifileConfig->Parameters($inifileConfig->{default});
    }
    foreach my $section ($inifileConfig->Sections()) {
        my %data;
        foreach my $param ( map { untaint_value($_) } uniq $inifileConfig->Parameters($section), @default_parms) {
            my $val = $inifileConfig->val($section, $param);
            $data{$param} = untaint($val);
        }
        $hash->{$section} = \%data;
    }
}

sub untaint_value {
    my $val = shift;
    if (defined $val && $val =~ /^(.*)$/) {
        return $1;
    }
}

sub untaint {
    my $val = $_[0];
    if (tainted($val)) {
        $val = untaint_value($val);
    } elsif (my $type = reftype($val)) {
        if ($type eq 'ARRAY') {
            foreach my $element (@$val) {
                $element = untaint($element);
            }
        } elsif ($type eq 'HASH') {
            foreach my $element (values %$val) {
                $element = untaint($element);
            }
        }
    }
    return $val;
}

=head2 cleanupWhitespace

Clean up whitespace is a utility function for cleaning up whitespaces for hashes

=cut

sub cleanupWhitespace {
    my ($self,$hash) = @_;
    foreach my $data (values %$hash ) {
        foreach my $key (keys %$data) {
            next unless defined $data->{$key};
            $data->{$key} =~ s/\s+$//;
        }
    }
}

=head2 storeIntoCache

store hash

=cut

sub storeIntoCache {
    my ($self,$hash) = @_;
    my $txn = $pf::LMDB::Config::LMDB_ENV->BeginTxn();

    unless($txn) {
        #Log some error here
        return;
    }
    my $db = $txn->OpenDB($self->storeNameSpace,MDB_CREATE);
    unless($db) {
        #Log some error here
        return;
    }
    $db->drop;
    my $txn_id = $txn->id;
    while ( my ($key,$value) = each %$hash) {
       my $data = sereal_encode_with_object($ENCODER,$value,$txn_id);
       $db->put($key,$data);
    }
    $txn->commit();
    return $LMDB_File::last_err == MDB_SUCCESS;
}

__PACKAGE__->meta->make_immutable;

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

