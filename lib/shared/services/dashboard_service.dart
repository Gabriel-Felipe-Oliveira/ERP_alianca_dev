import 'package:erp_alianca_dev/core/network/api_response.dart';
import 'package:erp_alianca_dev/core/network/dio_client.dart';
import 'package:erp_alianca_dev/features/dashboard_comercial/model/dashboard_comercial_model.dart';
import 'package:erp_alianca_dev/features/home/model/home_model.dart';
import 'package:erp_alianca_dev/shared/models/dashboard_totais_model.dart';

/// Serviço do dashboard.
/// - Resumo legado: GET api/dashboard.php (home).
/// - Dashboard comercial: GET api/dashboard (cards, gráficos, rankings).
/// - Totais de listagem: GET api/dashboard/totais (pedidos e romaneios).
class DashboardService {
  final DioClient _dioClient;

  DashboardService(this._dioClient);

  static const String _pathDashboardLegado = 'api/dashboard.php';
  static const String _pathDashboardComercial = 'api/dashboard';
  static const String _pathDashboardTotais = 'api/dashboard/totais';

  /// Busca resumo do sistema: total_clientes, total_produtos, total_pedidos_concluidos.
  Future<DashboardResumoModel> buscarResumo() async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      _pathDashboardLegado,
    );

    final data = response.data;
    if (data == null || !ApiResponseParser.isSuccess(data)) {
      return const DashboardResumoModel(
        idEmpresa: 0,
        totalClientes: 0,
        totalProdutos: 0,
        totalPedidosConcluidos: 0,
      );
    }

    return DashboardResumoModel.fromJson(data);
  }

  /// Dashboard comercial com filtros de período e agrupamento.
  Future<DashboardComercialModel> buscarComercial(
    DashboardComercialFiltros filtros,
  ) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      _pathDashboardComercial,
      queryParameters: filtros.toQueryParameters(),
    );

    final data = response.data;
    if (data == null || !ApiResponseParser.isSuccess(data)) {
      return DashboardComercialModel.vazio;
    }

    return DashboardComercialModel.fromJson(data);
  }

  /// Totais agregados para listagens (pedidos e romaneios), sem paginação.
  Future<DashboardTotaisModel> buscarTotais(
    DashboardTotaisFiltros filtros,
  ) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      _pathDashboardTotais,
      queryParameters: filtros.toQueryParameters(),
    );

    final data = response.data;
    if (data == null || !ApiResponseParser.isSuccess(data)) {
      return DashboardTotaisModel.vazio;
    }

    return DashboardTotaisModel.fromJson(data);
  }
}
