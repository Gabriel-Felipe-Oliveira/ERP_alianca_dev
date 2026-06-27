import 'package:flutter_test/flutter_test.dart';
import 'package:erp_alianca_dev/shared/services/produto_service.dart';
import '../../helpers/mock_dio_client.dart';

void main() {
  group('ProdutoService', () {
    test('listar parseia lista direta', () async {
      final dio = createTestDioClient([
        {
          'id_produto': 1,
          'id_empresa': 1,
          'nome': 'Produto A',
          'preco': 10.5,
          'estoque_atual': 5,
          'status': 'ativo',
        },
      ]);
      final service = ProdutoService(dio);
      final lista = await service.listar();
      expect(lista, hasLength(1));
      expect(lista.first.nome, 'Produto A');
      expect(lista.first.preco, 10.5);
    });

    test('listarPaginado retorna página', () async {
      final dio = createTestDioClient({
        'ok': true,
        'data': [
          {
            'id_produto': 2,
            'id_empresa': 1,
            'nome': 'Produto B',
            'preco': 20,
            'estoque_atual': 0,
            'status': 'ativo',
          },
        ],
      });
      final service = ProdutoService(dio);
      final page = await service.listarPaginado(page: 1);
      expect(page.items.first.nome, 'Produto B');
    });
  });
}
