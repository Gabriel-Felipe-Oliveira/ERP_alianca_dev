import 'package:flutter_test/flutter_test.dart';
import 'package:erp_alianca_dev/core/errors/app_exception.dart';
import 'package:erp_alianca_dev/core/network/dio_client.dart';
import 'package:erp_alianca_dev/features/clientes/model/cliente_model.dart';
import 'package:erp_alianca_dev/features/pedidos/model/pedido_model.dart';
import 'package:erp_alianca_dev/features/romaneio/model/romaneio_model.dart';
import 'package:erp_alianca_dev/features/romaneio/viewmodel/romaneio_criar_viewmodel.dart';
import 'package:erp_alianca_dev/shared/services/cliente_service.dart';
import 'package:erp_alianca_dev/shared/services/empresa_service.dart';
import 'package:erp_alianca_dev/shared/services/pedido_service.dart';
import 'package:erp_alianca_dev/shared/services/romaneio_service.dart';

import '../../../helpers/async_test_utils.dart';
import '../../../helpers/mock_dio_client.dart';

DioClient _bareClient() =>
    DioClient(EmpresaService(), createTestAuthService(EmpresaService()));

PedidoListagemModel _pedido({
  required int id,
  required int idCliente,
  double total = 100,
}) {
  return PedidoListagemModel(
    idPedido: id,
    idEmpresa: 3,
    idCliente: idCliente,
    status: 'confirmado',
    total: total,
  );
}

class FakePedidoService extends PedidoService {
  FakePedidoService() : super(_bareClient());

  List<PedidoListagemModel> pedidos = const [];
  AppException? erroAoListar;
  final Map<int, List<PedidoItemModel>> itensPorPedido = {};
  int alterarStatusCalls = 0;

  @override
  Future<List<PedidoListagemModel>> listarPedidos({
    String? status,
    int? idCliente,
  }) async {
    if (erroAoListar != null) throw erroAoListar!;
    return pedidos;
  }

  @override
  Future<List<PedidoItemModel>> listarItensPedido(int idPedido) async {
    return itensPorPedido[idPedido] ?? const [];
  }

  @override
  Future<void> alterarStatusPedido(
    int idPedido,
    int idEmpresa,
    String status, {
    String? pagamento,
    bool allowEmptyResponseOnSuccess = false,
  }) async {
    alterarStatusCalls++;
  }
}

class FakeRomaneioService extends RomaneioService {
  FakeRomaneioService() : super(_bareClient());

  AppException? erroAoCriar;
  int criarCalls = 0;
  RomaneioCriarResult? resultado =
      const RomaneioCriarResult(idRomaneio: 1, qtdPedidos: 1);

  @override
  Future<RomaneioCriarResult> criarRomaneio({
    required int idEmpresa,
    required String motoristaEntregador,
    required List<int> pedidos,
    required double totalFaturado,
    String? placaVeiculo,
    bool allowEmptyResponseOnSuccess = false,
  }) async {
    criarCalls++;
    if (erroAoCriar != null) throw erroAoCriar!;
    return resultado!;
  }
}

class FakeClienteService extends ClienteService {
  FakeClienteService() : super(_bareClient());

  @override
  Future<List<ClienteModel>> listarClientes({
    String? status,
    String? q,
    bool includeDeleted = false,
  }) async {
    return const [
      ClienteModel(
        id: 10,
        nome: 'Cliente A',
        telefone: '1',
        email: 'a@a.com',
        cep: '1',
        logradouro: 'R',
        numero: '1',
        bairro: 'B',
        cidade: 'C',
        estado: 'MG',
      ),
    ];
  }
}

