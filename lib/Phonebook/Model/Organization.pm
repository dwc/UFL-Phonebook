package Phonebook::Model::Organization;

use strict;
use warnings;
use base 'Catalyst::Model::LDAP';
use UNIVERSAL::require;

=head1 NAME

Phonebook::Model::Organization - LDAP Catalyst model component

=head1 SYNOPSIS

See L<Phonebook>.

=head1 DESCRIPTION

Catalyst model component for the University of Florida Phonebook.

=head1 METHODS

=cut

sub search {
    my $self = shift;

    my $entries = $self->SUPER::search(@_);

    my $class = $self->config->{class};
    return $entries unless $class and $class->require;

    my @units;
    if ($entries and @$entries) {
        @units = map { $class->new($_) } @$entries;
    }

    return \@units;
}

=head1 AUTHOR

University of Florida Web Administration E<lt>webmaster@ufl.eduE<gt>

L<http://www.webadmin.ufl.edu/>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
