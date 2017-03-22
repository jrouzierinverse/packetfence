package podcoverage;

=head1 NAME

podcoverage - fuctions to help with podcoverage for packetfence

=cut

=head1 DESCRIPTION

fuctions to help with podcoverage for packetfence

=cut

use strict;
use warnings;
use DBI;
use Pod::Coverage;
use File::Find;

=head2 open_coverage_db

open the coverage db

=cut

sub open_coverage_db {
    my ($dbfile) = @_;
    $dbfile //= "podcoverage.sqlite";
    my $dbh = DBI->connect("dbi:SQLite:dbname=$dbfile","","");
    setup_coverage_db($dbh);
    return $dbh;
}

=head2 setup_coverage_db

setup the table for the coverage db

=cut

sub setup_coverage_db {
    my ($dbh) = @_;
    my $create_sql =<<SQL;
    CREATE TABLE IF NOT EXISTS coverage_results (
        git_commit_id CHAR(20) , 
        package VARCHAR(255), 
        results BOOL, 
        why_unrated VARCHAR, 
        PRIMARY KEY (git_commit_id, package)
    );
SQL
    my $index_sql = "CREATE INDEX coverage_results_package ON coverage_results (package);";
    for my $sql ($create_sql, $index_sql) {
        $dbh->do($sql) or die $dbh->errstr;
    }
}

{

my @packages;

=head2 _wanted

Helper function for finding perl modules

=cut

sub _wanted {
    if (-f $File::Find::name) {
        my $p = $File::Find::name;
        return unless $p =~ /\.pm$/;
        $p =~ s#/usr/local/pf/lib/##;
        $p =~ s#/#::#g;
        $p =~ s/\.pm$//;
        push @packages, $p;
    }
}

sub get_packages {
    @packages = ();
    find (\&_wanted, '/usr/local/pf/lib');
    return [@packages];
}

}


=head2 save_current_coverage_state

save the current coverage state

=cut

sub save_current_coverage_state {
    my ($dbh, $commit_id) = @_;
    my $sth = $dbh->prepare("INSERT OR REPLACE INTO coverage_results (git_commit_id, package, results, why_unrated) VALUES (?,?,?,?)");
    my $packages = get_packages();
    $dbh->{AutoCommit} = 0; 
    $dbh->{RaiseError} = 1;
    eval {
        for my $p (@$packages) {
            my $pc = Pod::Coverage->new(package => $p);
            my $coverage = $pc->coverage;
            $sth->execute($commit_id, $p, $coverage, $pc->why_unrated);
            if (defined $coverage) {
                print "$p is coverage = $coverage\n";
                if ($coverage != 1) {
                    print "$p is not covered\n";
                    print join("\n",$pc->uncovered,"");
                }
            }
            else {
                print "$p is unrated " . $pc->why_unrated  . "\n";
            }
        }
        $dbh->commit;
    };
    if ($@) {
    }
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

