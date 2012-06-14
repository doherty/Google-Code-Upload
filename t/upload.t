use strict;
use warnings;
use Test::More 0.96;

my $user = $ENV{GOOGLECODE_USER};
my $pass = $ENV{GOOGLECODE_PASS};
my $proj = $ENV{GOOGLECODE_PROJECT};

plan skip_all => 'Set GOOGLECODE_PASS, GOOGLECODE_USER, and GOOGLECODE_PROJECT to run this test'
        unless $user and $pass and $proj;
plan tests => 2;

subtest old => sub {
    plan tests => 1;

    require Google::Code::Upload;
    Google::Code::Upload->import('upload');

    my ($status, $reason, $url) = upload('README', $proj, $user, $pass, 'TEST', [ 'Test', 'Deprecated']);
    is $status, 201 or diag $reason;
    diag $url;
};

subtest new => sub {
    plan tests => 3;

    require Google::Code::Upload;
    my $gc = new_ok('Google::Code::Upload' => [username => $user, password => $pass, project => $proj]);
    can_ok $gc, qw(upload);

    $gc->upload( file => __FILE__, summary => 'summary', labels => ['Test', 'Deprecated'], description => 'desc' );
};
