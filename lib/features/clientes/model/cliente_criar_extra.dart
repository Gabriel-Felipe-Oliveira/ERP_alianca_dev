import 'package:erp_alianca_dev/routes/app_routes.dart';
import 'package:erp_alianca_dev/shared/models/cnpj_consulta_model.dart';

/// Parâmetros opcionais ao abrir a tela de criar cliente.
class ClienteCriarExtra {
  const ClienteCriarExtra({
    required this.consultaCnpj,
    this.abrirPedidoAposSalvar = false,
    this.rotaVoltar = AppRoutes.clientes,
  });

  final CnpjConsultaModel consultaCnpj;
  final bool abrirPedidoAposSalvar;
  final String rotaVoltar;
}
