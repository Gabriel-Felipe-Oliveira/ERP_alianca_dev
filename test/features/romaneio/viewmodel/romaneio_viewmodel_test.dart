import 'package:flutter_test/flutter_test.dart';
import 'package:erp_alianca_dev/core/errors/app_exception.dart';
import 'package:erp_alianca_dev/core/network/dio_client.dart';
import 'package:erp_alianca_dev/features/romaneio/model/romaneio_model.dart';
import 'package:erp_alianca_dev/features/romaneio/viewmodel/romaneio_viewmodel.dart';
import 'package:erp_alianca_dev/shared/models/dashboard_totais_model.dart';
import 'package:erp_alianca_dev/shared/models/base_state.dart';
import 'package:erp_alianca_dev/shared/models/paginated_result.dart';
import 'package:erp_alianca_dev/shared/services/empresa_service.dart';
import 'package:erp_alianca_dev/shared/services/romaneio_service.dart';

import '../../../helpers/fake_services.dart';
import '../../../helpers/mock_dio_client.dart';

DioClient _bareClient() =>
    DioClient(EmpresaService(), createTestAuthService(EmpresaService()));

class FakeRomaneioService extends RomaneioService {
  FakeRomaneioService() : super(_bareClient());

  PaginatedResult<RomaneioModel>? resultado;
  AppException? erroAoListar;
  int listarCalls = 0;
  String? ultimoStatus;

  @override
  Future<PaginatedResult<RomaneioModel>> listarRomaneiosPaginado({
    required int page,
    int limit = 20,
    String? status,
    bool includeDeleted = false,
  }) async {
    listarCalls++;
    ultimoStatus = status;
    if (erroAoListar != null) throw erroAoListar!;
    return resultado ??
        PaginatedResult(
          items: const [],
          page: page,
          limit: limit,
          total: 0,
          hasMore: false,
        );
  }
}

RomaneioModel _romaneio({
  required int id,
  required RomaneioStatus status,
  double totalFaturado = 0,
}) {
  return RomaneioModel(
    id: id,
    numero: 'ROM-${id.toString().padLeft(5, '0')}',
    dataCriacao: DateTime(2026, 1, 1),
    status: status,
    tipoMotorista: TipoMotorista.proprio,
    observacao: '',
    listaPedidos: const [],
    valorTotal: 0,
    quantidadePedidos: 0,
    totalFaturado: totalFaturado,
  );
}

PaginatedResult<RomaneioModel> _page(List<RomaneioModel> items) {
  return PaginatedResult(
    items: items,
    page: 1,
    limit: 20,
    total: items.length,
    hasMore: false,
  );
}

void main() {
  group('RomaneioViewModel', () {
    late FakeRomaneioService service;
    late FakeDashboardService dashboardService;

    setUp(() {
      service = FakeRomaneioService();
      dashboardService = FakeDashboardService();
    });

    RomaneioViewModel buildVm() =>
        RomaneioViewModel(service, dashboardService);

    test('loadRomaneios com filtro específico popula a lista', () async {
      service.resultado = _page([
        _romaneio(id: 1, status: RomaneioStatus.concluido, totalFaturado: 300),
      ]);

      final vm = buildVm()..setStatusFiltro('concluido');
      await vm.loadRomaneios();

      expect(vm.state, ViewState.success);
      expect(vm.romaneios, hasLength(1));
      expect(service.listarCalls, 1);
    });

    test('filtro "Em rota" consulta API com status em_rota', () async {
      service.resultado = _page([
        _romaneio(id: 1, status: RomaneioStatus.emRota),
      ]);

      final vm = buildVm();
      await vm.loadRomaneios();

      expect(vm.romaneios, hasLength(1));
      expect(vm.statusFiltro, 'em_rota');
      expect(service.ultimoStatus, 'em_rota');
      expect(service.listarCalls, 1);
    });

    test('totalFaturadoListagem usa totais da API e não soma itens carregados',
        () async {
      service.resultado = _page([
        _romaneio(id: 1, status: RomaneioStatus.emRota, totalFaturado: 120.5),
        _romaneio(id: 2, status: RomaneioStatus.emRota, totalFaturado: 80.0),
      ]);
      dashboardService.totaisResultado = const DashboardTotaisModel(
        pedidos: DashboardTotaisPedidos.vazio,
        romaneios: DashboardTotaisRomaneios(
          resumo: DashboardTotaisResumo(
            quantidade: 25,
            valorTotal: 39000.9,
          ),
        ),
      );

      final vm = buildVm();
      await vm.loadRomaneios();

      expect(vm.totalFaturadoListagem, 39000.9);
      expect(dashboardService.buscarTotaisCalls, 1);
      expect(dashboardService.ultimosFiltrosTotais?.status, 'em_rota');
    });

    test('setStatusFiltro e setIncludeDeleted notificam e ignoram repetido', () {
      final vm = buildVm();
      var notificacoes = 0;
      vm.addListener(() => notificacoes++);

      vm.setStatusFiltro('cancelado');
      vm.setStatusFiltro('cancelado');
      vm.setIncludeDeleted(true);
      vm.setIncludeDeleted(true);

      expect(vm.statusFiltro, 'cancelado');
      expect(vm.includeDeleted, isTrue);
      expect(notificacoes, 2);
    });

    test('loadRomaneios define estado de erro quando service falha', () async {
      service.erroAoListar = const AppException(message: 'Falha de rede');

      final vm = buildVm();
      await vm.loadRomaneios();

      expect(vm.state, ViewState.error);
      expect(vm.errorMessage, isNotEmpty);
      expect(vm.romaneios, isEmpty);
    });
  });
}
