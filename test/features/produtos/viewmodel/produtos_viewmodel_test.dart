import 'package:flutter_test/flutter_test.dart';
import 'package:erp_alianca_dev/core/errors/app_exception.dart';
import 'package:erp_alianca_dev/features/produtos/model/produto_model.dart';
import 'package:erp_alianca_dev/features/produtos/viewmodel/produtos_viewmodel.dart';
import 'package:erp_alianca_dev/shared/models/base_state.dart';
import 'package:erp_alianca_dev/shared/models/paginated_result.dart';

import '../../../helpers/fake_services.dart';

ProdutoModel _produto({required int id, String nome = 'Produto'}) {
  return ProdutoModel(
    idProduto: id,
    idEmpresa: 3,
    nome: nome,
    preco: 10,
    estoqueAtual: 5,
    status: 'ativo',
  );
}

void main() {
  group('ProdutosViewModel', () {
    late FakeProdutoService service;

    setUp(() {
      service = FakeProdutoService();
    });

    test('loadProdutos preenche lista da primeira página', () async {
      service.resultado = PaginatedResult(
        items: [_produto(id: 1, nome: 'Arroz')],
        page: 1,
        limit: 20,
        total: 1,
        hasMore: false,
      );
      final vm = ProdutosViewModel(service);

      await vm.loadProdutos();

      expect(vm.state, ViewState.success);
      expect(vm.produtosTodos, hasLength(1));
      expect(vm.produtosTodos.first.nome, 'Arroz');
    });

    test('loadProdutos define estado de erro quando service falha', () async {
      service.erroAoListar =
          const AppException(message: 'Falha ao carregar produtos');
      final vm = ProdutosViewModel(service);

      await vm.loadProdutos();

      expect(vm.state, ViewState.error);
      expect(vm.errorMessage, 'Falha ao carregar produtos');
    });

    test('buscarPorNome envia query ao service', () async {
      service.resultado = PaginatedResult(
        items: [_produto(id: 2, nome: 'Feijão')],
        page: 1,
        limit: 20,
        total: 1,
        hasMore: false,
      );
      final vm = ProdutosViewModel(service);
      vm.query = 'feij';

      await vm.buscarPorNome();

      expect(vm.stateBusca, ViewState.success);
      expect(vm.hasSearched, isTrue);
      expect(service.ultimaQuery, 'feij');
      expect(vm.produtosBusca.first.nome, 'Feijão');
    });

    test('resetBusca limpa estado de busca', () async {
      final vm = ProdutosViewModel(service);
      vm.query = 'teste';
      await vm.buscarPorNome();

      vm.resetBusca(notify: false);

      expect(vm.query, isEmpty);
      expect(vm.hasSearched, isFalse);
      expect(vm.produtosBusca, isEmpty);
      expect(vm.stateBusca, ViewState.idle);
    });
  });
}
