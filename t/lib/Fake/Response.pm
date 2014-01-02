package Fake::Response;

use Moo;
use File::Slurp qw{ read_file };

has 'format' => (
    'is'      => 'ro',
    'default' => sub { 'json' }
);

has 'code' => (
    'is'      => 'ro',
    'default' => sub { 200 }
);

has 'content' => (
    'is'      => 'ro',
    'default' => sub { read_file('t/data/response.json') },
);

1;
