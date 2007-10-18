package UFL::Phonebook::Controller::Root;

use strict;
use warnings;
use base qw/Catalyst::Controller/;

__PACKAGE__->config(namespace => '');
__PACKAGE__->mk_accessors(qw/auto_login/);

=head1 NAME

UFL::Phonebook::Controller::Root - Root controller

=head1 DESCRIPTION

Root L<Catalyst> controller for L<UFL::Phonebook>.

=head1 METHODS

=head2 auto

Automatically log in users if configured to do so.

=cut

sub auto : Private {
    my ($self, $c) = @_;

    $c->forward($c->controller('Authentication')->action_for('login'))
        if $self->auto_login and not $c->user_exists;

    if ($c->user_exists) {
        my $mesg = $c->model('Person')->search("uid=" . $c->user->id);
        if (my $entry = $mesg->shift_entry) {
            # XXX: Copy a few items (can't store the entry itself in session)
            $c->user->$_($entry->$_)
                for qw/eduPersonPrimaryAffiliation uflEduUniversityId uri_args/;
        }
    }

    return 1;
}

=head2 default

Handle any actions which did not match, i.e. 404 errors.

=cut

sub default : Private {
    my ($self, $c) = @_;

    $c->res->status(404);
    $c->stash(template => 'not_found.tt');
}

=head2 index

Display the home page.

=cut

sub index : Path('') Args(0) {
    my ($self, $c) = @_;

    $c->stash(template  => 'index.tt');
}

=head2 affiliations

Display the home page.

=cut

sub affiliations : Local Args(0) {
    my ($self, $c) = @_;

    $c->stash(template  => 'affiliations.tt');
}

=head2 render

Attempt to render a view, if needed.

=cut 

sub render : ActionClass('RenderView') {
    my ($self, $c) = @_;

    if (@{ $c->error }) {
        $c->res->status(500);

        # Override the ugly Catalyst debug screen
        unless ($c->debug) {
            $c->log->error($_) for @{ $c->error };

            $c->stash(
                errors   => $c->error,
                template => 'error.tt',
            );
            $c->clear_errors;
        }
    }
}

=head2 end

Render a view and finish up before sending the response.

=cut

sub end : Private {
    my ($self, $c) = @_;

    $c->forward('render');
}

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
