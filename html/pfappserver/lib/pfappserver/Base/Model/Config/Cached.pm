package pfappserver::Base::Model::Config::Cached;

=head1 NAME

pfappserver::Base::Model::Config::Cached

=cut

=head1 DESCRIPTION

pfappserver::Base::Model::Config::Cached
Is the Generic class for the cached config

=cut

use Moose;
use namespace::autoclean;
use pf::config::cached;
use Log::Log4perl qw(get_logger);

BEGIN { extends 'Catalyst::Model'; }

=head1 FIELDS

=head2 cachedConfig

=cut

has cachedConfig =>
  (
   is => 'ro',
   lazy => 1,
   isa => 'pf::config::cached',
   builder => '_buildCachedConfig'
);

=head2 idKey

=cut

has idKey => ( is => 'ro', default => 'id');

=head2 configFile

=cut

has configFile => ( is => 'ro');


=head1 METHODs

=head2 _buildCachedConfig

=cut

sub _buildCachedConfig {
    my ($self) = @_;
    return pf::config::cached->new(-file => $self->configFile, -allowempty => 1);
}


=head2 readConfig

=cut

sub readConfig {
    my ($self) = @_;
    my $logger = get_logger();
    my ($status, $status_msg);
    my $config = $self->cachedConfig;
    $config->ReadConfig();
    return ($STATUS::OK);
}

=head2 rewriteConfig

Save the cached config

=cut

sub rewriteConfig {
    my ($self) = @_;
    my $logger = get_logger();
    my ($status, $status_msg);
    my $config = $self->cachedConfig;

    unless ($config->RewriteConfig()) {
        $status_msg = "Error Writing Config";
        $logger->warn("$status_msg");
        return ($STATUS::INTERNAL_SERVER_ERROR, $status_msg);
    }

    $status_msg = "Configuration file successfully saved";
    $logger->info("$status_msg");
    return ($STATUS::OK, $status_msg);
}

=head2 readAllIds

Get all the sections names

=cut

sub readAllIds {
    my ($self, $id) = @_;
    my ($status, $status_msg);
    my $config = $self->cachedConfig;
    my @sections = $config->Sections();
    return ($STATUS::OK, \@sections);
}

=head2 readAll

Get all the sections as an array of hash refs

=cut

sub readAll {
    my ( $self) = @_;
    my $logger = get_logger();
    my ($status, $status_msg);
    my $config = $self->cachedConfig;
    my @sections;
    foreach my $id ($config->Sections()) {
        my %section = ( $self->idKey() => $id );
        foreach my $param ($config->Parameters($id)) {
            $section{$param} = $config->val( $id, $param);
        }
        $self->cleanupAfterRead($id,\%section);
        if ($id =~ m/defaults?/) {
            unshift @sections, \%section;
        } else {
            push @sections,\%section;
        }
    }
    return ($STATUS::OK, \@sections);
}

=head2 hasId

If config has a section

=cut

sub hasId {
    my ($self, $id ) = @_;
    my $logger = get_logger();
    my ($status, $status_msg);
    my $config = $self->cachedConfig;
    if ( $config->SectionExists($id) ) {
        $status = $STATUS::OK;
        $status_msg = "\"$id\" found";
    } else {
        $status = $STATUS::NOT_FOUND;
        $status_msg = "\"$id\" does not exists";
        $logger->warn($status_msg);
    }
    $logger->info($status_msg);
    return ($status,$status_msg);
}

=head2 read

reads a section

=cut

sub read {
    my ($self, $id ) = @_;

    my $logger = get_logger();
    my ($status, $result);
    my $config = $self->cachedConfig;

    if ( $config->SectionExists($id) ) {
        my %item = defined($self->idKey) ? ($self->idKey => $id) : ();
        foreach my $param ($config->Parameters($id)) {
            $item{$param} = $config->val( $id, $param);
        }
        $status = $STATUS::OK;
        $result = \%item;
        $self->cleanupAfterRead($id,$result);
    } else {
        $status = $STATUS::NOT_FOUND;
        $result = "\"$id\" does not exists";
        $logger->warn("$result");
    }

    return ($status, $result);
}

