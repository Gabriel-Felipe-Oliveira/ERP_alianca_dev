import 'package:erp_alianca_dev/core/network/api_response.dart';
import 'package:erp_alianca_dev/core/network/dio_client.dart';
import 'package:erp_alianca_dev/features/home/model/home_model.dart';

/// Serviço do dashboard. Resumo (contadores) via GET api/dashboard.php.
/// [id_empresa] é injetado pelo Dio nas queries.
class DashboardService {
  final DioClient _dioClient;

  DashboardService(this._dioClient);

  static const String _pathDashboard = 'api/dashboard.php';

  /// Busca resumo do sistema: total_clientes, total_produtos, total_pedidos_concluidos.
  Future<DashboardResumoModel> buscarResumo() async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      _pathDashboard,
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
}
