#!perl

use strict;
use warnings;

use Test::Most;

use Buscape::API;

my $agent = Buscape::API->new( app_id => 'foobar' );

ok( $agent->app_id eq 'foobar',               'Application ID' );
ok( $agent->env eq 'sandbox',                 'Ambiente default' );
ok( $agent->service eq 'sandbox.buscape.com', 'Service default' );
ok( $agent->country eq 'BR',                  'País default' );
ok( $agent->format eq 'json',                 'Formato default' );

isa_ok( $agent->ua, 'LWP::UserAgent', 'User Agent default' );

done_testing;
