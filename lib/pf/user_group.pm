package pf::user_group;

=head1 NAME

pf::user_group -

=cut

=head1 DESCRIPTION

pf::user_group

CRUD operations for user_group table

=cut

use strict;
use warnings;
use constant USER_GROUP => 'user_group';
 
BEGIN {
    use Exporter ();
    our ( @ISA, @EXPORT );
    @ISA = qw(Exporter);
    @EXPORT = qw(
        $user_group_db_prepared
        user_group_db_prepare
        user_group_delete
        user_group_add
        user_group_try_add
        user_group_insert_or_update
        user_group_view
        user_group_count_all
        user_group_view_all
        user_group_custom
        user_group_cleanup
    );
}

use pf::log;
use pf::db;

our $logger = get_logger();

# The next two variables and the _prepare sub are required for database handling magic (see pf::db)
our $user_group_db_prepared = 0;
# in this hash reference we hold the database statements. We pass it to the query handler and he will repopulate
# the hash if required
our $user_group_statements = {};

our @FIELDS = qw(
    name
);

our %HEADINGS = (
    name              => 'name',
);

our $FIELD_LIST = join(", ",@FIELDS);

our $INSERT_LIST = join(", ", ("?") x @FIELDS);

=head1 SUBROUTINES

=head2 user_group_db_prepare()

Prepare the sql statements for user_group table

=cut

sub user_group_db_prepare {
    $logger->debug("Preparing pf::user_group database queries");
    my $dbh = get_db_handle();

    $user_group_statements->{'user_group_add_sql'} = $dbh->prepare(
        qq[ INSERT INTO user_group ( $FIELD_LIST ) VALUES ( $INSERT_LIST ) ]);

    $user_group_statements->{'user_group_try_add_sql'} = $dbh->prepare(
        qq[ INSERT IGNORE INTO user_group ( $FIELD_LIST ) VALUES ( $INSERT_LIST ) ]);

    $user_group_statements->{'user_group_view_sql'} = $dbh->prepare(
        qq[ SELECT user_group_id, $FIELD_LIST FROM user_group WHERE user_group_id = ? ]);

    $user_group_statements->{'user_group_view_all_sql'} = $dbh->prepare(
        qq[ SELECT user_group_id, $FIELD_LIST FROM user_group ORDER BY user_group_id LIMIT ?, ? ]);

    $user_group_statements->{'user_group_count_all_sql'} = $dbh->prepare( qq[ SELECT count(*) as count FROM user_group ]);

    $user_group_statements->{'user_group_delete_sql'} = $dbh->prepare(qq[ delete from user_group where user_group_id = ? ]);

    $user_group_db_prepared = 1;
}

=head2 $success = user_group_delete($id)

Delete a user_group entry

=cut

sub user_group_delete {
    my ($id) = @_;
    db_query_execute(USER_GROUP, $user_group_statements, 'user_group_delete_sql', $id) || return (0);
    $logger->info("user_group $id deleted");
    return (1);
}


=head2 $success = user_group_add(%args)

Add a user_group entry

=cut

sub user_group_add {
    my %data = @_;
    db_query_execute(USER_GROUP, $user_group_statements, 'user_group_add_sql', @data{@FIELDS}) || return (0);
    return (1);
}

=head2 $success = user_group_try_add(%args)

Try to add a user_group entry

=cut

sub user_group_try_add {
    my %data = @_;
    db_query_execute(USER_GROUP, $user_group_statements, 'user_group_add_sql', @data{@FIELDS}) || return (0);
    return (1);
}

=head2 $success = user_group_insert_or_update(%args)

Add a user_group entry

=cut

sub user_group_insert_or_update {
    my %data = @_;
    db_query_execute(USER_GROUP, $user_group_statements, 'user_group_insert_or_update_sql', @data{@FIELDS}) || return (0);
    return (1);
}

=head2 $entry = user_group_view($id)

View a user_group entry by it's id

=cut

sub user_group_view {
    my ($id) = @_;
    my $query  = db_query_execute(USER_GROUP, $user_group_statements, 'user_group_view_sql', $id)
        || return (0);
    my $ref = $query->fetchrow_hashref();
    # just get one row and finish
    $query->finish();
    return ($ref);
}

=head2 $count = user_group_count_all()

Count all the entries user_group

=cut

sub user_group_count_all {
    my $query = db_query_execute(USER_GROUP, $user_group_statements, 'user_group_count_all_sql');
    my @row = $query->fetchrow_array;
    $query->finish;
    return $row[0];
}

=head2 @entries = user_group_view_all($offset, $limit)

View all the user_group for an offset limit

=cut

sub user_group_view_all {
    my ($offset, $limit) = @_;
    $offset //= 0;
    $limit  //= 25;

    return db_data(USER_GROUP, $user_group_statements, 'user_group_view_all_sql', $offset, $limit);
}

sub user_group_cleanup {
    my $timer = pf::StatsD::Timer->new({sample_rate => 0.2});
    my ($expire_seconds, $batch, $time_limit) = @_;
    my $logger = get_logger();
    $logger->debug(sub { "calling user_group_cleanup with time=$expire_seconds batch=$batch timelimit=$time_limit" });
    my $now = db_now();
    my $start_time = time;
    my $end_time;
    my $rows_deleted = 0;
    while (1) {
        my $query = db_query_execute(USER_GROUP, $user_group_statements, 'user_group_cleanup_sql', $now, $expire_seconds, $batch)
        || return (0);
        my $rows = $query->rows;
        $query->finish;
        $end_time = time;
        $rows_deleted+=$rows if $rows > 0;
        $logger->trace( sub { "deleted $rows_deleted entries from user_group during user_group cleanup ($start_time $end_time) " });
        last if $rows <= 0 || (( $end_time - $start_time) > $time_limit );
    }
    $logger->trace( "deleted $rows_deleted entries from user_group during user_group cleanup ($start_time $end_time) " );
    return (0);
}

=head2 @entries = user_group_custom($sql, @args)

Custom sql query for radius audit log

=cut

sub user_group_custom {
    my ($sql, @args) = @_;
    $user_group_statements->{'user_group_custom_sql'} = $sql;
    return db_data(USER_GROUP, $user_group_statements, 'user_group_custom_sql', @args);
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2017 Inverse inc.

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
