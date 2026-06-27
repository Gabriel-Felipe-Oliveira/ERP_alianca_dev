/// Dados do romaneio para geração do PDF (sem HTTP). Agrupado por produto (id_produto).
class RomaneioPdfData {
  final String numeroRomaneio;
  final DateTime data;
  final String status;
  final String placa;
  final String motorista;
  final int totalVolumes;
  final double totalFaturado;
  /// Produtos agrupados por id_produto: quantidade total e subtotal somados de todos os pedidos.
  final List<ProdutoAgregadoPdf> produtos;

  const RomaneioPdfData({
    required this.numeroRomaneio,
    required this.data,
    required this.status,
    required this.placa,
    required this.motorista,
    required this.totalVolumes,
    required this.totalFaturado,
    required this.produtos,
  });
}

/// Linha de produto agregado (soma de quantidades e subtotais em todos os pedidos do romaneio).
class ProdutoAgregadoPdf {
  final String nomeProduto;
  final int quantidadeTotal;
  final double subtotalTotal;

  const ProdutoAgregadoPdf({
    required this.nomeProduto,
    required this.quantidadeTotal,
    required this.subtotalTotal,
  });
}
