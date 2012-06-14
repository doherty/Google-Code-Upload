package Google::Code::Upload;
use strict;
use warnings;
# ABSTRACT: upload files to a Google Code project
# VERSION

use File::Basename qw/basename/;
use LWP::UserAgent;
use LWP::Protocol::https;
use HTTP::Request::Common;
use Scalar::Util qw/blessed/;
use Carp;


=head1 EXPORTS

You may optionally export C<upload> to use this module in a non-OO manner.

=cut

use Exporter qw(import);
our @EXPORT_OK = qw/ upload /;

=head1 SYNOPSIS

    use Google::Code::Upload qw/upload/;

    upload( $file, $project_name, $username, $password, $summary, $labels );

=head1 DESCRIPTION

It's an incomplete Perl port of L<https://support.googlecode.com/svn/trunk/scripts/googlecode_upload.py>

Basically you need L<googlecode_upload> script instead.

=head1 METHODS

=head2 new

Constructs a new C<Google::Code::Upload> object. Takes the following key-value
pairs:

=over 4

=item username

=item password (your Google Code password from L<https://code.google.com/hosting/settings>)

=item project

=item ua - something that works like a L<LWP::UserAgent> (I<optional>)

=back

=cut

sub new {
    my $class = shift;
    my %args  = @_;
    $args{$_} || croak "You must provide $_" for qw(username password project);

    if ( $args{username} =~ /^(.*?)\@gmail\.com$/ ) {
        $args{username} = $1;
    }
    my $agent_string = defined $class->VERSION ? $class->VERSION : 'dev';

    my $self  = {
        ua          => $args{ua} || LWP::UserAgent->new( agent => $agent_string ),
        upload_uri  => "https://$args{project}.googlecode.com/files",
        password    => $args{password},
        username    => $args{username},
    };
    return bless $self, $class;
}

=head2 upload

Upload the given file to Google Code. Requires the following key-value pairs:

=over 4

=item file - the filename of the file to upload

=item summary - the one-line summary to give to the file (defaults to the filename)

=item labels - an arrayref of labels like C<Featured>, C<Type-Archive> or C<OpSys-All>

=back

You can also export the C<upload> function, if you don't want to use OO style.
Instead of key-value pairs, specify the arguments in the following order:

    use Google::Code::Upload qw(upload);
    upload( $file, $project_name, $username, $password, $summary, $labels );

=cut

sub upload {
    my $self;
    my $summary;
    my $labels;
    my $file;

    if (blessed $_[0]) {
        $self = shift;
        my %args = @_;
        $summary = $args{summary};
        $labels  = $args{labels} || [];
        $file    = $args{file};
    }
    else {
        $file           = shift;
        my $project     = shift;
        my $username    = shift;
        my $password    = shift;
        $summary        = shift;
        $labels         = shift || [];

        $self = __PACKAGE__->new(
            project     => $project,
            username    => $username,
            password    => $password,
        );
    }

    my $request = POST $self->{upload_uri},
        Content_Type => 'form-data',
        Content      => [
            summary     => $summary,
            ( map { (label => $_) } @$labels),
            filename    => [$file, basename($file), Content_Type => 'application/octet-stream'],
        ];
    $request->authorization_basic($self->{username}, $self->{password});

    my $response = $self->{ua}->request($request);

    if ($response->code == 201) {
        return ( $response->code, $response->status_line, $response->header('Location') );
    }
    else {
        return ( $response->code, $response->status_line, undef );
    }
}

1;
