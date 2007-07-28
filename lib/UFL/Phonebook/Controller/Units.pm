package UFL::Phonebook::Controller::Units;

use strict;
use warnings;
use base qw/Catalyst::Controller/;
use Net::LDAP::Constant;
use UFL::Phonebook::Filter::Abstract;
use UFL::Phonebook::Util;

__PACKAGE__->mk_accessors(qw/default_query hide/);

=head1 NAME

UFL::Phonebook::Controller::Units - Units controller component

=head1 SYNOPSIS

See L<UFL::Phonebook>.

=head1 DESCRIPTION

Catalyst controller component for finding units (departments or other
campus organizations).

=head1 METHODS

=head2 index

Redirect to the L<UFL::Phonebook> home page.

=cut

sub index : Private {
    my ($self, $c) = @_;

    $c->res->redirect($c->uri_for('/'));
}

=head2 search

Search the directory for units.

=cut

sub search : Local {
    my ($self, $c) = @_;

    my $query = $c->req->param('query');
    $c->detach('index') if not $query
        or $query eq $self->default_query;

    my $filter = $self->_parse_query($query);
    my $string = $filter->as_string;

    $c->log->debug("Query: $query");
    $c->log->debug("Filter: $string");

    my $mesg = $c->model('Unit')->search($string);
    $c->forward('results', [ $mesg ]);
}

=head2 results

Display the units from the specified L<Net::LDAP::Message>. If only
one unit is found, display it directly.

=cut

sub results : Private {
    my ($self, $c, $mesg) = @_;

    $c->stash->{sizelimit_exceeded} = ($mesg->code == &Net::LDAP::Constant::LDAP_SIZELIMIT_EXCEEDED);
    $c->stash->{timelimit_exceeded} = ($mesg->code == &Net::LDAP::Constant::LDAP_TIMELIMIT_EXCEEDED);

    my $sort  = $c->req->param('sort') || 'o';
    my @units =
        sort { $a->$sort cmp $b->$sort }
        $mesg->entries;

    if (scalar @units == 1) {
        my $unit = shift @units;
        $c->res->cookies->{query} = { value => $c->req->param('query') || $unit->o };
        $c->res->redirect($c->uri_for('/units', $unit, ''));
    }
    elsif (scalar @units > 0) {
        $c->stash->{units}    = \@units;
        $c->stash->{template} = 'units/results.tt';
    }
    else {
        $c->stash->{template} = 'units/noResults.tt';
    }
}

=head2 single

Display a single unit. By specifying an argument after the PeopleSoft
department ID and providing a corresponding local action, you can
override the display behavior of the unit.

=cut

sub single : Path('') {
    my ($self, $c, $psid, $action) = @_;

    $c->detach('/default') unless $psid;
    $c->log->debug("PeopleSoft department ID: $psid");

    # Handle redirection when a search query returns only one person
    my $query = $c->req->cookies->{query};
    if ($query and $query->value) {
        $c->stash->{query} = $query->value;
        $c->res->cookies->{query} = { value => '' };

        $c->stash->{single_result} = 1;
    }

    my $mesg = $c->model('Unit')->search("uflEduPsDeptId=$psid");
    my $entry = $mesg->shift_entry;
    unless ($entry) {
        # Redirect from the UFID to the PeopleSoft department ID
        $mesg = $c->model('Unit')->search("uflEduUniversityId=$psid");
        $entry = $mesg->shift_entry;
        $c->detach('/default') unless $entry;

        $c->log->debug('Redirecting unit to PeopleSoft department ID: ' . $entry->uflEduPsDeptId);

        my @args = ($entry->uflEduPsDeptId);
        push @args, $action if $action;
        return $c->res->redirect($c->uri_for('/units', @args, ''), 301);
    }

    $c->stash->{unit}     = $entry;
    $c->stash->{template} = 'units/show.tt';

    if ($action) {
        $c->detach('/default') unless $self->can($action);
        $c->detach($action);
    }
}

=head2 full

Display the full entry for a single unit.

=cut

sub full : Private {
    my ($self, $c) = @_;

    $c->stash->{template} = 'units/full.tt';
}

=head2 people

Search for people whose primary organizational affiliation matches the
specified PeopleSoft department ID.

=cut

sub people : Private {
    my ($self, $c) = @_;

    my $unit = $c->stash->{unit};
    $c->detach('/default') unless $unit;

    my $filter = $c->controller('People')->_get_restriction;
    $filter->add('departmentNumber', '=', $unit->uflEduPsDeptId);

    $c->log->debug("Filter: $filter");

    my $mesg = $c->model('Person')->search($filter->as_string);
    $c->forward('/people/results', [ $mesg ]);
}

=head2 _parse_query

Parse a query into an LDAP filter.

=cut

sub _parse_query {
    my ($self, $query) = @_;

    my @tokens = UFL::Phonebook::Util::tokenize_query($query);

    my $filter = UFL::Phonebook::Filter::Abstract->new('|');
    if ($query =~ /([^@]+)\@/) {
        # Email address
        my $mail = $tokens[0];

        $filter->add('mail', '=', $mail);
    }
#    elsif ($query =~ /(\d{3})?.?((:?\d{2})?\d).?(\d{4})/) {
#        # TODO: Searching phone numbers seems slow
#        # Phone number
#        my $area_code = $1;
#        my $exchange = $2;
#        my $last_four = $3;
#
#        my $phone_number = UFL::Phonebook::Util::getPhoneNumber($area_code, $exchange, $last_four);
#
#        $filter->add('telephoneNumber',          '=', qq[$phone_number*]);
#        $filter->add('facsimileTelephoneNumber', '=', qq[$phone_number*]);
#    }
    else {
        # Unit name
        $filter->add('o', '=', qq[*$query*]);
    }
}

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;