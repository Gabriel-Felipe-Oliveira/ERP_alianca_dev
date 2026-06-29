import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/core/errors/app_exception.dart';
import 'package:erp_alianca_dev/core/theme/empresa_palettes.dart';
import 'package:erp_alianca_dev/features/pedidos/model/pedido_model.dart';
import 'package:erp_alianca_dev/features/pedidos/view/pedidos_view.dart';
import 'package:erp_alianca_dev/features/pedidos/viewmodel/pedidos_viewmodel.dart';
import 'package:erp_alianca_dev/shared/models/paginated_result.dart';
import 'package:erp_alianca_dev/shared/services/empresa_service.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';

import '../../../helpers/fake_services.dart';

Widget _buildApp(PedidosViewModel vm) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        height: 600,
        child: ChangeNotifierProvider<PedidosViewModel>.value(
          value: vm,
          child: const PedidosView(),
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

  testWidgets('PedidosView exibe filtros de status', (tester) async {
    final vm = PedidosViewModel(
      FakePedidoService(),
      FakeClienteService(),
      FakeDashboardService(),
    );

    await tester.pumpWidget(_buildApp(vm));
    await tester.pumpAndSettle();

    expect(find.text('Em aberto'), findsOneWidget);
    expect(find.text('Organizado'), findsOneWidget);
    expect(find.text('Concluído'), findsOneWidget);
    expect(find.text('Cancelado'), findsOneWidget);
  });

  testWidgets('PedidosView exibe erro quando listagem falha', (tester) async {
    final pedidoService = FakePedidoService();
    pedidoService.erroAoListar =
        const AppException(message: 'Falha ao carregar pedidos');
    final vm = PedidosViewModel(
      pedidoService,
      FakeClienteService(),
      FakeDashboardService(),
    );
    await vm.loadPedidos();

    await tester.pumpWidget(_buildApp(vm));
    await tester.pumpAndSettle();

    expect(find.text('Falha ao carregar pedidos'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsOneWidget);
  });

  testWidgets('PedidosView exibe contagem após carregar pedidos', (tester) async {
    final pedidoService = FakePedidoService();
    pedidoService.resultado = PaginatedResult(
      items: [
        PedidoListagemModel(
          idPedido: 1,
          idEmpresa: 3,
          idCliente: 10,
          status: 'confirmado',
          total: 99,
        ),
      ],
      page: 1,
      limit: 20,
      total: 1,
      hasMore: false,
    );
    final vm = PedidosViewModel(
      pedidoService,
      FakeClienteService(),
      FakeDashboardService(),
    );
    await vm.loadPedidos();

    await tester.pumpWidget(_buildApp(vm));
    await tester.pumpAndSettle();

    expect(find.text('1 pedido encontrado'), findsOneWidget);
  });

  testWidgets('PedidosView exibe mensagem de lista vazia', (tester) async {
    final pedidoService = FakePedidoService();
    pedidoService.resultado = PaginatedResult(
      items: const [],
      page: 1,
      limit: 20,
      total: 0,
      hasMore: false,
    );
    final vm = PedidosViewModel(
      pedidoService,
      FakeClienteService(),
      FakeDashboardService(),
    );
    await vm.loadPedidos();

    await tester.pumpWidget(_buildApp(vm));
    await tester.pumpAndSettle();

    expect(find.text('Nenhum pedido encontrado.'), findsOneWidget);
  });
}
