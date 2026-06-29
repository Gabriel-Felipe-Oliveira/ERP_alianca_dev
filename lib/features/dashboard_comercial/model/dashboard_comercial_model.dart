/// Filtros enviados/recebidos do GET api/dashboard.
class DashboardComercialFiltros {
  const DashboardComercialFiltros({
    required this.dataInicio,
    required this.dataFim,
    required this.agrupamento,
    this.idProduto,
    this.statusPedido,
    this.includeDeleted = false,
  });

  final String dataInicio;
  final String dataFim;
  final String agrupamento;
  final int? idProduto;
  final String? statusPedido;
  final bool includeDeleted;

  factory DashboardComercialFiltros.fromJson(Map<String, dynamic> json) {
    return DashboardComercialFiltros(
      dataInicio: json['data_inicio']?.toString() ?? '',
      dataFim: json['data_fim']?.toString() ?? '',
      agrupamento: json['agrupamento']?.toString() ?? 'diario',
      idProduto: _nullableInt(json['id_produto']),
      statusPedido: json['status_pedido']?.toString(),
      includeDeleted: json['include_deleted'] == true,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return <String, dynamic>{
      'data_inicio': dataInicio,
      'data_fim': dataFim,
      'agrupamento': agrupamento,
      if (idProduto != null) 'id_produto': idProduto,
      if (statusPedido != null && statusPedido!.trim().isNotEmpty)
        'status_pedido': statusPedido,
      'include_deleted': includeDeleted,
    };
  }
}

class DashboardComercialCards {
  const DashboardComercialCards({
    required this.totalVendas,
    required this.totalPedidos,
    required this.ticketMedio,
    required this.totalProdutosVendidos,
    required this.totalClientesEmpresasCompradoras,
  });

  final double totalVendas;
  final int totalPedidos;
  final double ticketMedio;
  final int totalProdutosVendidos;
  final int totalClientesEmpresasCompradoras;

  factory DashboardComercialCards.fromJson(Map<String, dynamic> json) {
    return DashboardComercialCards(
      totalVendas: _doubleFrom(json['total_vendas']),
      totalPedidos: _intFrom(json['total_pedidos']),
      ticketMedio: _doubleFrom(json['ticket_medio']),
      totalProdutosVendidos: _intFrom(json['total_produtos_vendidos']),
      totalClientesEmpresasCompradoras:
          _intFrom(json['total_clientes_empresas_compradoras']),
    );
  }
}

class DashboardPeriodoValor {
  const DashboardPeriodoValor({
    required this.periodo,
    required this.total,
  });

  final String periodo;
  final double total;

  factory DashboardPeriodoValor.fromJson(Map<String, dynamic> json) {
    return DashboardPeriodoValor(
      periodo: json['periodo']?.toString() ?? '',
      total: _doubleFrom(json['total']),
    );
  }
}

class DashboardProdutoRanking {
  const DashboardProdutoRanking({
    required this.idProduto,
    required this.produto,
    this.quantidade,
    required this.valorTotal,
  });

  final int idProduto;
  final String produto;
  final int? quantidade;
  final double valorTotal;

  factory DashboardProdutoRanking.fromJson(Map<String, dynamic> json) {
    return DashboardProdutoRanking(
      idProduto: _intFrom(json['id_produto']),
      produto: json['produto']?.toString() ?? '',
      quantidade: json['quantidade'] == null
          ? null
          : _intFrom(json['quantidade']),
      valorTotal: _doubleFrom(json['valor_total']),
    );
  }
}

class DashboardClienteRanking {
  const DashboardClienteRanking({
    required this.idCliente,
    required this.nome,
    this.nomeEmpresa,
    this.cpfCnpj,
    required this.totalPedidos,
    required this.valorTotal,
  });

  final int idCliente;
  final String nome;
  final String? nomeEmpresa;
  final String? cpfCnpj;
  final int totalPedidos;
  final double valorTotal;

  String get nomeExibicao =>
      (nomeEmpresa != null && nomeEmpresa!.trim().isNotEmpty)
          ? nomeEmpresa!
          : nome;

  factory DashboardClienteRanking.fromJson(Map<String, dynamic> json) {
    return DashboardClienteRanking(
      idCliente: _intFrom(json['id_cliente']),
      nome: json['nome']?.toString() ?? '',
      nomeEmpresa: json['nome_empresa']?.toString(),
      cpfCnpj: json['cpf_cnpj']?.toString(),
      totalPedidos: _intFrom(json['total_pedidos']),
      valorTotal: _doubleFrom(json['valor_total']),
    );
  }
}

class DashboardUltimoPedido {
  const DashboardUltimoPedido({
    required this.idPedido,
    required this.dataPedido,
    required this.status,
    required this.valorTotal,
  });

  final int idPedido;
  final String dataPedido;
  final String status;
  final double valorTotal;

  factory DashboardUltimoPedido.fromJson(Map<String, dynamic> json) {
    return DashboardUltimoPedido(
      idPedido: _intFrom(json['id_pedido']),
      dataPedido: json['data_pedido']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      valorTotal: _doubleFrom(json['valor_total']),
    );
  }
}

class DashboardComercialGraficos {
  const DashboardComercialGraficos({
    required this.vendasPorPeriodo,
    required this.pedidosPorPeriodo,
    required this.produtosMaisVendidos,
    required this.produtosMaiorFaturamento,
    required this.clientesMaisCompraram,
  });

