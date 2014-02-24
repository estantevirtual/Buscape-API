#!perl

use strict;
use warnings;

use Test::Most;
use Buscape::API;

use lib 't/lib';
use Fake::UA;

my $agent = Buscape::API->new(
    app_id    => 'foobar',
    source_id => 'etc123',
    env       => 'business',
    country   => 'AR',
    format    => 'xml',
    ua        => Fake::UA->new,
);

ok( $agent->app_id eq 'foobar',           'Application ID' );
ok( $agent->env eq 'business',            'Ambiente selecionado' );
ok( $agent->service eq 'bws.buscape.com', 'Service selecionado' );
ok( $agent->country eq 'AR',              'País selecionado' );
ok( $agent->format eq 'xml',              'Formato selecionado' );

isa_ok( $agent->ua, 'Fake::UA', 'User Agent selecionado' );

done_testing;
