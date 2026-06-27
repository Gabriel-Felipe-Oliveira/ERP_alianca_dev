abstract class AppRoutes {
  // Home
  static const String home = '/';

  // Clientes
  static const String clientes = '/clientes';
  static const String clientesCriar = '/clientes/criar';
  static const String clientesDetalhes = '/clientes/detalhes';

  /// Gera o path real com o id do cliente: /clientes/detalhes/123
  static String clientesDetalhesId(int id) => '/clientes/detalhes/$id';
  // Produtos
  static const String produtos = '/produtos';
  static const String produtosCriar = '/produtos/criar';
  static const String produtosDetalhes = '/produtos/detalhes';

  /// Gera o path com o id do produto: /produtos/detalhes/123
  static String produtosDetalhesId(int id) => '/produtos/detalhes/$id';

  // Pedidos
  static const String pedidos = '/pedidos';
  static const String pedidosCriar = '/pedidos/criar';
  static const String pedidosDetalhes = '/pedidos/detalhes';

  /// Gera o path com o id do pedido: /pedidos/detalhes/123
  static String pedidosDetalhesId(int id) => '/pedidos/detalhes/$id';

  // Romaneio
  static const String romaneio = '/romaneio';
  static const String romaneioCriar = '/romaneio/criar';
  static const String romaneioDetalhes = '/romaneio/detalhes';

  /// Path com id: /romaneio/detalhes/123
  static String romaneioDetalhesId(int id) => '/romaneio/detalhes/$id';
}
