use Test::More;

BEGIN {
  use_ok( 'Git::Repository::Plugin::LsTree' );
  use_ok( 'Git::Repository::LsTree' );
}

for (qw/ Git::Repository::Plugin::LsTree /) {
  diag "Testing $_ " . eval '$' . $_ . '::VERSION'
}

done_testing();
