package pfappserver::Form::Widget::Theme::Pf;

=head1 NAME

pfappserver::Form::Widget::Theme::Pf - PacketFence theme

=head1 DESCRIPTION

This theme extends the Bootstrap theme. It modifies various aspects of
the fields:

 - add some element and wrapper classes to fields
 - add 'data-required=required' attribute to required fields
 - add 'data-type=number' attribute to number fields

=cut

use HTML::FormHandler::Moose::Role;
use namespace::autoclean;
with 'HTML::FormHandler::Widget::Theme::Bootstrap';

=head2 get_language_handle_from_ctx

=cut

sub get_language_handle_from_ctx {
    my $self = shift;

    return pfappserver::I18N->get_handle(
        @{ $self->ctx->languages } );
}

=head2 help

=cut

sub help {
    my $self = shift;
    my $help = undef;

    if ($self->get_tag('help')) {
        return sprintf('<p class="help-block">%s</p>', $self->_localize($self->get_tag('help')));
    }
}

=head2 help_list

=cut

sub help_list {
    my $self = shift;
    my $help = undef;

    if ($self->get_tag('help')) {
        return sprintf('<dl class="help-block">%s</dl>', $self->_localize($self->get_tag('help')));
    }
}

=head2 html_attributes

Translate placeholders in select inputs (data-placeholder), if defined

=cut

sub html_attributes {
    my ( $self, $obj, $type, $attr, $result ) = @_;
    # obj is either form or field
    if (exists $attr->{'data-placeholder'}) {
        $attr->{'data-placeholder'} = $self->_localize($attr->{'data-placeholder'});
    }
    return $attr;
}

sub build_update_subfields {{
    by_type =>
      {
       'IntRange' =>
       {
        element_class => ['input-mini'],
       },
       'PosInteger' =>
       {
        element_class => ['input-mini'],
        element_attr => {'min' => '0'},
       },
       'TextArea' =>
       {
        element_class => ['input-xlarge'],
       },
       'Uneditable' =>
       {
        element_class => ['uneditable'],
       },
       'DatePicker' =>
       {
        element_class =>  ['datepicker', 'input-small'],
        element_attr => { 'data-date-format' => 'yyyy-mm-dd',
                          placeholder => 'yyyy-mm-dd' },
       },
       'TimePicker' =>
       {
        element_class => ['timepicker-default', 'input-small'],
        element_attr => {placeholder => 'MM:HH'},
       },
      },
}}

sub update_fields {
    my $self = shift;

    foreach my $field (@{$self->fields}) {
        if ($field->required) {
            $field->set_element_attr('data-required' => 'required');
            $field->tags->{label_after} = ' <i class="icon-exclamation-sign"></i>';
        }
        if ($field->type eq 'PosInteger') {
            $field->type_attr($field->html5_type_attr);
            $field->set_element_attr('data-type' => 'number');
        }
        elsif ($field->{is_compound}) {
            foreach my $subfield (@{$field->fields}) {
                if ($subfield->type eq 'PosInteger') {
                    $subfield->type_attr($subfield->html5_type_attr);
                    $subfield->set_element_attr('data-type' => 'number');
                }
                if ($field->required) {
                    $subfield->set_element_attr('data-required' => 'required');
                }
            }
        }
        elsif ($field->type eq 'DatePicker') {
            if ($field->start) {
                $field->set_element_attr('data-date-startdate' => $field->start);
            }
            if ($field->end) {
                $field->set_element_attr('data-date-enddate' => $field->end);
            }
        }
    }
}

=head2 field_errors

Return a hashref of field errors. Can be called once the form has been processed.

=cut

sub field_errors {
    my $self = shift;

    my %errors = ();
    if ($self->has_errors) {
        foreach my $field ($self->error_fields) {
            $errors{$field->name} = join(' ', @{$field->errors});
        }
    }

    return \%errors;
}

no HTML::FormHandler::Moose::Role;

=head1 COPYRIGHT

Copyright (C) 2012 Inverse inc.

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