void main() {
  group('RomaneioCriarViewModel', () {
    late FakePedidoService pedidoService;
    late FakeRomaneioService romaneioService;
    late EmpresaService empresaService;

    setUp(() {
      pedidoService = FakePedidoService();
      romaneioService = FakeRomaneioService();
      empresaService = EmpresaService();
      pedidoService.pedidos = [
        _pedido(id: 1, idCliente: 10, total: 120),
        _pedido(id: 2, idCliente: 10, total: 80),
      ];
      pedidoService.itensPorPedido[1] = [
        const PedidoItemModel(
          idItem: 1,
          idPedido: 1,
          idEmpresa: 3,
          idProduto: 5,
          quantidade: 4,
          precoUnitario: 30,
          subtotal: 120,
        ),
      ];
    });

    RomaneioCriarViewModel buildVm() => RomaneioCriarViewModel(
          pedidoService,
          romaneioService,
          empresaService,
          FakeClienteService(),
        );

    test('carregarPedidosDisponiveis popula lista e nomes de clientes', () async {
      final vm = buildVm();
      await waitUntil(() => !vm.isLoadingPedidos);

      expect(vm.pedidosDisponiveis, hasLength(2));
      expect(vm.nomeCliente(10), 'Cliente A');

      vm.dispose();
    });

    test('togglePedido atualiza totais e volume', () async {
      final vm = buildVm();
      await waitUntil(() => !vm.isLoadingPedidos);

      vm.togglePedido(vm.pedidosDisponiveis.first);
      await waitUntil(() => vm.volumeTotal > 0);

      expect(vm.quantidadePedidos, 1);
      expect(vm.valorTotal, 120);
      expect(vm.volumeTotal, 4);

      vm.dispose();
    });

    test('pedidosFiltrados respeita busca por id', () async {
      final vm = buildVm();
      await waitUntil(() => !vm.isLoadingPedidos);

      vm.setSearchQuery('80');

      expect(vm.pedidosFiltrados, hasLength(1));
      expect(vm.pedidosFiltrados.first.idPedido, 2);

      vm.dispose();
    });

    test('setTipoMotorista proprio exige nome para podeCriar', () async {
      final vm = buildVm();
      await waitUntil(() => !vm.isLoadingPedidos);
      vm.togglePedido(vm.pedidosDisponiveis.first);

      vm.setTipoMotorista(TipoMotorista.proprio);
      expect(vm.podeCriar, isFalse);
      expect(vm.camposFaltantes, contains('Nome do motorista'));

      vm.nomeMotoristaController.text = 'João';
      expect(vm.podeCriar, isTrue);

      vm.dispose();
    });

    test('validarDadosMotorista rejeita placa inválida', () async {
      final vm = buildVm();
      vm.setTipoMotorista(TipoMotorista.proprio);
      vm.nomeMotoristaController.text = 'João';
      vm.placaVeiculoController.text = 'XXX';

      expect(vm.validarDadosMotorista(), isNotNull);
      expect(vm.podeCriar, isFalse);

      vm.dispose();
    });

    test('criarRomaneio persiste e organiza pedidos selecionados', () async {
      final vm = buildVm();
      await waitUntil(() => !vm.isLoadingPedidos);
      vm.togglePedido(vm.pedidosDisponiveis.first);

      final ok = await vm.criarRomaneio();

      expect(ok, isTrue);
      expect(romaneioService.criarCalls, 1);
      expect(pedidoService.alterarStatusCalls, 1);

      vm.dispose();
    });

    test('criarRomaneio falha sem pedidos selecionados', () async {
      final vm = buildVm();
      await waitUntil(() => !vm.isLoadingPedidos);

      final ok = await vm.criarRomaneio();

      expect(ok, isFalse);
      expect(vm.errorMessage, isNotNull);
      expect(romaneioService.criarCalls, 0);

      vm.dispose();
    });

    test('carregarPedidosDisponiveis define erro quando listagem falha', () async {
      pedidoService.erroAoListar =
          const AppException(message: 'Falha de rede');
      final vm = buildVm();
      await waitUntil(() => !vm.isLoadingPedidos);

      expect(vm.errorMessage, isNotNull);
      expect(vm.pedidosDisponiveis, isEmpty);

      vm.dispose();
    });
  });
}
