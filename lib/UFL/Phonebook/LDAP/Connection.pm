package UFL::Phonebook::LDAP::Connection;

use strict;
use warnings;
use base qw/Catalyst::Model::LDAP::Connection/;
use Authen::SASL qw/Perl/;
use Carp qw/croak/;
use Class::C3;
use Net::LDAP::Control::ProxyAuth;

__PACKAGE__->mk_accessors(qw/catalyst_user/);

=head1 NAME

UFL::Phonebook::LDAP::Connection - LDAP connection for authenticated requests

=head1 DESCRIPTION

Overrides L<Catalyst::Model::LDAP::Connection> to assume the identity
of the person associated with the current L<Catalyst> user.

=head1 METHODS

=head2 bind

Bind the connection, authenticating via SASL.

=cut

sub bind {
    my ($self, %args) = @_;

    my %sasl_args = %{ delete $args{sasl} || {} };

    if (my $catalyst_user = delete $args{catalyst_user}) {
        # Store the Catalyst user for later
        $self->catalyst_user($catalyst_user);

        my $sasl = Authen::SASL->new(mechanism => 'GSSAPI', %sasl_args);
        $args{sasl} = $sasl;
    }

    $self->next::method(%args);
}

=head2 search

Request authorization and then search as the current L<Catalyst> user.

=cut

sub search {
    my $self = shift;
    my %args = scalar @_ == 1 ? (filter => shift) : @_;

    if ($self->catalyst_user) {
        my $auth = Net::LDAP::Control::ProxyAuth->new(
            authzID => 'u:' . $self->catalyst_user->id,
        );

        push @{ $args{control} }, $auth;
    }

    $self->next::method(%args);
}

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
