@Tags(['integration'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:erp_alianca_dev/shared/services/cliente_service.dart';
import 'package:erp_alianca_dev/shared/services/pedido_service.dart';
import 'package:erp_alianca_dev/shared/services/produto_service.dart';
import 'package:erp_alianca_dev/shared/services/romaneio_service.dart';

import 'helpers/integration_test_context.dart';

/// Testes de integração dos fluxos de negócio (listagens autenticadas).
void main() {
  late IntegrationTestContext ctx;

  setUp(() async {
    ctx = IntegrationTestContext();
    await ctx.setUp();
    await ctx.login();
  });

  tearDown(() async {
    await ctx.tearDown();
  });

  group('API de negócio (integração)', () {
    test('listar clientes paginado retorna envelope válido', () async {
      final service = ClienteService(ctx.dioClient);
      final page = await service.listarClientesPaginado(page: 1, limit: 5);

      expect(page.page, 1);
      expect(page.limit, 5);
      expect(page.total, greaterThanOrEqualTo(0));
      expect(page.items, isA<List<dynamic>>());
    });

    test('listar produtos paginado retorna envelope válido', () async {
      final service = ProdutoService(ctx.dioClient);
      final page = await service.listarPaginado(page: 1, limit: 5);

      expect(page.page, 1);
      expect(page.limit, 5);
      expect(page.total, greaterThanOrEqualTo(0));
      expect(page.items, isA<List<dynamic>>());
    });

    test('listar pedidos paginado retorna envelope válido', () async {
      final service = PedidoService(ctx.dioClient);
      final page = await service.listarPedidosPaginado(
        page: 1,
        limit: 5,
        status: 'confirmado',
      );

      expect(page.page, 1);
      expect(page.limit, 5);
      expect(page.total, greaterThanOrEqualTo(0));
      expect(page.items, isA<List<dynamic>>());
    });

    test('listar romaneios paginado retorna envelope válido', () async {
      final service = RomaneioService(ctx.dioClient);
      final page = await service.listarRomaneiosPaginado(page: 1, limit: 5);

      expect(page.page, 1);
      expect(page.limit, 5);
      expect(page.total, greaterThanOrEqualTo(0));
      expect(page.items, isA<List<dynamic>>());
    });

    test('listar pedidos por status organizado retorna lista parseada', () async {
      final service = PedidoService(ctx.dioClient);
      final pedidos = await service.listarPedidos(status: 'organizado');

      expect(pedidos, isA<List<dynamic>>());
    });
  });
}
