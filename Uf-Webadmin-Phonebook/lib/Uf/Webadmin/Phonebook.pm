package Uf::Webadmin::Phonebook;

use strict;
use Catalyst qw/-Debug/;

our $VERSION = '0.01';

Uf::Webadmin::Phonebook->config(
    name => 'University of Florida Phonebook',
);

Uf::Webadmin::Phonebook->setup;

=head1 NAME

Uf::Webadmin::Phonebook - Catalyst based application

=head1 SYNOPSIS

  script/uf_webadmin_phonebook_server.pl

=head1 DESCRIPTION

Catalyst based application.

=head1 METHODS

=head2 default

Display the home page.

=cut

sub default : Private {
    my ($self, $c) = @_;

    $c->stash->{template} = 'index.tt';
}

=head2 end

Forward to the application's view.

=cut

sub end : Private {
    my ($self, $c) = @_;

    $c->forward(__PACKAGE__ . '::V::TT') unless $c->res->output;
}

=head1 AUTHOR

University of Florida Web Administration E<lt>webmaster@ufl.eduE<gt>

L<http://www.webadmin.ufl.edu/>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
