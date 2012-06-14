package Google::Code::Upload;
use strict;
use warnings;
# ABSTRACT: upload files to a Google Code project
# VERSION

use File::Basename qw/basename/;
use LWP::UserAgent;
use LWP::Protocol::https;
use HTTP::Request::Common;

use Exporter qw(import);
our @EXPORT_OK = qw/ upload /;

=head1 SYNOPSIS

    use Google::Code::Upload qw/upload/;

    upload( $file, $project_name, $username, $password, $summary, $labels );

=head1 DESCRIPTION

It's an incomplete Perl port of L<http://support.googlecode.com/svn/trunk/scripts/googlecode_upload.py>

basically you need L<googlecode_upload> script instead.

=head1 METHODS

=head2 upload

    upload( $file, $project_name, $username, $password, $summary, $labels );

=cut

sub upload {
    my ( $file, $project_name, $username, $password, $summary, $labels ) = @_;

    $labels ||= [];
    if ( $username =~ /^(.*?)\@gmail\.com$/ ) {
        $username = $1;
    }

    my $request = POST "https://$project_name.googlecode.com/files",
        Content_Type => 'form-data',
        Content      => [
            summary     => $summary,
            ( map { (label => $_) } @$labels),
            filename    => [$file, basename($file), Content_Type => 'application/octet-stream'],
        ];
    $request->authorization_basic($username, $password);

    my $ua = LWP::UserAgent->new( agent => 'Googlecode.com uploader v0.9.4' );
    my $response = $ua->request($request);

    if ($response->code == 201) {
        return ( $response->code, $response->status_line, $response->header('Location') );
    }
    else {
        return ( $response->code, $response->status_line, undef );
    }
}

1;
