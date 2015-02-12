package Git::Repository::Plugin::LsTree;

use warnings;
use strict;
use 5.006;

our $VERSION = '0.01';

use Git::Repository::Plugin;
our @ISA = qw( Git::Repository::Plugin );
sub _keywords { qw( ls_tree ) }

use Git::Repository::LsTree;

sub ls_tree {
  Git::Repository::LsTree->new(@_);
}

1;

# ABSTRACT: Add a lstree() method to Git::Repository

=pod

=head1 NAME

Git::Repository::Plugin::Lstree - Class representing git log --lstree data

=head1 SYNOPSIS

    # load the plugin
    use Git::Repository 'Lstree';

    my $r = Git::Repository->new();

    # get all log and lstree objects
    my @logs = $r->lstree(qw( --since=yesterday ));

    # get an iterator
    my $iter = $r->lstree(qw( --since=yesterday ));
    while ( my $log = $iter->next() ) {
        ...;
    }

=head1 DESCRIPTION

This module adds a new method to L<Git::Repository>.

=head1 METHOD

=head2 ls_tree

Run C<git ls-tree> with the given arguments.

=head1 SEE ALSO

L<Git::Repository::Plugin>,
L<Git::Repository::LsTree>.

=head1 COPYRIGHT

Copyright 2015 Kubo Koich, all rights reserved.

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
