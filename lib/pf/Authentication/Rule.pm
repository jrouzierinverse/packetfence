package pf::Authentication::Rule;

=head1 NAME

pf::Authentication::Rule

=head1 DESCRIPTION

=cut

use Moose;

use pf::Authentication::constants;
use pf::Authentication::Condition;
use pf::Authentication::Action;

has 'id' => (isa => 'Str', is => 'rw', required => 1);
has 'description' => (isa => 'Str', is => 'rw', required => 0);
has 'match' => (isa => 'Maybe[Str]', is => 'rw', default => $Rules::ANY);
has 'type' => (isa => 'Maybe[Str]', is => 'rw', default => $Rules::ANY);
has 'actions' => (isa => 'ArrayRef', is => 'rw', required => 0);
has 'conditions' => (isa => 'ArrayRef', is => 'rw', required => 0);

=head2 BUILDARGS

Massage the condition and action parameters before passing it to the constructor

=cut

sub BUILDARGS {
    my ($self, @args) = @_;
    my %original_args;
    #If there is more than one parameter assume it is a hash
    if (@args > 1 ) {
        %original_args = @args;
    } else {
        %original_args = %{$args[0]};
    }
    my (%newsargs, @conditions, @actions);
    while (my ($key, $val) = each %original_args) {
        if ($key =~ m/condition(\d+)/) {
            #print "Condition $1: " . $config->val($rule, $parameter) . "\n";
            my ($attribute, $operator, $value) = split(',', $val, 3);
            push @conditions,
              pf::Authentication::Condition->new(
                {   attribute => $attribute,
                    operator  => $operator,
                    value     => $value
                }
              );
        }
        elsif ($key =~ m/action(\d+)/) {

            #print "Action: $1" . $config->val($rule_id, $parameter) . "\n";
            my ($type, $value) = split('=', $val);
            push @actions,
              pf::Authentication::Action->new(
                {   type  => $type,
                    value => $value
                }
              );
        }
        else {
            $newsargs{$key} = $val;
        }
    }
    $newsargs{actions}    = \@actions;
    $newsargs{conditions} = \@conditions;
    return \%newsargs;
}

sub add_action {
  my ($self, $action) = @_;
  push(@{$self->{'actions'}}, $action);
}

sub add_condition {
  my ($self, $condition) = @_;
  push(@{$self->{'conditions'}}, $condition);
}

sub is_fallback {
  my $self = shift;

  if (scalar @{$self->{'conditions'}} == 0 &&
      scalar @{$self->{'actions'}} > 0)
    {
      return 1;
    }

  return 0;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2013 Inverse inc.

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

__PACKAGE__->meta->make_immutable;
1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:
