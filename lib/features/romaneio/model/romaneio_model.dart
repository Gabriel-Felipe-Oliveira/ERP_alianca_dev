import 'package:erp_alianca_dev/features/pedidos/model/pedido_model.dart';

/// Status do romaneio (API: em_rota, concluido, cancelado; rascunho legado).
enum RomaneioStatus {
  rascunho('Rascunho'),
  emRota('Em rota'),
  concluido('Concluído'),
  cancelado('Cancelado');

  const RomaneioStatus(this.label);
  final String label;

  /// Converte string da API para enum.
  static RomaneioStatus fromApi(String? value) {
    if (value == null || value.isEmpty) return RomaneioStatus.rascunho;
    switch (value) {
      case 'rascunho':
        return RomaneioStatus.rascunho;
      case 'em_rota':
        return RomaneioStatus.emRota;
      case 'concluido':
        return RomaneioStatus.concluido;
      case 'cancelado':
        return RomaneioStatus.cancelado;
      default:
        return RomaneioStatus.rascunho;
    }
  }
}

/// Tipo de motorista do romaneio.
enum TipoMotorista {
  proprio('Motorista Próprio'),
  agregado('Motorista Agregado');

  const TipoMotorista(this.label);
  final String label;
}

/// Entidade logística que agrupa múltiplos pedidos para entrega.
class RomaneioModel {
  final int? id;
  final String numero;
  final DateTime dataCriacao;
  final RomaneioStatus status;
  final TipoMotorista tipoMotorista;
  final String? nomeMotorista;
  final String? placaVeiculo;
  final String observacao;
  final List<PedidoListagemModel> listaPedidos;
  /// IDs dos pedidos retornados pela API (campo "pedidos": [5, 11, 12]).
  final List<int> idPedidos;
  final double valorTotal;
  final int quantidadePedidos;
  /// Total faturado do romaneio (API: total_faturado).
  final double totalFaturado;

  const RomaneioModel({
    this.id,
    required this.numero,
    required this.dataCriacao,
    required this.status,
    required this.tipoMotorista,
    this.nomeMotorista,
    this.placaVeiculo,
    required this.observacao,
    required this.listaPedidos,
    List<int>? idPedidos,
    required this.valorTotal,
    required this.quantidadePedidos,
    this.totalFaturado = 0,
  }) : idPedidos = idPedidos ?? const [];

  /// Nome para exibição: usa [numero] se preenchido, senão ROM-{id} (ex: ROM-00016).
  static String nomeExibicao(RomaneioModel r) {
    if (r.numero.trim().isNotEmpty) return r.numero;
    if (r.id != null) return 'ROM-${r.id!.toString().padLeft(5, '0')}';
    return '—';
  }

  /// Calcula [valorTotal] e [quantidadePedidos] a partir de [listaPedidos].
  static (double valorTotal, int quantidadePedidos) calcularTotais(
    List<PedidoListagemModel> pedidos,
  ) {
    final valorTotal = pedidos.fold<double>(
      0,
      (sum, p) => sum + p.total,
    );
    return (valorTotal, pedidos.length);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numero': numero,
      'data_criacao': dataCriacao.toIso8601String(),
      'status': status.name,
      'tipo_motorista': tipoMotorista.name,
      'nome_motorista': nomeMotorista,
      'placa_veiculo': placaVeiculo,
      'observacao': observacao,
      'id_pedidos': listaPedidos.map((p) => p.idPedido).toList(),
      'valor_total': valorTotal,
      'quantidade_pedidos': quantidadePedidos,
    };
  }

  factory RomaneioModel.fromJson(Map<String, dynamic> json) {
    final status = RomaneioStatus.fromApi(json['status'] as String?);
    final tipoStr = json['tipo_motorista'] as String? ?? 'proprio';
    final tipoMotorista = TipoMotorista.values.firstWhere(
      (t) => t.name == tipoStr,
      orElse: () => TipoMotorista.proprio,
    );
    // Listagem envia created_at; detalhe pode enviar data_criacao
    final dataCriacaoRaw = json['data_criacao'] ?? json['created_at'];
    final dataCriacao = dataCriacaoRaw != null
        ? DateTime.tryParse(dataCriacaoRaw as String) ?? DateTime.now()
        : DateTime.now();
    final lista = json['lista_pedidos'] is List
        ? (json['lista_pedidos'] as List)
            .map((e) => PedidoListagemModel.fromJson(e as Map<String, dynamic>))
            .toList()
        : <PedidoListagemModel>[];
    // Detalhe envia "pedidos": [5, 11, 12].
    final pedidosArray = json['pedidos'] ?? json['id_pedidos'];
    final qtdFromPedidosArray = pedidosArray is List ? pedidosArray.length : 0;
    final idPedidos = pedidosArray is List
        ? pedidosArray
            .map((e) => e is int ? e : int.tryParse(e?.toString() ?? '') ?? 0)
            .where((id) => id > 0)
            .toList()
        : <int>[];
    final (valorTotal, quantidadePedidos) = calcularTotais(lista);
    final valorTotalJson = json['valor_total'];
    final valorTotalFromJson = valorTotalJson is int
        ? valorTotalJson.toDouble()
        : valorTotalJson is num
            ? valorTotalJson.toDouble()
            : double.tryParse(valorTotalJson?.toString() ?? '') ?? valorTotal;
    final qtdRaw = json['quantidade_pedidos'] ?? json['qtd_pedidos'];
    final qtdFromApi = qtdRaw is int
        ? qtdRaw
        : int.tryParse(qtdRaw?.toString() ?? '');
    final qtdFromJson = qtdFromPedidosArray > 0
        ? qtdFromPedidosArray
        : (qtdFromApi ?? lista.length);

    final idRaw = json['id'] ?? json['id_romaneio'];
    final id = idRaw == null
        ? null
        : (idRaw is int ? idRaw : int.tryParse(idRaw.toString()));
    // Motorista: API pode enviar motorista_entregador, nome_motorista ou motorista
    final nomeMotorista = (json['nome_motorista'] as String?)?.trim().isNotEmpty == true
        ? json['nome_motorista'] as String?
        : (json['motorista_entregador'] as String?)?.trim().isNotEmpty == true
            ? (json['motorista_entregador'] as String?)?.trim()
            : (json['motorista'] as String?)?.trim().isNotEmpty == true
                ? (json['motorista'] as String?)?.trim()
                : null;
    final totalFaturadoRaw = json['total_faturado'];
    final totalFaturado = totalFaturadoRaw is int
        ? totalFaturadoRaw.toDouble()
        : totalFaturadoRaw is num
            ? totalFaturadoRaw.toDouble()
            : double.tryParse(totalFaturadoRaw?.toString() ?? '') ?? 0.0;
    return RomaneioModel(
      id: id,
      numero: json['numero'] as String? ?? '',
      dataCriacao: dataCriacao,
      status: status,
      tipoMotorista: tipoMotorista,
      nomeMotorista: nomeMotorista?.isEmpty == true ? null : nomeMotorista,
      placaVeiculo: (json['placa_veiculo'] ?? json['placa']) as String?,
      observacao: json['observacao'] as String? ?? '',
      listaPedidos: lista,
      idPedidos: idPedidos,
      valorTotal: valorTotalFromJson,
      quantidadePedidos: qtdFromJson,
      totalFaturado: totalFaturado,
    );
  }
}
