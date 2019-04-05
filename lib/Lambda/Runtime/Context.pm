package Lambda::Runtime::Context;
use JSON::XS qw/decode_json/;
use Time::HiRes qw/gettimeofday/;

=pod

=head1 Lambda::Runtime::Context

A quick implementation of https://docs.aws.amazon.com/lambda/latest/dg/java-context-object.html in Perl

=head2 new

Initialize the class using the env vars and input headers 

=cut

sub new {
  my ($class, $headers) = @_;

  my $self = bless {
    aws_request_id => $headers->{'lambda-runtime-aws-request-id'},
    deadline_ms => int($headers->{'lambda-runtime-deadline-ms'}),
    invoked_function_arn => $headers->{'lambda-runtime-invoked-function-arn'},
    log_group_name => $ENV{'AWS_LAMBDA_LOG_GROUP_NAME'},
    log_stream_name => $ENV{'AWS_LAMBDA_LOG_STREAM_NAME'},
    function_name => $ENV{'AWS_LAMBDA_FUNCTION_NAME'},
    function_version => $ENV{'AWS_LAMBDA_FUNCTION_VERSION'},
    memory_limit_in_mb => $ENV{'AWS_LAMBDA_FUNCTION_MEMORY_SIZE'}
  }, $class;
  $self->_set_decoded_if_exists('client_context', $headers->{'lambda-runtime-client-context'});
  $self->_set_decoded_if_exists('identity', $headers->{'lambda-runtime-cognito-identity'});

  return $self;
}

=head2 get_remaining_time_in_millis

Return the amount of milliseconds remaining until the function times out

=cut

sub get_remaining_time_in_millis {
  my $self = shift;
  my ($seconds, $micro) = gettimeofday();
  my $ms = $micro + $seconds * 1000;
  return $self->deadline_ms - $ms;
}

=head2 _set_decoded_if_exists

Given a key and value, 
If the value is truthy, it will decode the value as json
and set it on the object with the key

=cut

sub _set_decoded_if_exists {
  my ($self, $key, $val) = @_;
  if ($val) {
    $self->{$key} = decode_json($val);
  }
}

1;