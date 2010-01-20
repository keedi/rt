package RT::Action::WithCustomFields;
use strict;
use warnings;

sub _add_custom_fields {
    my $self = shift;
    my %args = @_;

    my $cfs    = $args{cfs};
    my $method = $args{method};

    while (my $cf = $cfs->next) {
        my $render_as = $cf->type_for_rendering;
        my $name = 'cf_' . $cf->id;

        my %args = (
            name          => $name,
            label         => $cf->name,
            render_as     => $render_as,
            default_value => $self->record->first_custom_field_value($cf->name),
        );

        if ($render_as =~ /Select/i) {
            $args{valid_values} = [ {
                collection   => $cf->values,
                display_from => 'name',
                value_from   => 'name',
            } ];
        }
        elsif ($render_as =~ /Combobox/i) {
            $args{available_values} = [ {
                collection   => $cf->values,
                display_from => 'name',
                value_from   => 'name',
            } ];
        }

        $self->$method(
            %args,
        );
    }
}

1;

