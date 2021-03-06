package UFL::Phonebook::BaseController;

use strict;
use warnings;
use base qw/Catalyst::Controller/;
use Net::LDAP::Constant;

__PACKAGE__->mk_accessors(qw/default_query model_name sort_fields/);

=head1 NAME

UFL::Phonebook::BaseController - Base controller component

=head1 SYNOPSIS

See L<UFL::Phonebook>.

=head1 DESCRIPTION

Catalyst controller component for searching the directory via LDAP.

=head1 METHODS

=head2 index

Redirect to the L<UFL::Phonebook> home page.

=cut

sub index : Path('') Args(0) {
    my ($self, $c) = @_;

    $c->res->redirect($c->uri_for($c->controller('Root')->action_for('index')));
}

=head2 search

Search the directory for objects matching the specified query.

=cut

sub search : Local Args(0) {
    my ($self, $c) = @_;

    my $query = $c->req->param('query');
    $c->detach('index') if not $query
        or $query eq $self->default_query;

    # Throttle the request before allowing the search
    $c->forward('/throttle/check');

    my $filter = $self->_parse_query($query);

    $c->log->debug("Query: $query");
    $c->log->debug("Filter: $filter");

    my $mesg = $self->model($c)->search($filter->as_string);
    $c->forward('results', [ $mesg ]);
}

=head2 results

Display the objects from the specified L<Net::LDAP::Message>. If only
one object is found, display it directly.

=cut

sub results : Private {
    my ($self, $c, $mesg) = @_;

    $c->stash(
        sizelimit_exceeded => ($mesg->code == &Net::LDAP::Constant::LDAP_SIZELIMIT_EXCEEDED),
        timelimit_exceeded => ($mesg->code == &Net::LDAP::Constant::LDAP_TIMELIMIT_EXCEEDED),
    );

    my @entries = $mesg->entries;
    @entries = $self->filter_entries(@entries)
        if $self->can('filter_entries');

    if (@entries == 1 and my $query = $c->req->param('query')) {
        my $entry = shift @entries;
        $c->res->cookies->{query} = { value => $query };
        $c->res->redirect($c->uri_for($self->action_for('view'), $entry->uri_args, ''));
    }
    elsif (@entries) {
        my $sort = $c->req->params->{sort};

        # Sort by e.g. last name, then first name
        my @sort_fields = @{ $sort ? [ $sort ] : $self->sort_fields };
        foreach my $sort_field (reverse @sort_fields) {
            @entries = sort { $a->$sort_field cmp $b->$sort_field } @entries;
        }

        $c->stash(
            entries  => \@entries,
            template => $self->template('results.tt'),
        );
    }
    else {
        $c->stash(template => $self->template('no_results.tt'));
    }
}

=head2 single

Throttle the request before allowing the user to view the result.

=cut

sub single : Private {
    my ($self, $c, $ufid) = @_;

    $c->forward('/throttle/check');
}

=head2 view

Display the stashed entry.

=cut

sub view : PathPart('') Chained('single') Args(0) {
    my ($self, $c) = @_;

    $c->stash(template => $self->template('view.tt'));
}

=head2 full

Display the full entry for a single object.

=cut

sub full : PathPart Chained('single') Args(0) {
    my ($self, $c) = @_;

    $c->stash(template => $self->template('full.tt'));
}

=head2 model

Return the configured model via the specified application object.

=cut

sub model {
    my ($self, $c) = @_;

    die 'No model name configured' unless $self->model_name;

    return $c->model($self->model_name);
}

=head2 template

Return the path to the specified template, relative to this
controller's L<Catalyst::Action> namespace.

=cut

sub template {
    my ($self, $filename) = @_;

    return $self->action_namespace . '/' . $filename;
}

=head2 filter

Generate a new L<UFL::Phonebook::Filter::Abstract> suitable for
searching the directory via this controller's model.

=cut

sub filter {
    die 'abstract method';
}

=head2 _parse_query

Parse a user-supplied query into an LDAP filter.

=cut

sub _parse_query {
    die 'abstract method';
}

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
