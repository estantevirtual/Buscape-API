#!perl

use strict;
use warnings;

use Test::Most;

use Buscape::API;

use lib 't/lib';
use Fake::UA;
use JSON qw{ from_json };
use List::Util qw{ min max };

my $agent = Buscape::API->new(
    app_id    => 'foobar',
    source_id => 'etc123',
    ua        => Fake::UA->new,
);

my $res = $agent->query(
    'method'     => 'find_product_list',
    'categoryId' => 3482,
    'keyword'    => 'machado-de-assis-memorias-postumas-de-bras-cubas'
);

my $content = from_json( $res->content );

my @keys = qw{ totalsellers pricemax numoffers pricemin productname };
my @products;
foreach my $product ( @{ $content->{product} } ) {
    my %product;
    @product{@keys} = @{ $product->{product} }{@keys};
    push @products, \%product;
}

my $min = min map { $_->{pricemin} } @products;
my $max = max map { $_->{pricemax} } @products;

ok( scalar(@products) == 16,     'Processados 16 produtos' );
ok( abs( $min - 7.64 ) < 0.001,  'Preço mínimo' );
ok( abs( $max - 71.90 ) < 0.001, 'Preço máximo' );

done_testing;
