import 'package:flutter_test/flutter_test.dart';
import '../../../helpers/mock_dio_client.dart';
import 'package:erp_alianca_dev/core/network/dio_client.dart';
import 'package:erp_alianca_dev/features/clientes/model/cliente_model.dart';
import 'package:erp_alianca_dev/features/clientes/viewmodel/clientes_viewmodel.dart';
import 'package:erp_alianca_dev/shared/models/paginated_result.dart';
import 'package:erp_alianca_dev/shared/services/cliente_service.dart';
import 'package:erp_alianca_dev/shared/services/empresa_service.dart';

class FakeClienteService extends ClienteService {
  FakeClienteService()
      : super(DioClient(
          EmpresaService(),
          createTestAuthService(EmpresaService()),
        ));

  PaginatedResult<ClienteModel>? paginatedResult;
  int listarCalls = 0;

  @override
  Future<PaginatedResult<ClienteModel>> listarClientesPaginado({
    required int page,
    int limit = 20,
    String? status,
    String? q,
    bool includeDeleted = false,
  }) async {
    listarCalls++;
    return paginatedResult ??
        PaginatedResult(
          items: const [],
          page: page,
          limit: limit,
          total: 0,
          hasMore: false,
        );
  }
}

void main() {
  group('ClientesViewModel', () {
    late FakeClienteService fake;

    setUp(() {
      fake = FakeClienteService();
    });

    test('loadClientes preenche lista da primeira página', () async {
      fake.paginatedResult = PaginatedResult(
        items: [
          const ClienteModel(
            id: 1,
            nome: 'A',
            telefone: '1',
            email: 'a@a.com',
            cep: '1',
            logradouro: 'R',
            numero: '1',
            bairro: 'B',
            cidade: 'C',
            estado: 'MG',
          ),
        ],
        page: 1,
        limit: 20,
        total: 1,
        hasMore: false,
      );
      final vm = ClientesViewModel(fake);
      await vm.loadClientes();
      expect(vm.clientesTodos, hasLength(1));
      expect(vm.clientesTodos.first.nome, 'A');
      expect(fake.listarCalls, 1);
    });

    test('resetBusca limpa query sem notify quando notify false', () {
      final vm = ClientesViewModel(fake);
      vm.query = 'teste';
      vm.resetBusca(notify: false);
      expect(vm.query, isEmpty);
      expect(vm.hasSearched, isFalse);
    });
  });
}
