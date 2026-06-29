import 'package:flutter_test/flutter_test.dart';
import 'package:erp_alianca_dev/core/errors/app_exception.dart';
import 'package:erp_alianca_dev/core/network/dio_client.dart';
import 'package:erp_alianca_dev/features/romaneio/model/romaneio_model.dart';
import 'package:erp_alianca_dev/features/romaneio/viewmodel/romaneio_viewmodel.dart';
import 'package:erp_alianca_dev/shared/models/base_state.dart';
import 'package:erp_alianca_dev/shared/models/paginated_result.dart';
import 'package:erp_alianca_dev/shared/services/empresa_service.dart';
import 'package:erp_alianca_dev/shared/services/romaneio_service.dart';

import '../../../helpers/mock_dio_client.dart';

DioClient _bareClient() =>
    DioClient(EmpresaService(), createTestAuthService(EmpresaService()));

class FakeRomaneioService extends RomaneioService {
  FakeRomaneioService() : super(_bareClient());

  PaginatedResult<RomaneioModel>? resultado;
  AppException? erroAoListar;
  int listarCalls = 0;

  @override
  Future<PaginatedResult<RomaneioModel>> listarRomaneiosPaginado({
    required int page,
    int limit = 20,
    String? status,
    bool includeDeleted = false,
  }) async {
    listarCalls++;
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

    setUp(() {
      service = FakeRomaneioService();
    });

    test('loadRomaneios com filtro específico popula a lista', () async {
      service.resultado = _page([
        _romaneio(id: 1, status: RomaneioStatus.concluido, totalFaturado: 300),
      ]);

      final vm = RomaneioViewModel(service)..setStatusFiltro('concluido');
      await vm.loadRomaneios();

      expect(vm.state, ViewState.success);
      expect(vm.romaneios, hasLength(1));
      expect(service.listarCalls, 1);
    });

    test('filtro "Em aberto" exclui concluídos e cancelados', () async {
      service.resultado = _page([
        _romaneio(id: 1, status: RomaneioStatus.rascunho),
        _romaneio(id: 2, status: RomaneioStatus.emRota),
        _romaneio(id: 3, status: RomaneioStatus.concluido),
        _romaneio(id: 4, status: RomaneioStatus.cancelado),
      ]);

      final vm = RomaneioViewModel(service);
      await vm.loadRomaneios();

      expect(vm.romaneios, hasLength(2));
      expect(
        vm.romaneios.map((r) => r.status),
        containsAll([RomaneioStatus.rascunho, RomaneioStatus.emRota]),
      );
    });

    test('totalFaturadoListagem soma o faturamento dos romaneios', () async {
      service.resultado = _page([
        _romaneio(id: 1, status: RomaneioStatus.rascunho, totalFaturado: 120.5),
        _romaneio(id: 2, status: RomaneioStatus.emRota, totalFaturado: 80.0),
      ]);

      final vm = RomaneioViewModel(service);
      await vm.loadRomaneios();

      expect(vm.totalFaturadoListagem, 200.5);
    });

    test('setStatusFiltro e setIncludeDeleted notificam e ignoram repetido', () {
      final vm = RomaneioViewModel(service);
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

      final vm = RomaneioViewModel(service);
      await vm.loadRomaneios();

      expect(vm.state, ViewState.error);
      expect(vm.errorMessage, isNotEmpty);
      expect(vm.romaneios, isEmpty);
    });
  });
}
