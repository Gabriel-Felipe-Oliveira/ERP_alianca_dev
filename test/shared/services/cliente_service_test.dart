import 'package:flutter_test/flutter_test.dart';
import 'package:erp_alianca_dev/shared/services/cliente_service.dart';
import '../../helpers/mock_dio_client.dart';

void main() {
  group('ClienteService', () {
    test('listarClientes parseia envelope data', () async {
      final dio = createTestDioClient({
        'ok': true,
        'data': [
          {
            'id_cliente': 1,
            'id_empresa': 1,
            'tipo_documento': 'cpf',
            'documento': '12345678901',
            'nome': 'Cliente Teste',
            'telefone': '31999999999',
            'email': 'a@b.com',
            'cep': '32606470',
            'logradouro': 'Rua A',
            'numero': '1',
            'bairro': 'Centro',
            'cidade': 'Betim',
            'estado': 'MG',
            'status': 'ativa',
          },
        ],
      });
      final service = ClienteService(dio);
      final lista = await service.listarClientes(status: 'ativa');
      expect(lista, hasLength(1));
      expect(lista.first.nome, 'Cliente Teste');
    });

    test('listarClientesPaginado retorna metadados', () async {
      final dio = createTestDioClient({
        'ok': true,
        'data': [
          {
            'id_cliente': 2,
            'id_empresa': 1,
            'tipo_documento': 'cpf',
            'documento': '12345678901',
            'nome': 'Paginado',
            'telefone': '31999999999',
            'email': 'a@b.com',
            'cep': '32606470',
            'logradouro': 'Rua A',
            'numero': '1',
            'bairro': 'Centro',
            'cidade': 'Betim',
            'estado': 'MG',
            'status': 'ativa',
          },
        ],
      });
      final service = ClienteService(dio);
      final page = await service.listarClientesPaginado(page: 1, limit: 20);
      expect(page.items, hasLength(1));
      expect(page.page, 1);
    });

    test('listarClientes retorna vazio quando data ausente', () async {
      final dio = createTestDioClient({'ok': true, 'data': []});
      final service = ClienteService(dio);
      final lista = await service.listarClientes();
      expect(lista, isEmpty);
    });
  });
}
