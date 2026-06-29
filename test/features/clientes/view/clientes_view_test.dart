import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/core/errors/app_exception.dart';
import 'package:erp_alianca_dev/core/theme/empresa_palettes.dart';
import 'package:erp_alianca_dev/features/clientes/model/cliente_model.dart';
import 'package:erp_alianca_dev/features/clientes/view/clientes_view.dart';
import 'package:erp_alianca_dev/features/clientes/viewmodel/clientes_viewmodel.dart';
import 'package:erp_alianca_dev/shared/models/base_state.dart';
import 'package:erp_alianca_dev/shared/models/paginated_result.dart';
import 'package:erp_alianca_dev/shared/services/empresa_service.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';

import '../../../helpers/fake_services.dart';

Widget _buildApp(ClientesViewModel vm) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        height: 600,
        child: ChangeNotifierProvider<ClientesViewModel>.value(
          value: vm,
          child: const ClientesView(),
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AppColors.setCurrent(EmpresaPalettes.getById(kDefaultIdEmpresa));
  });

  testWidgets('ClientesView exibe campo de busca', (tester) async {
    final vm = ClientesViewModel(FakeClienteService());

    await tester.pumpWidget(_buildApp(vm));
    await tester.pumpAndSettle();

    expect(find.text('Buscar clientes por nome...'), findsOneWidget);
  });

  testWidgets('ClientesView exibe erro quando listagem falha', (tester) async {
    final service = FakeClienteService();
    service.erroAoListar =
        const AppException(message: 'Erro ao carregar clientes');
    final vm = ClientesViewModel(service);

    await tester.pumpWidget(_buildApp(vm));
    await tester.pump();
    await tester.pump();

    expect(vm.state, ViewState.error);
    expect(find.text('Erro ao carregar clientes'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsOneWidget);
  });

  testWidgets('ClientesView exibe contagem após carregar clientes', (tester) async {
    final service = FakeClienteService();
    service.listagemResultado = PaginatedResult(
      items: [
        const ClienteModel(
          id: 1,
          nome: 'João',
          telefone: '1',
          email: 'j@j.com',
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
    final vm = ClientesViewModel(service);
    await vm.loadClientes();

    await tester.pumpWidget(_buildApp(vm));
    await tester.pumpAndSettle();

    expect(find.text('1 cliente encontrado'), findsOneWidget);
  });

  testWidgets('ClientesView exibe mensagem de lista vazia', (tester) async {
    final service = FakeClienteService();
    service.listagemResultado = PaginatedResult(
      items: const [],
      page: 1,
      limit: 20,
      total: 0,
      hasMore: false,
    );
    final vm = ClientesViewModel(service);
    await vm.loadClientes();

    await tester.pumpWidget(_buildApp(vm));
    await tester.pumpAndSettle();

    expect(find.text('Nenhum cliente cadastrado.'), findsOneWidget);
  });
}
