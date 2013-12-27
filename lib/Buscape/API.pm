package Buscape::API;

use Moo;

use URI;
use JSON;
use Const::Fast;

const our $METHODS => {
    'categories'      => 'findCategoryList',
    'products'        => 'findProductList',
    'offers'          => 'findOfferList',
    'top_products'    => 'topProducts',
    'ratings'         => 'viewUserRatings',
    'product_details' => 'viewProductDetails',
    'seller_details'  => 'viewSellerDetails',
};

const our $COUNTRIES => {
    'BR' => 'Brasil',
    'AR' => 'Argentina',
    'CO' => 'Colômbia',
    'CL' => 'Chile',
    'MX' => 'México',
    'PE' => 'Peru',
    'VE' => 'Venezuela',
};

has 'sandbox' => (
    'is'      => 'ro',
    'builder' => sub { 'sandbox.buscape.com' },
);

has 'business' => (
    'is'      => 'ro',
    'builder' => sub { 'bws.buscape.com' },
);

has 'env' => (
    'is'      => 'ro',
    'default' => sub { 'sandbox' },
    'lazy'    => 1,
);

has 'service' => (
    'is'      => 'ro',
    'lazy'    => 1,
    'builder' => sub {
        my ($self) = @_;

        return $self->env eq 'sandbox'
          ? $self->sandbox
          : $self->business;
    },
);

has 'country' => (
    'is'      => 'ro',
    'default' => sub { 'BR' },
    'lazy'    => 1,
);

has 'app_id' => (
    'is'       => 'ro',
    'required' => 1,
);

has 'format' => (
    'is'      => 'ro',
    'lazy'    => 1,
    'default' => sub { 'json' },
);

has 'ua' => (
    'is'      => 'ro',
    'default' => sub {
        require LWP::UserAgent;
        return LWP::UserAgent->new;
    },
);

sub query {
    my ( $self, %args ) = @_;

    $args{format} = $self->format
      unless exists $args{format};

    my $service = $self->service;
    my $method  = $METHODS->{ delete $args{method} };
    my $app_id  = $self->app_id;
    my $country = $self->country;
    my $ua      = $self->ua;

    my $uri = URI->new("http://$service/service/$method/$app_id/$country");
    $uri->query_form(%args);

    my $res = $ua->get($uri);

    return $res->code == 200 ? from_json( $res->content ) : undef;
}

1;
