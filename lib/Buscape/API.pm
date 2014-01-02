use utf8;

package Buscape::API;

use Moo;
use URI;
use Carp;
use Const::Fast;

use List::MoreUtils qw{ any };

const our %METHODS => (
    'find_category_list'   => 'findCategoryList',
    'find_product_list'    => 'findProductList',
    'find_offer_list'      => 'findOfferList',
    'top_products'         => 'topProducts',
    'view_user_ratings'    => 'viewUserRatings',
    'view_product_details' => 'viewProductDetails',
    'view_seller_details'  => 'viewSellerDetails',
);

const our %COUNTRIES => (
    'BR' => 'Brasil',
    'AR' => 'Argentina',
    'CO' => 'Colômbia',
    'CL' => 'Chile',
    'MX' => 'México',
    'PE' => 'Peru',
    'VE' => 'Venezuela',
);

const our %SERVICES => (
    'business' => 'bws.buscape.com',
    'sandbox'  => 'sandbox.buscape.com',
);

has 'app_id' => (
    'is'       => 'ro',
    'required' => 1,
);

has 'env' => (
    'is'  => 'ro',
    'isa' => sub {
        Carp::croak '"env" precisa ser "business" ou "sandbox"'
          unless $_[0] =~ m{business|sandbox};
    },
    'default' => sub { 'sandbox' },
    'lazy'    => 1,

);

has 'country' => (
    'is'  => 'ro',
    'isa' => sub {
        my ($current) = @_;

        my @keys = sort keys %COUNTRIES;
        my $values = join ', ', map { qq{"$_"} } @keys;

        Carp::croak '"country" precisa ser um dos valores: ' . $values
          unless any { $_ eq $current } @keys;
    },
    'default' => sub { 'BR' },
    'lazy'    => 1,

);

has 'service' => (
    'is'      => 'ro',
    'builder' => sub { $SERVICES{ shift->env }; },
    'lazy'    => 1,
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

    my $service = $self->service;
    my $method  = $METHODS{ delete $args{method} };
    my $app_id  = $self->app_id;
    my $country = $self->country;
    my $ua      = $self->ua;

    my $uri = URI->new("http://$service/service/$method/$app_id/$country");
    $uri->query_form(%args);

    return $ua->get($uri);
}

1;

# ABSTRACT: Wrapper em torno da API do Buscapé

=method new( %args )

Construtor. Instancia o objeto da API utilizando os argumentos passados.

Os argumentos podem ser:

    * app_id: Obrigatório. ID da aplicação criada junto ao Buscapé. Veja como
    fazer isso em L<http://developer.buscape.com/tutoriais/procedimentos-para-desenvolver-sua-aplicacao/>.
    
    * env: O ambiente onde a API vai se conectar. 

=method app_id

Retorna o ID da aplicação selecionado no build do objeto.

=method env

Retorna o ambiente selecionado no build do objeto, podendo ter os valores
C<sandbox> (default) ou C<business> (ambiente de produção).

=method country

Retorna o país selecionado durante o build do objeto, podendo ter um dos
valores: C<AR>, C<BR>, C<CL>, C<CO>, C<MX>, C<PE> ou C<VE>.

=method service

Retorna o hostname onde está o ambiente selecionado, podendo ter os valores
C<sandbox.buscape.com> (sandbox, o default) ou C<bws.buscape.com> (ambiente
de produção).

=cut
