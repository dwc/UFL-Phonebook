package Uf::Webadmin::Phonebook::Entry;

use strict;

=head1 NAME

Uf::Webadmin::Phonebook::Entry - A phonebook entry

=head1 SYNOPSIS

  # Search using Net::LDAP
  my $mesg = $ldap->search($filter);
  my @entries = map {
      Uf::Webadmin::Phonebook::Entry->new($_)
  } $mesg->entries;
  print $entries[0]->{eduPersonPrimaryAffiliation};

=head1 DESCRIPTION



=head1 METHODS

=head2 new

Given a L<Net::LDAP::Entry>, create our view of that entry.

=cut

sub new {
    my ($class, $entry) = @_;

    return unless ($entry and $entry->attributes);

    my $self = bless({}, $class);

    foreach my $attribute ($entry->attributes) {
        my $value = $entry->get_value($attribute);

        $self->{attribute} = undef;
        if ($value and $value ne '--UNKNOWN--') {
            $self->{$attribute} = $value;
        }
    }

    return $self;
}

=head1 AUTHOR

University of Florida Web Administration E<lt>webmaster@ufl.eduE<gt>

L<http://www.webadmin.ufl.edu/>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
