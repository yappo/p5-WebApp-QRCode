package WebApp::QRCode;
use strict;
use warnings;
our $VERSION = '0.01';
use overload '&{}' => sub { shift->to_app(@_) }, fallback => 1;

use Plack::Request;
use Imager::QRCode;

our %MIME_TYPES = (
    gif  => 'image/gif',
    png  => 'image/png',
    jpeg => 'image/jpeg',
);

sub new {
    my($class, %args) = @_;

    my $filetype = delete $args{filetype} || '';
    $filetype = 'png' unless $MIME_TYPES{$filetype};

    my $queryname = delete $args{queryname} || 'body';

    bless {
        qr        => Imager::QRCode->new(%args),
        queryname => $queryname,
        filetype  => $filetype,
    }, $class;
}

sub call {
    my($self, $env) = @_;

    my $req = Plack::Request->new($env);
    my $img = $self->{qr}->plot($req->parameters->get($self->{queryname}));
    $img->write( data => \my $data, type => $self->{filetype} ) or do {
        my $msg = $img->errstr;
        return [
            500,
            [
                'Content-Type'   => 'text/html',
                'Content-Length' => length($msg),
            ],
            [ $msg ],
        ];
    };

    return [
        200,
        [
            'Content-Type'   => $MIME_TYPES{$self->{filetype}},
            'Content-Length' => length($data),
        ],
        [ $data ],
    ];
}

sub to_app {
    my $self = shift;
    return sub { $self->call(@_) };
}

1;
__END__

=head1 NAME

WebApp::QRCode -

=head1 SYNOPSIS

app.psgi

  use WebApp::QRCode;
  use Plack::Builder;

  builder {
      mount '/qrcode' => WebApp::QRCode->new;
      mount '/'       => $app;
  };

in shell

  $ plackup -p 5000 app.psgi
  $ wget "http://localhost:5000/qrcode?body=foobar

=head1 DESCRIPTION

WebApp::QRCode is

=METHODS

=head2 new( filetype => 'png', queryname => 'body', %ImagerQRcodeOptions )

=head2 to_app

=head2 call

=head1 AUTHOR

Kazuhiro Osawa E<lt>yappo {at} shibuya {dot} plE<gt>

=head1 SEE ALSO

L<Imager::QRCode>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
