import 'package:flutter_test/flutter_test.dart';
import 'package:erp_alianca_dev/core/errors/app_exception.dart';
import 'package:erp_alianca_dev/core/network/dio_client.dart';
import 'package:erp_alianca_dev/features/clientes/model/cliente_model.dart';
import 'package:erp_alianca_dev/features/pedidos/model/pedido_model.dart';
import 'package:erp_alianca_dev/features/produtos/model/produto_model.dart';
import 'package:erp_alianca_dev/features/romaneio/model/romaneio_model.dart';
import 'package:erp_alianca_dev/features/romaneio/viewmodel/romaneio_detalhe_viewmodel.dart';
import 'package:erp_alianca_dev/shared/models/base_state.dart';
import 'package:erp_alianca_dev/shared/services/cliente_service.dart';
import 'package:erp_alianca_dev/shared/services/cupom_service.dart';
import 'package:erp_alianca_dev/shared/services/empresa_service.dart';
import 'package:erp_alianca_dev/shared/services/pdf_export_service.dart';
import 'package:erp_alianca_dev/shared/services/pedido_service.dart';
import 'package:erp_alianca_dev/shared/services/produto_service.dart';
import 'package:erp_alianca_dev/shared/services/romaneio_service.dart';

import '../../../helpers/mock_dio_client.dart';

DioClient _bareClient() =>
    DioClient(EmpresaService(), createTestAuthService(EmpresaService()));

RomaneioModel _romaneio({
  int id = 7,
  RomaneioStatus status = RomaneioStatus.emRota,
  List<int> idPedidos = const [10],
}) {
  return RomaneioModel(
    id: id,
    numero: 'ROM-00007',
    dataCriacao: DateTime(2026, 3, 15),
    status: status,
    tipoMotorista: TipoMotorista.proprio,
    nomeMotorista: 'Carlos',
    placaVeiculo: 'ABC1D23',
    observacao: '',
    listaPedidos: const [],
    idPedidos: idPedidos,
    valorTotal: 150,
    quantidadePedidos: idPedidos.length,
    totalFaturado: 150,
  );
}

PedidoListagemModel _pedido(int id) {
  return PedidoListagemModel(
    idPedido: id,
    idEmpresa: 3,
    idCliente: 5,
    status: 'organizado',
    total: 150,
  );
}

class FakeRomaneioService extends RomaneioService {
  FakeRomaneioService() : super(_bareClient());

  RomaneioModel? romaneio;
  AppException? erroObter;
  int obterCalls = 0;
  int alterarStatusCalls = 0;
  String? ultimoStatus;

  @override
  Future<RomaneioModel?> obterRomaneio(int idRomaneio) async {
    obterCalls++;
    if (erroObter != null) throw erroObter!;
    return romaneio;
  }

  @override
  Future<void> alterarStatusRomaneio({
    required int idEmpresa,
    required int idRomaneio,
    required String status,
    bool allowEmptyResponseOnSuccess = false,
  }) async {
    alterarStatusCalls++;
    ultimoStatus = status;
    if (romaneio != null) {
      romaneio = RomaneioModel(
        id: romaneio!.id,
        numero: romaneio!.numero,
        dataCriacao: romaneio!.dataCriacao,
        status: RomaneioStatus.fromApi(status),
        tipoMotorista: romaneio!.tipoMotorista,
        nomeMotorista: romaneio!.nomeMotorista,
        placaVeiculo: romaneio!.placaVeiculo,
        observacao: romaneio!.observacao,
        listaPedidos: romaneio!.listaPedidos,
        idPedidos: romaneio!.idPedidos,
        valorTotal: romaneio!.valorTotal,
        quantidadePedidos: romaneio!.quantidadePedidos,
        totalFaturado: romaneio!.totalFaturado,
      );
    }
  }
}

class FakePedidoService extends PedidoService {
  FakePedidoService() : super(_bareClient());

  int alterarStatusCalls = 0;

  @override
  Future<List<PedidoListagemModel>> listarPedidosPorIds(
    List<int> ids,
  ) async {
    return ids.map(_pedido).toList();
  }

