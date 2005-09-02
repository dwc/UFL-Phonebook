package Uf::Webadmin::Phonebook::M::People;

use strict;
use base 'Catalyst::Model::LDAP';

__PACKAGE__->config(
    host     => 'ldap.ufl.edu',
    base     => 'ou=People,dc=ufl,dc=edu',
    dn       => '',
    password => '',
    options  => {},
);

=head1 NAME

Uf::Webadmin::Phonebook::M::People - LDAP Catalyst model component

=head1 SYNOPSIS

See L<Uf::Webadmin::Phonebook>.

=head1 DESCRIPTION

Catalyst model component for the University of Florida LDAP server.
This component uses a base of C<ou=People,dc=ufl,dc=edu>.

=head1 AUTHOR

University of Florida Web Administration E<lt>webmaster@ufl.eduE<gt>

L<http://www.webadmin.ufl.edu/>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;