=head2 update

Update/edit/modify an existing section

=cut

sub update {
    my ($self, $id, $assignments) = @_;
    my $logger = get_logger();

    my ($status, $status_msg) = ($STATUS::OK, "");
    if ($id eq 'all') {
        $status = $STATUS::FORBIDDEN;
        $status_msg = "This method does not handle \"$id\"";
    }
    else {
        $self->cleanupBeforeCommit($id, $assignments);
        my $config = $self->cachedConfig;
        delete $assignments->{$self->idKey};
        if ( $config->SectionExists($id) ) {
            while ( my ($param, $value) = each %$assignments ) {
                if ( $config->exists($id, $param) ) {
                    if(defined($value)) {
                        $config->setval($id, $param, $value);
                    } else {
                        $config->delval($id, $param);
                    }
                } elsif(defined($value)) {
                    $config->newval($id, $param, $value);
                }
            }
        } else {
            $status_msg = "\"$id\" does not exists";
            $status =  $STATUS::NOT_FOUND;
            $logger->warn("$status_msg");
        }
        $status_msg = "\"$id\" successfully modified";
        $logger->info("$status_msg");
    }
    return ($status, $status_msg);
}

=head2 create

To create

=cut

sub create {
    my ($self, $id, $assignments) = @_;
    my $logger = get_logger();

    my ($status, $status_msg);
    $self->cleanupBeforeCommit($id, $assignments);
    my $config = $self->cachedConfig;

    if ( !$config->SectionExists($id) ) {
        $config->AddSection($id);
        delete $assignments->{$self->idKey};
        while ( my ($param, $value) = each %$assignments ) {
            $config->newval( $id, $param, defined $value ? $value : '' );
        }
        ($status,$status_msg) = ($STATUS::OK,"\"$id\" successfully created");
    } else {
        ($status,$status_msg) = ($STATUS::PRECONDITION_FAILED,"\"$id\" already exists");
        $logger->warn("$status_msg");
    }
    $logger->info("$status_msg");
    return ($status, $status_msg);
}


=head2 remove

Removes an existing item

=cut

sub remove {
    my ($self, $id) = @_;
    my $logger = get_logger();
    my ($status,$status_msg);
    my $config = $self->cachedConfig;

    if ( $config->SectionExists($id) ) {
        $config->DeleteSection($id);
        $status_msg = "\"$id\" successfully deleted";
        $status = $STATUS::OK;
    } else {
        $status = $STATUS::NOT_FOUND;
        $status_msg = "\"$id\" does not exists";
        $logger->warn("$status_msg");
    }

    $logger->info("$status_msg");
    return ($status, $status_msg);
}

=head2 renameItem

=cut

sub renameItem {
    my ( $self, $old, $new ) = @_;
    my $logger = get_logger();
    my ($status,$status_msg);
    my $config = $self->cachedConfig;
    if ( $config->SectionExists($old) ) {
        $config->RenameSection($old,$new);
        $status_msg = "\"$old\" successfully renamed to $new";
        $status = $STATUS::OK;
    } else {
        $status = $STATUS::NOT_FOUND;
        $status_msg = "\"$old\" does not exists";
        $logger->warn("$status_msg");
    }

    $logger->info("$status_msg");
    return ($status,$status_msg);
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
            my @items = split(/\s*,\s*/,$object->{$column});
            $object->{$column} = \@items;
        }
    }
}

=head2 flatten_list

=cut

sub flatten_list {
    my ( $self,$object,@columns ) = @_;
    foreach my $column (@columns) {
        if (exists $object->{$column} && ref($object->{$column}) eq 'ARRAY') {
            $object->{$column} = join(',',@{$object->{$column}});
        }
    }
}


__PACKAGE__->meta->make_immutable;

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

1;

