import 'package:flutter_test/flutter_test.dart';
import 'package:erp_alianca_dev/core/errors/app_exception.dart';
import 'package:erp_alianca_dev/features/pedidos/model/pedido_model.dart';
import 'package:erp_alianca_dev/features/pedidos/viewmodel/pedidos_viewmodel.dart';
import 'package:erp_alianca_dev/shared/models/dashboard_totais_model.dart';
import 'package:erp_alianca_dev/shared/models/base_state.dart';
import 'package:erp_alianca_dev/shared/models/paginated_result.dart';

import '../../../helpers/fake_services.dart';

PedidoListagemModel _pedido({
  required int idPedido,
  required int idCliente,
  required double total,
  String status = 'confirmado',
}) {
  return PedidoListagemModel(
    idPedido: idPedido,
    idEmpresa: 1,
    idCliente: idCliente,
    status: status,
    total: total,
  );
}

void main() {
  group('PedidosViewModel', () {
    late FakePedidoService pedidoService;
    late FakeClienteService clienteService;
    late FakeDashboardService dashboardService;

    setUp(() {
      pedidoService = FakePedidoService();
      clienteService = FakeClienteService();
      dashboardService = FakeDashboardService();
    });

    PedidosViewModel buildVm() => PedidosViewModel(
          pedidoService,
          clienteService,
          dashboardService,
        );

    test('loadPedidos popula lista e resolve nomes de clientes', () async {
      clienteService.nomes[10] = 'Padaria Central';
      pedidoService.resultado = PaginatedResult(
        items: [
          _pedido(idPedido: 1, idCliente: 10, total: 150.0),
          _pedido(idPedido: 2, idCliente: 10, total: 50.0),
        ],
        page: 1,
        limit: 20,
        total: 2,
        hasMore: false,
      );

      final vm = buildVm();
      await vm.loadPedidos();

      expect(vm.state, ViewState.success);
      expect(vm.pedidos, hasLength(2));
      expect(vm.nomeCliente(10), 'Padaria Central');
      expect(pedidoService.listarCalls, 1);
    });

    test('totalGeralListagem usa totais da API e não soma itens carregados',
        () async {
      pedidoService.resultado = PaginatedResult(
        items: [
          _pedido(idPedido: 1, idCliente: 1, total: 100.5),
          _pedido(idPedido: 2, idCliente: 2, total: 99.5),
        ],
        page: 1,
        limit: 20,
        total: 2,
        hasMore: false,
      );
      dashboardService.totaisResultado = const DashboardTotaisModel(
        pedidos: DashboardTotaisPedidos(
          resumo: DashboardTotaisResumo(
            quantidade: 152,
            valorTotal: 48750.9,
          ),
        ),
        romaneios: DashboardTotaisRomaneios.vazio,
      );

      final vm = buildVm();
      await vm.loadPedidos();

      expect(vm.totalGeralListagem, 48750.9);
      expect(dashboardService.buscarTotaisCalls, 1);
      expect(dashboardService.ultimosFiltrosTotais?.status, 'confirmado');
    });

    test('setStatusFiltro altera o filtro e dispara notificação', () {
      final vm = buildVm();
      var notificou = false;
      vm.addListener(() => notificou = true);

      vm.setStatusFiltro('cancelado');

      expect(vm.statusFiltro, 'cancelado');
      expect(notificou, isTrue);
    });

    test('setStatusFiltro ignora valor repetido', () {
      final vm = buildVm();
      vm.setStatusFiltro('organizado');
      var notificou = false;
      vm.addListener(() => notificou = true);

      vm.setStatusFiltro('organizado');

      expect(notificou, isFalse);
    });

    test('nomeCliente retorna traço para id não resolvido', () {
      final vm = buildVm();
      expect(vm.nomeCliente(999), '—');
    });

    test('loadPedidos define estado de erro quando service falha', () async {
      pedidoService.erroAoListar =
          const AppException(message: 'Falha de rede');

      final vm = buildVm();
      await vm.loadPedidos();

      expect(vm.state, ViewState.error);
      expect(vm.errorMessage, isNotEmpty);
      expect(vm.pedidos, isEmpty);
    });
  });
}
