/// Estrutura do pedido para geração do recibo/cupom (conforme spec).
/// PDF em shared/pdf recebe Model como parâmetro (não faz HTTP).
class Pedido {
  final String id;
  final DateTime data;
  final String clienteNome;
  final String? clienteTelefone;
  final List<ItemPedido> itens;
  final double subtotal;
  final double desconto;
  final double total;
  final String formaPagamento;
  /// Opcional: cabeçalho. Se vazio, não imprime linha CNPJ.
  final String nomeEmpresa;
  final String cnpjEmpresa;
  /// Código do cliente no recibo (ex.: "#001").
  final String clienteCod;
  /// Endereço formatado do cliente para o recibo.
  final String enderecoCliente;

  const Pedido({
    required this.id,
    required this.data,
    required this.clienteNome,
    this.clienteTelefone,
    required this.itens,
    required this.subtotal,
    required this.desconto,
    required this.total,
    required this.formaPagamento,
    this.nomeEmpresa = '',
    this.cnpjEmpresa = '',
    this.clienteCod = '',
    this.enderecoCliente = '',
  });
}

/// Item do pedido no cupom (conforme spec).
/// [precoUnitario]: valor unitário (preco_unitario quando valor_desconto é 0, senão valor_desconto).
/// [subtotalLinha]: quando informado, usa o subtotal da API; senão calcula quantidade * precoUnitario.
class ItemPedido {
  final String nome;
  final int quantidade;
  final double precoUnitario;
  final double? subtotalLinha;

  const ItemPedido({
    required this.nome,
    required this.quantidade,
    required this.precoUnitario,
    this.subtotalLinha,
  });

  double get subtotal => subtotalLinha ?? (quantidade * precoUnitario);
}
