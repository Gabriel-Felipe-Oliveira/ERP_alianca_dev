/// Filtros do GET api/dashboard/totais.
class DashboardTotaisFiltros {
  const DashboardTotaisFiltros({
    this.dataInicio,
    this.dataFim,
    this.status,
    this.includeDeleted = false,
  });

  final String? dataInicio;
  final String? dataFim;
  final String? status;
  final bool includeDeleted;

  Map<String, dynamic> toQueryParameters() {
    return <String, dynamic>{
      if (dataInicio != null && dataInicio!.isNotEmpty)
        'data_inicio': dataInicio,
      if (dataFim != null && dataFim!.isNotEmpty) 'data_fim': dataFim,
      if (status != null && status!.trim().isNotEmpty) 'status': status,
      if (includeDeleted) 'include_deleted': true,
    };
  }
}

/// Resumo agregado (quantidade + valor) retornado pela API de totais.
class DashboardTotaisResumo {
  const DashboardTotaisResumo({
    required this.quantidade,
    required this.valorTotal,
  });

  final int quantidade;
  final double valorTotal;

  static const DashboardTotaisResumo vazio =
      DashboardTotaisResumo(quantidade: 0, valorTotal: 0);

  factory DashboardTotaisResumo.fromJson(Map<String, dynamic>? json) {
    if (json == null) return vazio;
    return DashboardTotaisResumo(
      quantidade: _intFrom(json['quantidade']),
      valorTotal: _doubleFrom(json['valor_total']),
    );
  }
}

/// Totais de pedidos no envelope da API.
class DashboardTotaisPedidos {
  const DashboardTotaisPedidos({required this.resumo});

  final DashboardTotaisResumo resumo;

  static const DashboardTotaisPedidos vazio =
      DashboardTotaisPedidos(resumo: DashboardTotaisResumo.vazio);

  factory DashboardTotaisPedidos.fromJson(Map<String, dynamic>? json) {
    if (json == null) return vazio;
    return DashboardTotaisPedidos(
      resumo: DashboardTotaisResumo.fromJson(
        json['resumo'] as Map<String, dynamic>?,
      ),
    );
  }
}

/// Totais de romaneios no envelope da API.
class DashboardTotaisRomaneios {
  const DashboardTotaisRomaneios({required this.resumo});

  final DashboardTotaisResumo resumo;

  static const DashboardTotaisRomaneios vazio =
      DashboardTotaisRomaneios(resumo: DashboardTotaisResumo.vazio);

  factory DashboardTotaisRomaneios.fromJson(Map<String, dynamic>? json) {
    if (json == null) return vazio;
    return DashboardTotaisRomaneios(
      resumo: DashboardTotaisResumo.fromJson(
        json['resumo'] as Map<String, dynamic>?,
      ),
    );
  }
}

/// Resposta parseada de GET api/dashboard/totais.
class DashboardTotaisModel {
  const DashboardTotaisModel({
    required this.pedidos,
    required this.romaneios,
  });

  final DashboardTotaisPedidos pedidos;
  final DashboardTotaisRomaneios romaneios;

  static const DashboardTotaisModel vazio = DashboardTotaisModel(
    pedidos: DashboardTotaisPedidos.vazio,
    romaneios: DashboardTotaisRomaneios.vazio,
  );

  factory DashboardTotaisModel.fromJson(Object? raw) {
    if (raw is! Map) return vazio;
    final map = Map<String, dynamic>.from(raw);
    final data = map['data'];
    if (data is! Map) return vazio;
    final dataMap = Map<String, dynamic>.from(data);
    final totais = dataMap['totais'];
    if (totais is! Map) return vazio;
    final totaisMap = Map<String, dynamic>.from(totais);
    return DashboardTotaisModel(
      pedidos: DashboardTotaisPedidos.fromJson(
        totaisMap['pedidos'] as Map<String, dynamic>?,
      ),
      romaneios: DashboardTotaisRomaneios.fromJson(
        totaisMap['romaneios'] as Map<String, dynamic>?,
      ),
    );
  }
}

int _intFrom(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _doubleFrom(Object? value) {
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
