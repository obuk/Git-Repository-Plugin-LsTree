package Git::Repository::LsTree;

use strict;
use warnings;
use 5.006;

use Carp;
use Git::Repository::Plugin;
our @ISA = qw( Git::Repository::Plugin );

use Git::Repository::Plugin::LsTree;
*VERSION = \$Git::Repository::Plugin::LsTree::VERSION;

use Encode;

# a few simple accessors
for my $attr (qw(file mode type object size)) {
  no strict 'refs';
  *$attr = sub { return $_[0]{$attr} };
}

sub _ls_tree {
  my ($class, $mtos, $file) = @_;
  my ($mode, $type, $object, $size) = split " ", $mtos;
  bless {
    file => $file, mode => $mode, type => $type, object => $object,
    defined $size ? (size => $size) : (),
  };
}

sub new {
  my ($class, $git) = splice(@_, 0, 2);
  my $enc = shift if @_ && $_[0] =~ /^:/;
  my $ls_tree = $git->command(qw/ls-tree/, @_)->stdout;
  binmode $ls_tree, $enc if $enc;
  my @ls_tree;
  while (<$ls_tree>) {
    chop;
    push @ls_tree, $class->_ls_tree(split "\t");
  }
  @ls_tree;
}

1;

# ABSTRACT: Class representing git ls-tree data

=pod

=head1 SYNOPSIS

    # load the lstree plugin
    use Git::Repository qw/ LsTree /;

    # get the ls-tree for HEAD
    my @ls_tree = Git::Repository->ls_tree(qw/ -lr HEAD /);
    for (@ls_tree) {
        print join "\t" => $_->mode => $_->type => $_->object => $_->size
            => $_->file, "\n";
    }

=head1 DESCRIPTION

L<Git::Repository::Lstree> is a class whose instances represent
ls-tree items from a B<git ls-tree> stream.

=head1 CONSTRUCTOR

=head2 new

Create a new L<Git::Repository::LsTree> instance, using the list of key/values
passed as parameters. The supported keys are (from the output of
C<git ls-tree>):

=over 4

=item ls_tree

=item file, mode, type, object, size

=back

=head1 COPYRIGHT

Copyright 2015 Kubo Koich, all rights reserved.

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
