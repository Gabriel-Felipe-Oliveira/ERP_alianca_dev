import 'package:flutter_test/flutter_test.dart';
import 'package:erp_alianca_dev/core/network/api_response.dart';

void main() {
  group('ApiResponseParser.isSuccess', () {
    test('retorna true para ok: true', () {
      expect(ApiResponseParser.isSuccess({'ok': true}), isTrue);
    });

    test('retorna true para success: true', () {
      expect(ApiResponseParser.isSuccess({'success': true}), isTrue);
    });

    test('retorna false para ok: false', () {
      expect(ApiResponseParser.isSuccess({'ok': false}), isFalse);
    });

    test('retorna true para lista direta (sem envelope)', () {
      expect(ApiResponseParser.isSuccess([{'id': 1}]), isTrue);
    });
  });

  group('ApiResponseParser.message', () {
    test('extrai message do envelope', () {
      expect(
        ApiResponseParser.message({'message': '  Erro de validação  '}),
        'Erro de validação',
      );
    });

    test('extrai error quando message ausente', () {
      expect(
        ApiResponseParser.message({'error': 'Produto não encontrado'}),
        'Produto não encontrado',
      );
    });
  });

  group('ApiResponseParser.parseList', () {
    test('parseia lista direta', () {
      final list = ApiResponseParser.parseList(
        [
          {'nome': 'A'},
          {'nome': 'B'},
        ],
        (json) => json['nome'] as String,
      );
      expect(list, ['A', 'B']);
    });

    test('parseia envelope data', () {
      final list = ApiResponseParser.parseList(
        {
          'ok': true,
          'data': [
            {'nome': 'X'},
          ],
        },
        (json) => json['nome'] as String,
      );
      expect(list, ['X']);
    });
  });

  group('ApiResponseParser.parseObject', () {
    test('parseia objeto em data', () {
      final obj = ApiResponseParser.parseObject(
        {
          'ok': true,
          'data': {'id_produto': 98, 'nome': 'Produto Teste'},
        },
        (json) => json,
        rootEntityKeys: ['nome', 'id_produto'],
      );
      expect(obj?['nome'], 'Produto Teste');
    });

    test('retorna null quando rootEntityKeys não batem', () {
      final obj = ApiResponseParser.parseObject(
        {'ok': false, 'error': 'não encontrado'},
        (json) => json,
        rootEntityKeys: ['nome'],
      );
      expect(obj, isNull);
    });
  });

  group('ApiResponseParser.requireOk', () {
    test('não lança quando ok: true', () {
      expect(
        () => ApiResponseParser.requireOk(
          {'ok': true},
          defaultMessage: 'Falha',
        ),
        returnsNormally,
      );
    });

    test('lança com message da API', () {
      expect(
        () => ApiResponseParser.requireOk(
          {'ok': false, 'message': 'Estoque insuficiente'},
          defaultMessage: 'Falha genérica',
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Estoque insuficiente'),
          ),
        ),
      );
    });
  });

  group('ApiResponseParser.parsePaginatedList', () {
    test('pagina client-side quando API retorna lista grande', () {
      final raw = List.generate(
        25,
        (i) => {'nome': 'Item $i'},
      );
      final result = ApiResponseParser.parsePaginatedList(
        raw,
        (json) => json['nome'] as String,
        requestedPage: 1,
        requestedLimit: 20,
      );
      expect(result.items.length, 20);
      expect(result.total, 25);
      expect(result.hasMore, isTrue);
      expect(result.fullCache?.length, 25);
    });

    test('lista menor que limit não tem hasMore', () {
      final result = ApiResponseParser.parsePaginatedList(
        [
          {'nome': 'A'},
        ],
        (json) => json['nome'] as String,
        requestedPage: 1,
        requestedLimit: 20,
      );
      expect(result.items.length, 1);
      expect(result.hasMore, isFalse);
      expect(result.fullCache, isNull);
    });
  });
}
