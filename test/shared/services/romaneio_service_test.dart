import 'package:flutter_test/flutter_test.dart';
import 'package:erp_alianca_dev/shared/services/romaneio_service.dart';
import '../../helpers/mock_dio_client.dart';

void main() {
  group('RomaneioService', () {
    test('listarRomaneiosPaginado parseia envelope', () async {
      final dio = createTestDioClient({
        'ok': true,
        'data': [
          {
            'id_romaneio': 1,
            'id_empresa': 1,
            'numero': 'ROM-00001',
            'status': 'rascunho',
            'total_faturado': 500.0,
            'data_criacao': '2026-06-18 10:00:00',
          },
        ],
      });
      final service = RomaneioService(dio);
      final page = await service.listarRomaneiosPaginado(page: 1);
      expect(page.items, hasLength(1));
      expect(page.items.first.totalFaturado, 500.0);
    });
  });
}
