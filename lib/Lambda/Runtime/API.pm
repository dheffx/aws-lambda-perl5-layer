package Lambda::Runtime::API;
use HTTP::Tiny;
use JSON::XS qw/encode_json/;

=pod

=head1 Lambda::Runtime::API

Wrapper for https://docs.aws.amazon.com/lambda/latest/dg/runtimes-api.html

=head2 new

Initialize the class using API URL

=cut

sub new {
  my ($class, %args) = @_;
  $args{API_URL} //= $ENV{'AWS_LAMBDA_RUNTIME_API'};

  return bless {
    base_url => "http://$args{API_URL}/2018-06-01/runtime",
    http => HTTP::Tiny->new()
  }, $class;
}

=head2 url

Returns the full URL for a request

Concats the base_url with the passed in route

=cut

sub url {
  my ($self, $route) = @_;
  return $self->{base_url} . "/$route";
}

=head2 next

Get the next event
If not successful, die
Otherwise return response

=cut

sub next {
  my $self = shift;
  my $resp = $self->{http}->get($self->url('invocation/next'));
  _die_unless_success('retrieve the next event', $resp);
  return $resp;
}

=head2 respond

Post the function response back to the Lambda API

If the api does not return success, die

=cut

sub respond {
  my ($self, $request_id, $result) = @_;
  my $resp = $self->{http}->post($self->url("invocation/$request_id/response"), {
    content => encode_json($result),
  });
  _die_unless_success('response for execution', $resp);
}

=head2 initialization_error

Post an error to the initializatoin error endpoint

=cut

sub initialization_error {
  my $self = shift;
  return $self->error("init/error", @_);
}

=head2 invocation_error

Post an error to the invocation error endpoint for the request id

=cut

sub invocation_error {
  my $self = shift;
  my $request_id = shift;
  return $self->error("invocation/$request_id/error", @_);
}

=head2 error

Posts an error to a given route as JSON
If the API does not return success, die

=cut

sub error {
  my ($self, $route, $type, $msg) = @_;
  my $resp = $self->{http}->post(
    $self->url($route),
    encode_json({
      'errorMessage' => $msg,
      'errorType' => $type
    })
  );
  _die_unless_success('post error for event', $resp);
}

=head2 _die_resp

Die with a message formatted with response status and reason

=cut

sub _die_unless_success {
  my ($resp, $msg) = @_;
  die "failed to $msg: $resp->{status} $resp->{reason}"
    unless $resp->{success};
}

1;