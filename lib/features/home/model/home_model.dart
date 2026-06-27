/// Resumo do dashboard (contadores para os cards da home).
/// Resposta de GET api/dashboard.php.
class DashboardResumoModel {
  final int idEmpresa;
  final int totalClientes;
  final int totalProdutos;
  final int totalPedidosConcluidos;

  const DashboardResumoModel({
    required this.idEmpresa,
    required this.totalClientes,
    required this.totalProdutos,
    required this.totalPedidosConcluidos,
  });

  factory DashboardResumoModel.fromJson(Map<String, dynamic> json) {
    return DashboardResumoModel(
      idEmpresa: _intFromJson(json, 'id_empresa'),
      totalClientes: _intFromJson(json, 'total_clientes'),
      totalProdutos: _intFromJson(json, 'total_produtos'),
      totalPedidosConcluidos: _intFromJson(json, 'total_pedidos_concluidos'),
    );
  }

  static int _intFromJson(Map<String, dynamic> json, String key) {
    final v = json[key];
    if (v is int) return v;
    if (v != null) return int.tryParse(v.toString()) ?? 0;
    return 0;
  }
}
