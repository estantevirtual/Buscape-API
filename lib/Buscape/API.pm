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

# ABSTRACT: Wrapper em torno da API do Buscape

=encoding utf8

=method new( %args )

Construtor. Instancia o objeto da API utilizando os argumentos passados.

Os argumentos podem ser:

=over 4

=item B<app_id>: Obrigatório. ID da aplicação criada junto ao Buscapé.
Veja como fazer isso em L<http://developer.buscape.com/tutoriais/procedimentos-para-desenvolver-sua-aplicacao/>.

=item B<env>: O ambiente onde a API vai se conectar. Pode ter os valores
'sandbox' ou 'business'. O default é sandbox.

=item B<country>: A sigla do país onde buscar os dados. Pode ter os valores:
BR (Brasil), AR (Argentina), CO (Colômbia), CL (Chile), MX (México), PE (Peru)
ou VE(Venezuela).

=item B<ua>: User Agent que utilizado para fazer a requisição. O valor default
é uma instância de um objeto C<LWP::UserAgent> sem argumentos.

=back

    use Buscape::API;
    use WWW::Mechanize;
    
    my $api = Buscape::API->new(
        app_id  => 'foobar',
        env     => 'busuness',
        country => 'BR',
        ua      => WWW::Mechanize->new,
    );

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

=method query( %args )

Realiza a requisição sobre a API do Buscapé. A maioria dos argumentos pode ser
obtida na documentação oficial da API em
L<http://developer.buscape.com/api/apis-e-documentacao-buscape/>.

O formato de retorno pode ser escolhido entre json ou xml, utilizando a chave
C<format>.

O método a ser executado deve ser passado na chave C<method> e pode conter os
seguintes valores:

=over 4

=item B<find_category_list>: Retorna a lista de categorias disponiveis;

=item B<find_product_list>: Retorna uma lista de produtos;

=item B<find_offer_list>: Retorna uma lista de ofertas;

=item B<top_products>: Retorna a lista com os produtos mais populares;

=item B<view_user_ratings>: Retorna as avaliações dos usuários de um
determinado produto;

=item B<view_product_details>: Retorna os detalhes técnicos de um
determinado produto;

=item B<view_seller_details>: Retorna os detalhes de uma determinada loja;

=back

    my $res = $api->query(
        method      => 'find_product_list',
        format      => 'json',
        categoryId  => '3482',
        keyword     => 'memorias+postumas+de+bras+cubas',
    );

    my $data = $res->code == 200 ? JSON::from_json( $res->content ) : {};

Os outros argumentos podem ser obtidos na documentação oficial da API.

=cut
