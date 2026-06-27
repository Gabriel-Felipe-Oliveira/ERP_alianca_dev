import 'package:erp_alianca_dev/features/produtos/model/produto_model.dart';

/// Uma linha de item no pedido (produto + quantidade + opcional valor_desconto).
/// Total = valor efetivo × quantidade. Valor efetivo = valorDesconto ?? produto.preco.
/// Usado no fluxo de seleção de produtos (criar pedido e editar pedido).
class ItemPedidoLinha {
  final ProdutoModel produto;
  final int quantidade;
  /// Quando preenchido, usado como preço unitário no lugar de [produto.preco] (e enviado como valor_desconto na API).
  final double? valorDesconto;

  ItemPedidoLinha({
    required this.produto,
    required this.quantidade,
    this.valorDesconto,
  });

  /// Preço unitário efetivo: desconto se informado, senão preço do produto.
  double get valorEfetivo => valorDesconto ?? produto.preco;

  double get totalLinha => valorEfetivo * quantidade;
}
