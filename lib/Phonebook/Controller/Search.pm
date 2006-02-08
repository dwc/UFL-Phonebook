package Phonebook::Controller::Search;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

Phonebook::Controller::People - People controller component

=head1 SYNOPSIS

See L<Phonebook>.

=head1 DESCRIPTION

Catalyst controller component for finding people.

=head1 METHODS

=head2 search

Search the specified source.

=cut

sub search : Path('') {
    my ($self, $c) = @_;

    my $query  = $c->req->param('query');
    my $source = $c->req->param('source');

    $source =~ s/[^a-z]//g;
    $source = (exists $c->config->{sources}->{$source}
               ? $c->config->{sources}->{$source}
               : $c->config->{sources}->{$c->config->{default_source}}
              );

    my $url = $c->uri_for(sprintf($source->{url}, $query));
    $c->log->debug("Search URL: [$url]");

    $c->res->redirect($url);
}

=head1 AUTHOR

University of Florida Web Administration E<lt>webmaster@ufl.eduE<gt>

L<http://www.webadmin.ufl.edu/>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
