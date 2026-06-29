import 'package:flutter_test/flutter_test.dart';
import 'package:erp_alianca_dev/core/errors/app_exception.dart';
import 'package:erp_alianca_dev/core/network/dio_client.dart';
import 'package:erp_alianca_dev/features/clientes/model/cliente_model.dart';
import 'package:erp_alianca_dev/features/pedidos/model/item_pedido_linha.dart';
import 'package:erp_alianca_dev/features/pedidos/model/pedido_model.dart';
import 'package:erp_alianca_dev/features/pedidos/viewmodel/pedido_criar_viewmodel.dart';
import 'package:erp_alianca_dev/features/produtos/model/produto_model.dart';
import 'package:erp_alianca_dev/shared/services/cliente_service.dart';
import 'package:erp_alianca_dev/shared/services/empresa_service.dart';
import 'package:erp_alianca_dev/shared/services/pedido_service.dart';
import 'package:erp_alianca_dev/shared/services/produto_service.dart';

import '../../../helpers/mock_dio_client.dart';

DioClient _bareClient() =>
    DioClient(EmpresaService(), createTestAuthService(EmpresaService()));

const _clienteTeste = ClienteModel(
  id: 10,
  nome: 'Padaria Central',
  telefone: '31999999999',
  email: 'padaria@test.com',
  cep: '32600000',
  logradouro: 'Rua A',
  numero: '1',
  bairro: 'Centro',
  cidade: 'Betim',
  estado: 'MG',
);

ProdutoModel _produto({int id = 5, double preco = 12.5}) {
  return ProdutoModel(
    idProduto: id,
    idEmpresa: 3,
    nome: 'Produto $id',
    preco: preco,
    estoqueAtual: 50,
    status: 'ativo',
  );
}

class FakePedidoService extends PedidoService {
  FakePedidoService() : super(_bareClient());

  AppException? erroAoCriar;
  int criarCalls = 0;
  int adicionarCalls = 0;
  int alterarStatusCalls = 0;
  int idPedidoRetorno = 99;
  String? ultimoStatusConfirmado;

  @override
  Future<int> criarPedido(
    PedidoCriarPayload payload, {
    bool allowEmptyResponseOnSuccess = false,
  }) async {
    criarCalls++;
    if (erroAoCriar != null) throw erroAoCriar!;
    return idPedidoRetorno;
  }

  @override
  Future<void> adicionarItem(
    PedidoItemPayload payload, {
    bool allowEmptyResponseOnSuccess = false,
  }) async {
    adicionarCalls++;
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
    ultimoStatusConfirmado = status;
  }
}

class FakeClienteService extends ClienteService {
  FakeClienteService() : super(_bareClient());
}

class FakeProdutoService extends ProdutoService {
  FakeProdutoService() : super(_bareClient());
}

void main() {
  group('PedidoCriarViewModel', () {
    late FakePedidoService pedidoService;
    late EmpresaService empresaService;

    setUp(() {
      pedidoService = FakePedidoService();
      empresaService = EmpresaService();
    });

    PedidoCriarViewModel buildVm() => PedidoCriarViewModel(
          FakeClienteService(),
          FakeProdutoService(),
          pedidoService,
          empresaService,
        );

    test('podeCriar exige cliente, itens e forma de pagamento', () {
      final vm = buildVm();

      expect(vm.podeCriar, isFalse);
      expect(vm.camposFaltantes, containsAll(['Cliente', 'Adicione ao menos um produto', 'Forma de Pagamento']));

      vm.selecionarCliente(_clienteTeste);
      expect(vm.podeCriar, isFalse);

      vm.adicionarItem(_produto(), 2);
      expect(vm.podeCriar, isFalse);

      vm.formaPagamentoSelecionada = 'pix';
      expect(vm.podeCriar, isTrue);
      expect(vm.camposFaltantes, isEmpty);

      vm.dispose();
    });

    test('totalPedido soma quantidade x preço dos itens', () {
      final vm = buildVm();
      vm.adicionarItem(_produto(preco: 10), 2);
      vm.adicionarItem(_produto(id: 6, preco: 5), 1);

      expect(vm.totalPedido, 25);

      vm.dispose();
    });

    test('salvar cria pedido, adiciona itens e confirma status', () async {
      final vm = buildVm();
      vm.selecionarCliente(_clienteTeste);
      vm.formaPagamentoSelecionada = 'dinheiro';
      vm.adicionarItem(_produto(), 3);

      final ok = await vm.salvar();

      expect(ok, isTrue);
      expect(pedidoService.criarCalls, 1);
      expect(pedidoService.adicionarCalls, 1);
      expect(pedidoService.alterarStatusCalls, 1);
      expect(pedidoService.ultimoStatusConfirmado, 'confirmado');
      expect(vm.isLoading, isFalse);

      vm.dispose();
    });

    test('salvar retorna false sem dados mínimos', () async {
      final vm = buildVm();

      final ok = await vm.salvar();

      expect(ok, isFalse);
      expect(vm.errorMessage, isNotNull);
      expect(pedidoService.criarCalls, 0);

      vm.dispose();
    });

    test('salvar expõe erro amigável quando service falha', () async {
      pedidoService.erroAoCriar =
          const AppException(message: 'Estoque insuficiente');
      final vm = buildVm();
      vm.selecionarCliente(_clienteTeste);
      vm.formaPagamentoSelecionada = 'pix';
      vm.adicionarItem(_produto(), 1);

      final ok = await vm.salvar();

      expect(ok, isFalse);
      expect(vm.errorMessage, 'Estoque insuficiente');

      vm.dispose();
    });

    test('adicionarItens soma quantidade quando produto já existe', () async {
      final vm = buildVm();
      vm.adicionarItem(_produto(), 2);
      await vm.adicionarItens([
        ItemPedidoLinha(produto: _produto(), quantidade: 3),
      ]);

      expect(vm.itens, hasLength(1));
      expect(vm.itens.first.quantidade, 5);

      vm.dispose();
    });
  });
}
