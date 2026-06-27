import 'package:flutter_test/flutter_test.dart';
import 'package:erp_alianca_dev/shared/services/pedido_service.dart';
import '../../helpers/mock_dio_client.dart';

void main() {
  group('PedidoService', () {
    test('listarPedidosPaginado parseia envelope', () async {
      final dio = createTestDioClient({
        'ok': true,
        'data': [
          {
            'id_pedido': 1,
            'id_empresa': 1,
            'id_cliente': 10,
            'status': 'confirmado',
            'total': 150.0,
            'pagamento': 'pix',
          },
        ],
      });
      final service = PedidoService(dio);
      final page = await service.listarPedidosPaginado(
        page: 1,
        status: 'confirmado',
      );
      expect(page.items, hasLength(1));
      expect(page.items.first.total, 150.0);
    });
  });
}
