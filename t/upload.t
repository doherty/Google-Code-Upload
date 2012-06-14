use strict;
use warnings;
use Test::More;
use Google::Code::Upload qw(upload);

unless ($ENV{GOOGLECODE_PASS} and $ENV{GOOGLECODE_USER} and $ENV{GOOGLECODE_PROJECT}) {
    plan skip_all => 'Set GOOGLECODE_PASS, GOOGLECODE_USER, and GOOGLECODE_PROJECT to run this test';
}
else {
    plan tests => 1;
}
my $user = $ENV{GOOGLECODE_USER};
my $pass = $ENV{GOOGLECODE_PASS};
my $proj = $ENV{GOOGLECODE_PROJECT};

my ($status, $reason, $url) = upload('README', $proj, $user, $pass, 'TEST', [ 'Test', 'Deprecated']);
is $status, 201 or diag $reason;
diag $url;