  final List<DashboardPeriodoValor> vendasPorPeriodo;
  final List<DashboardPeriodoValor> pedidosPorPeriodo;
  final List<DashboardProdutoRanking> produtosMaisVendidos;
  final List<DashboardProdutoRanking> produtosMaiorFaturamento;
  final List<DashboardClienteRanking> clientesMaisCompraram;

  factory DashboardComercialGraficos.fromJson(Map<String, dynamic> json) {
    return DashboardComercialGraficos(
      vendasPorPeriodo: _periodoList(json['vendas_por_periodo']),
      pedidosPorPeriodo: _periodoList(json['pedidos_por_periodo']),
      produtosMaisVendidos: _produtoList(json['produtos_mais_vendidos']),
      produtosMaiorFaturamento: _produtoList(json['produtos_maior_faturamento']),
      clientesMaisCompraram: _clienteList(json['clientes_mais_compraram']),
    );
  }
}

/// Payload completo de GET api/dashboard (campo `data` do envelope).
class DashboardComercialModel {
  const DashboardComercialModel({
    required this.filtros,
    required this.cards,
    required this.graficos,
    required this.ultimosPedidos,
  });

  final DashboardComercialFiltros filtros;
  final DashboardComercialCards cards;
  final DashboardComercialGraficos graficos;
  final List<DashboardUltimoPedido> ultimosPedidos;

  factory DashboardComercialModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final map = data is Map<String, dynamic>
        ? data
        : data is Map
            ? Map<String, dynamic>.from(data)
            : json;

    return DashboardComercialModel(
      filtros: DashboardComercialFiltros.fromJson(
        map['filtros'] is Map
            ? Map<String, dynamic>.from(map['filtros'] as Map)
            : const <String, dynamic>{},
      ),
      cards: DashboardComercialCards.fromJson(
        map['cards'] is Map
            ? Map<String, dynamic>.from(map['cards'] as Map)
            : const <String, dynamic>{},
      ),
      graficos: DashboardComercialGraficos.fromJson(
        map['graficos'] is Map
            ? Map<String, dynamic>.from(map['graficos'] as Map)
            : const <String, dynamic>{},
      ),
      ultimosPedidos: _ultimosPedidosList(map['ultimos_pedidos']),
    );
  }

  static const DashboardComercialModel vazio = DashboardComercialModel(
    filtros: DashboardComercialFiltros(
      dataInicio: '',
      dataFim: '',
      agrupamento: 'diario',
    ),
    cards: DashboardComercialCards(
      totalVendas: 0,
      totalPedidos: 0,
      ticketMedio: 0,
      totalProdutosVendidos: 0,
      totalClientesEmpresasCompradoras: 0,
    ),
    graficos: DashboardComercialGraficos(
      vendasPorPeriodo: [],
      pedidosPorPeriodo: [],
      produtosMaisVendidos: [],
      produtosMaiorFaturamento: [],
      clientesMaisCompraram: [],
    ),
    ultimosPedidos: [],
  );
}

List<DashboardPeriodoValor> _periodoList(Object? raw) {
  if (raw is! List) return const [];
  return raw
      .whereType<Map>()
      .map((e) => DashboardPeriodoValor.fromJson(Map<String, dynamic>.from(e)))
      .toList();
}

List<DashboardProdutoRanking> _produtoList(Object? raw) {
  if (raw is! List) return const [];
  return raw
      .whereType<Map>()
      .map((e) => DashboardProdutoRanking.fromJson(Map<String, dynamic>.from(e)))
      .toList();
}

List<DashboardClienteRanking> _clienteList(Object? raw) {
  if (raw is! List) return const [];
  return raw
      .whereType<Map>()
      .map((e) => DashboardClienteRanking.fromJson(Map<String, dynamic>.from(e)))
      .toList();
}

List<DashboardUltimoPedido> _ultimosPedidosList(Object? raw) {
  if (raw is! List) return const [];
  return raw
      .whereType<Map>()
      .map((e) => DashboardUltimoPedido.fromJson(Map<String, dynamic>.from(e)))
      .toList();
}

int _intFrom(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int? _nullableInt(Object? value) {
  if (value == null) return null;
  return _intFrom(value);
}

double _doubleFrom(Object? value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

/// Opções de agrupamento aceitas pela API.
const List<({String value, String label})> kDashboardAgrupamentos = [
  (value: 'diario', label: 'Diário'),
  (value: 'mensal', label: 'Mensal'),
  (value: 'anual', label: 'Anual'),
];

const List<({String value, String label})> kDashboardStatusPedidoFiltros = [
  (value: '', label: 'Todos os status'),
  (value: 'rascunho', label: 'Rascunho'),
  (value: 'confirmado', label: 'Confirmado'),
  (value: 'organizado', label: 'Organizado'),
  (value: 'concluido', label: 'Concluído'),
  (value: 'cancelado', label: 'Cancelado'),
];
