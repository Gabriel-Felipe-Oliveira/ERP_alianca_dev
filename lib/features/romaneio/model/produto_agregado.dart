/// Capacidade fixa do caminhão em volumes (até a API expor esse dado).
const int capacidadeCaminhaoVolumes = 800;

/// Produto agrupado no romaneio (soma de quantidades e subtotais de todos os pedidos).
class ProdutoAgregado {
  const ProdutoAgregado({
    required this.idProduto,
    required this.nome,
    required this.quantidadeTotal,
    required this.subtotalTotal,
  });

  final int idProduto;
  final String nome;
  final int quantidadeTotal;
  final double subtotalTotal;
}
