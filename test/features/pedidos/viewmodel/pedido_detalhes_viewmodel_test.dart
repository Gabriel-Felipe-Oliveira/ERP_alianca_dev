import 'package:flutter_test/flutter_test.dart';
import 'package:erp_alianca_dev/features/clientes/model/cliente_model.dart';
import 'package:erp_alianca_dev/core/errors/app_exception.dart';
import 'package:erp_alianca_dev/core/network/dio_client.dart';
import 'package:erp_alianca_dev/features/pedidos/model/pedido_model.dart';
import 'package:erp_alianca_dev/features/pedidos/viewmodel/pedido_detalhes_viewmodel.dart';
import 'package:erp_alianca_dev/features/produtos/model/produto_model.dart';
import 'package:erp_alianca_dev/shared/models/base_state.dart';
import 'package:erp_alianca_dev/shared/services/cliente_service.dart';
import 'package:erp_alianca_dev/shared/services/cupom_service.dart';
import 'package:erp_alianca_dev/shared/services/empresa_service.dart';
import 'package:erp_alianca_dev/shared/services/pdf_export_service.dart';
import 'package:erp_alianca_dev/shared/services/pedido_service.dart';
import 'package:erp_alianca_dev/shared/services/produto_service.dart';

import '../../../helpers/mock_dio_client.dart';

DioClient _bareClient() =>
    DioClient(EmpresaService(), createTestAuthService(EmpresaService()));

const _pedidoRascunho = PedidoListagemModel(
  idPedido: 42,
  idEmpresa: 3,
  idCliente: 10,
  status: 'rascunho',
  total: 150,
  pagamento: 'Pix',
);

class FakePedidoService extends PedidoService {
  FakePedidoService() : super(_bareClient());

  List<PedidoItemModel> itens = const [
    PedidoItemModel(
      idItem: 1,
      idPedido: 42,
      idEmpresa: 3,
      idProduto: 5,
      quantidade: 2,
      precoUnitario: 75,
      subtotal: 150,
    ),
  ];
  AppException? erroItens;
  int alterarStatusCalls = 0;
  String? ultimoStatus;

  @override
  Future<List<PedidoItemModel>> listarItensPedido(int idPedido) async {
    if (erroItens != null) throw erroItens!;
    return itens;
  }

  @override
  Future<List<PedidoListagemModel>> listarPedidosPorIds(
    List<int> ids,
  ) async {
    return [_pedidoRascunho];
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
    ultimoStatus = status;
  }
}

class FakeProdutoService extends ProdutoService {
  FakeProdutoService() : super(_bareClient());

  @override
  Future<ProdutoModel?> buscarPorId(int id) async {
    return ProdutoModel(
      idProduto: id,
      idEmpresa: 3,
      nome: 'Produto $id',
      preco: 75,
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
      nome: 'Cliente $id',
      telefone: '31999999999',
      email: 'c@test.com',
      cep: '32600000',
      logradouro: 'Rua A',
      numero: '1',
      bairro: 'Centro',
      cidade: 'Betim',
      estado: 'MG',
    );
  }
}

PedidoDetalhesViewModel _buildVm(FakePedidoService pedidoService) {
  return PedidoDetalhesViewModel(
    pedidoService,
    FakeProdutoService(),
    EmpresaService(),
    CupomService(),
    FakeClienteService(),
    PdfExportService(),
    idPedido: 42,
    pedido: _pedidoRascunho,
    nomeCliente: 'Cliente Teste',
  );
}

void main() {
  group('PedidoDetalhesViewModel', () {
    late FakePedidoService pedidoService;

    setUp(() {
      pedidoService = FakePedidoService();
    });

    test('expõe dados do pedido inicial', () {
      final vm = _buildVm(pedidoService);

      expect(vm.pedido?.idPedido, 42);
      expect(vm.pagamentoExibicao, 'Pix');
      expect(vm.nomeCliente, 'Cliente Teste');
      expect(vm.statusAtual, 'rascunho');

      vm.dispose();
    });

    test('loadItens popula itens e total', () async {
      final vm = _buildVm(pedidoService);

      await vm.loadItens();

      expect(vm.state, ViewState.success);
      expect(vm.itens, hasLength(1));
      expect(vm.totalPedido, 150);

      vm.dispose();
    });

    test('confirmarPedido altera status para confirmado', () async {
      final vm = _buildVm(pedidoService);

      final result = await vm.confirmarPedido();

      expect(result, isTrue);
      expect(pedidoService.alterarStatusCalls, 1);
      expect(pedidoService.ultimoStatus, 'confirmado');
      expect(vm.statusAtual, 'confirmado');

      vm.dispose();
    });

    test('confirmarPedido retorna false se já confirmado', () async {
      final vm = PedidoDetalhesViewModel(
        pedidoService,
        FakeProdutoService(),
        EmpresaService(),
        CupomService(),
        FakeClienteService(),
        PdfExportService(),
        idPedido: 42,
        pedido: _pedidoRascunho.copyWith(status: 'confirmado'),
        nomeCliente: 'Cliente Teste',
      );

      final result = await vm.confirmarPedido();

      expect(result, isFalse);
      expect(pedidoService.alterarStatusCalls, 0);

      vm.dispose();
    });

    test('cancelarPedido altera status para cancelado', () async {
      final vm = _buildVm(pedidoService);

      final result = await vm.cancelarPedido();

      expect(result, isTrue);
      expect(pedidoService.ultimoStatus, 'cancelado');
      expect(vm.pedido?.status, 'cancelado');

      vm.dispose();
    });

    test('loadItens define erro quando service falha', () async {
      pedidoService.erroItens = const AppException(message: 'Pedido não encontrado');
      final vm = _buildVm(pedidoService);

      await vm.loadItens();

      expect(vm.state, ViewState.error);
      expect(vm.errorMessage, isNotEmpty);

      vm.dispose();
    });
  });
}

extension on PedidoListagemModel {
  PedidoListagemModel copyWith({String? status}) {
    return PedidoListagemModel(
      idPedido: idPedido,
      idEmpresa: idEmpresa,
      idCliente: idCliente,
      status: status ?? this.status,
      total: total,
      volume: volume,
      createdAt: createdAt,
      pagamento: pagamento,
    );
  }
}
