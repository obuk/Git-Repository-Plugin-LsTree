# -*- coding: utf-8 -*-

use strict;
use warnings;
use Test::More;

BEGIN { use_ok('Git::Repository', 'LsTree') }

use Test::Output qw/output_from/;
use Test::Git;
use File::Spec::Functions qw/catfile splitdir catdir/;
use YAML qw/ LoadFile Load DumpFile Dump /;
use Cwd;

my $top = getcwd();
my $test_bundle = "$top/test.bundle";

$ENV{GIT_AUTHOR_EMAIL}    = 'author@example.com';
$ENV{GIT_AUTHOR_NAME}     = 'Author Example';
$ENV{GIT_COMMITTER_EMAIL} = 'committer@example.com';
$ENV{GIT_COMMITTER_NAME}  = 'Committer Example';

{
  my $r = test_repository;

  {
    my $f = 'a.yml';
    DumpFile(catfile($r->work_tree, $f), { numbers => [ 103 .. 200 ] });
    $r->run(add => $f);
    $r->run(commit => -m => "adds $f");
  }

  {
    my ($f, $g) = qw!a.yml b.yml!;
    $r->run(mv => $f => $g);
    $r->run(commit => -m => "renames $f $g");
  }

  {
    my $f = 'c.yml';
    DumpFile(catfile($r->work_tree, $f), { numbers => [ 103 .. 200 ] });
    $r->run(add => $f);
    $r->run(commit => -m => "adds $f");
  }

  {
    my ($f, $g) = qw!c.yml x/c.yml!;
    mkdir catfile($r->work_tree, 'x');
    $r->run(mv => $f => $g);
    $r->run(commit => -m => "renames $f $g");
  }

  {
    my ($f, $g) = qw!x/c.yml x/d.yml!;
    $r->run(mv => $f => $g);
    $r->run(commit => -m => "renames $f $g");
  }

  $r->run(tag => 'RELENG');
  $r->run(bundle => create => $test_bundle => HEAD => '--all');

  my $self = Git::Repository->new(git_dir => $r->git_dir);
  is ref $self, 'Git::Repository' or diag $self;

  $self->can('ls_tree');

  {
    my @ls_tree = $self->ls_tree(qw/ HEAD /);
    is @ls_tree, 2 or diag explain [@ls_tree];
    for (@ls_tree) {
      can_ok($_, qw/ file mode type object size /);
      is $_->size, undef;
    }
  }

  {
    my @ls_tree = $self->ls_tree(qw/ -lr HEAD /);
    is @ls_tree, 2 or diag explain [@ls_tree];
    for (@ls_tree) {
      can_ok($_, qw/ file mode type object size /);
      isnt $_->size, undef;
      # diag join(' ', $_->mode, $_->type, $_->object, $_->size, $_->file);
    }
  }

  {
    for my $opts (
      [ qw/ -l HEAD / ],
      [ qw/ :utf8 -l HEAD / ],
     ) {
      my %ls;
      {
        local $ENV{GIT_DIR} = $r->git_dir;
        for (Git::Repository->ls_tree(@$opts)) {
          can_ok($_, qw/ file mode type object size /);
          isnt $_->size, undef;
          $ls{$_->file}{mode} = $_->mode;
          $ls{$_->file}{type} = $_->type;
          #diag join(' ', $_->mode, $_->type, $_->object, $_->size, $_->file);
        }
        is $ls{'b.yml'}{type}, 'blob';
        is $ls{'x'    }{type}, 'tree';
      }
      {
        for ($self->ls_tree(@$opts)) {
          can_ok($_, qw/ file mode type object size /);
          isnt $_->size, undef;
          is $_->mode, $ls{$_->file}{mode};
          is $_->type, $ls{$_->file}{type};
        }
      }
    }
  }

}

unlink $test_bundle;

done_testing();
