package Net::LDAP::Filter::Abstract::Operator;

use strict;
use base 'Tree::Simple';

our $DEFAULT_OPERATOR = '&';

=head1 NAME

Net::LDAP::Filter::Abstract::Operator - An LDAP operator

=head1 SYNOPSIS

See L<Net::LDAP::Filter::Abstract>.

=head1 DESCRIPTION

An LDAP operator, which might look like the ampersand (C<&>) in:

  (&(...)(...))

This class is not intended to be used directly. See
L<Net::LDAP::Filter::Abstract>.

=head1 METHODS

=head2 new

=cut

sub new {
    my ($class, $operator, $parent) = @_;

    $operator ||= $DEFAULT_OPERATOR;

    my $self = (ref($class) || $class)->SUPER::new($operator);

    return $self;
}

=head2 as_string

=cut

sub as_string {
    my $self = shift;

    my $string = '';
    $self->traverse(sub {
        my ($node) = @_;
        $string .= $node->getNodeValue;
    });

    return $string;
}

=head1 OPERATORS

=over 4

=item *

C<&> - logical and

=item *

C<|> - logical or

=item *

C<!> - logical not

=back

=head1 SEE ALSO

L<Net::LDAP::Filter::Abstract>

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