  @override
  Future<List<PedidoItemModel>> listarItensPedido(int idPedido) async {
    return [
      PedidoItemModel(
        idItem: 1,
        idPedido: idPedido,
        idEmpresa: 3,
        idProduto: 100,
        quantidade: 3,
        precoUnitario: 50,
        subtotal: 150,
      ),
    ];
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

class FakeProdutoService extends ProdutoService {
  FakeProdutoService() : super(_bareClient());

  @override
  Future<ProdutoModel?> buscarPorId(int id) async {
    return ProdutoModel(
      idProduto: id,
      idEmpresa: 3,
      nome: 'Arroz 5kg',
      preco: 50,
      estoqueAtual: 10,
      status: 'ativo',
    );
  }
}

class FakeClienteService extends ClienteService {
  FakeClienteService() : super(_bareClient());

  @override
  Future<ClienteModel> buscarClientePorId(int id) async {
    return ClienteModel(
      id: id,
      nome: 'Mercado Silva',
      telefone: '31999999999',
      email: 'm@test.com',
      cep: '32600000',
      logradouro: 'Rua B',
      numero: '10',
      bairro: 'Centro',
      cidade: 'Betim',
      estado: 'MG',
    );
  }
}

RomaneioDetalheViewModel _buildVm({
  required FakeRomaneioService romaneioService,
  required FakePedidoService pedidoService,
  int idRomaneio = 7,
}) {
  return RomaneioDetalheViewModel(
    romaneioService,
    pedidoService,
    FakeProdutoService(),
    EmpresaService(),
    FakeClienteService(),
    CupomService(),
    PdfExportService(),
    idRomaneio: idRomaneio,
  );
}

void main() {
  group('RomaneioDetalheViewModel', () {
    late FakeRomaneioService romaneioService;
    late FakePedidoService pedidoService;

    setUp(() {
      romaneioService = FakeRomaneioService();
      pedidoService = FakePedidoService();
      romaneioService.romaneio = _romaneio();
    });

    test('loadRomaneio carrega cabeçalho, pedidos e agregações', () async {
      final vm = _buildVm(
        romaneioService: romaneioService,
        pedidoService: pedidoService,
      );

      await vm.loadRomaneio();

      expect(vm.state, ViewState.success);
      expect(vm.romaneio?.id, 7);
      expect(vm.pedidosDoRomaneio, hasLength(1));
      expect(vm.totalVolumes, 3);
      expect(vm.totalFaturado, 150);
      expect(vm.produtosAgregados, hasLength(1));
      expect(vm.produtosAgregados.first.nome, 'Arroz 5kg');
      expect(vm.nomeClienteDoPedido(10), 'Mercado Silva');

      vm.dispose();
    });

    test('loadRomaneio define erro quando romaneio não existe', () async {
      romaneioService.romaneio = null;
      final vm = _buildVm(
        romaneioService: romaneioService,
        pedidoService: pedidoService,
      );

      await vm.loadRomaneio();

      expect(vm.state, ViewState.error);
      expect(vm.errorMessage, 'Romaneio não encontrado.');

      vm.dispose();
    });

    test('helpers de formatação expõem dados legíveis', () {
      final vm = _buildVm(
        romaneioService: romaneioService,
        pedidoService: pedidoService,
      );
      final r = _romaneio();

      expect(vm.textoNumeroRomaneio(r), 'Romaneio ROM-00007');
      expect(vm.placaExibicao(r), 'ABC1D23');
      expect(vm.motoristaExibicao(r), 'Carlos');
      expect(vm.formatarMoeda(150), contains('150'));

      vm.dispose();
    });

    test('cancelarRomaneio altera status via service', () async {
      final vm = _buildVm(
        romaneioService: romaneioService,
        pedidoService: pedidoService,
      );
      await vm.loadRomaneio();

      final ok = await vm.cancelarRomaneio();

      expect(ok, isTrue);
      expect(romaneioService.ultimoStatus, 'cancelado');

      vm.dispose();
    });

    test('faturarMarcarConcluido conclui pedidos e romaneio', () async {
      final vm = _buildVm(
        romaneioService: romaneioService,
        pedidoService: pedidoService,
      );
      await vm.loadRomaneio();

      final ok = await vm.faturarMarcarConcluido();

      expect(ok, isTrue);
      expect(pedidoService.alterarStatusCalls, 1);
      expect(romaneioService.ultimoStatus, 'concluido');

      vm.dispose();
    });

    test('loadRomaneio define erro quando service falha', () async {
      romaneioService.erroObter =
          const AppException(message: 'Romaneio indisponível');
      final vm = _buildVm(
        romaneioService: romaneioService,
        pedidoService: pedidoService,
      );

      await vm.loadRomaneio();

      expect(vm.state, ViewState.error);
      expect(vm.errorMessage, isNotEmpty);

      vm.dispose();
    });
  });
}
