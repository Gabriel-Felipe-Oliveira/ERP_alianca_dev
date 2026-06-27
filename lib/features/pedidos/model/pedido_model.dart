/// Payload para POST criar pedido (api/pedidos.php).
/// Resposta 201: { "ok": true, "id_pedido": 10 }
/// Cria como rascunho; em seguida o app adiciona os itens e altera o status para confirmado.
class PedidoCriarPayload {
  final int idEmpresa;
  final int idCliente;
  final String observacao;
  final String status;
  final String pagamento;

  const PedidoCriarPayload({
    required this.idEmpresa,
    required this.idCliente,
    this.observacao = '',
    this.status = 'rascunho',
    this.pagamento = '',
  });

  Map<String, dynamic> toJson() => {
        'id_empresa': idEmpresa,
        'id_cliente': idCliente,
        'observacao': observacao,
        'status': status,
        'pagamento': pagamento,
        // Compatibilidade temporária com versões antigas do backend.
        'forma_pagamento': pagamento,
      };

  /// Retorna id_pedido da resposta ou null se inválida.
  static int? idPedidoFromResponse(Map<String, dynamic>? data) {
    if (data == null) return null;
    final ok = data['ok'] as bool? ?? false;
    if (!ok) return null;
    final id = data['id_pedido'];
    if (id is int) return id;
    if (id is num) return id.toInt();
    if (id is String) return int.tryParse(id);
    return null;
  }
}

/// Item da listagem GET api/pedidos.php (id_pedido, id_cliente, status, total, volume, created_at).
class PedidoListagemModel {
  final int idPedido;
  final int idEmpresa;
  final int idCliente;
  final String status;
  final double total;
  /// Volume do pedido (unidades) para cálculo de ocupação do romaneio.
  final int volume;
  final String? createdAt;
  /// Forma de pagamento (campo `pagamento` na API; fallback `forma_pagamento`).
  final String pagamento;

  const PedidoListagemModel({
    required this.idPedido,
    required this.idEmpresa,
    required this.idCliente,
    required this.status,
    required this.total,
    this.volume = 0,
    this.createdAt,
    this.pagamento = '',
  });

  factory PedidoListagemModel.fromJson(Map<String, dynamic> json) {
    final total = json['total'];
    final totalDouble = total is int
        ? total.toDouble()
        : total is num
            ? total.toDouble()
            : double.tryParse(total?.toString() ?? '') ?? 0.0;
    final volumeRaw = json['volume'];
    final volume = volumeRaw is int
        ? volumeRaw
        : int.tryParse(volumeRaw?.toString() ?? '') ?? 0;
    final pagamentoRaw = json['pagamento'];
    final formaPagamentoRaw = json['forma_pagamento'];
    String pagamentoStr = '';
    if (pagamentoRaw != null && pagamentoRaw.toString().trim().isNotEmpty) {
      pagamentoStr = pagamentoRaw.toString().trim();
    } else if (formaPagamentoRaw != null &&
        formaPagamentoRaw.toString().trim().isNotEmpty) {
      pagamentoStr = formaPagamentoRaw.toString().trim();
    }
    return PedidoListagemModel(
      idPedido: json['id_pedido'] is int
          ? json['id_pedido'] as int
          : int.tryParse(json['id_pedido']?.toString() ?? '') ?? 0,
      idEmpresa: json['id_empresa'] is int
          ? json['id_empresa'] as int
          : int.tryParse(json['id_empresa']?.toString() ?? '') ?? 0,
      idCliente: json['id_cliente'] is int
          ? json['id_cliente'] as int
          : int.tryParse(json['id_cliente']?.toString() ?? '') ?? 0,
      status: json['status'] as String? ?? '',
      total: totalDouble,
      volume: volume,
      createdAt: json['created_at'] as String?,
      pagamento: pagamentoStr,
    );
  }
}

/// Item do pedido retornado por GET api/pedido_itens.php.
class PedidoItemModel {
  final int idItem;
  final int idPedido;
  final int idEmpresa;
  final int idProduto;
  final int quantidade;
  final double precoUnitario;
  final double subtotal;

  const PedidoItemModel({
    required this.idItem,
    required this.idPedido,
    required this.idEmpresa,
    required this.idProduto,
    required this.quantidade,
    required this.precoUnitario,
    required this.subtotal,
  });

  factory PedidoItemModel.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is int) return v.toDouble();
      if (v is num) return v.toDouble();
      final s = v.toString().trim().replaceAll(',', '.');
      return double.tryParse(s) ?? 0.0;
    }
    final quantidade = json['quantidade'] is int
        ? json['quantidade'] as int
        : int.tryParse(json['quantidade']?.toString() ?? '') ?? 0;
    // valor_desconto = preço unitário de venda para esse cliente (não é "valor do desconto").
    // Se valor_desconto != 0 usa como unitário; senão usa preco_unitario.
    final valorDesconto = json.containsKey('valor_desconto') && json['valor_desconto'] != null
        ? toDouble(json['valor_desconto'])
        : 0.0;
    final precoUnitarioApi = toDouble(json['preco_unitario']);
    final precoUnitario = valorDesconto != 0 ? valorDesconto : precoUnitarioApi;
    // Subtotal vem do retorno da API (pedido_itens); se não vier, fallback: quantidade × valor unitário.
    double subtotal = 0.0;
    if (json.containsKey('subtotal') && json['subtotal'] != null) {
      subtotal = toDouble(json['subtotal']);
    }
    if (subtotal == 0) subtotal = precoUnitario * quantidade;
    return PedidoItemModel(
      idItem: json['id_item'] is int
          ? json['id_item'] as int
          : int.tryParse(json['id_item']?.toString() ?? '') ?? 0,
      idPedido: json['id_pedido'] is int
          ? json['id_pedido'] as int
          : int.tryParse(json['id_pedido']?.toString() ?? '') ?? 0,
      idEmpresa: json['id_empresa'] is int
          ? json['id_empresa'] as int
          : int.tryParse(json['id_empresa']?.toString() ?? '') ?? 0,
      idProduto: json['id_produto'] is int
          ? json['id_produto'] as int
          : int.tryParse(json['id_produto']?.toString() ?? '') ?? 0,
      quantidade: quantidade,
      precoUnitario: precoUnitario,
      subtotal: subtotal,
    );
  }
}

/// Payload para POST adicionar item (api/pedido_itens.php).
/// valor_desconto = preço unitário de venda (mesmo tipo que preco_unitario). Sempre enviado no body.
/// No backend: subtotal = quantidade × valor_desconto.
class PedidoItemPayload {
  final int idPedido;
  final int idEmpresa;
  final int idProduto;
  final int quantidade;
  /// Preço unitário de venda (mesmo tipo que preco_unitario). Valor na tela; quando null no payload, backend usa preco_unitario.
  final double? valorDesconto;

  const PedidoItemPayload({
    required this.idPedido,
    required this.idEmpresa,
    required this.idProduto,
    required this.quantidade,
    this.valorDesconto,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id_pedido': idPedido,
      'id_empresa': idEmpresa,
      'id_produto': idProduto,
      'quantidade': quantidade,
      'valor_desconto': valorDesconto,
    };
  }
}
