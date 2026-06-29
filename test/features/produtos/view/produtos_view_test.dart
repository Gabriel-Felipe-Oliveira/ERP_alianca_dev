import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/core/errors/app_exception.dart';
import 'package:erp_alianca_dev/core/theme/empresa_palettes.dart';
import 'package:erp_alianca_dev/features/produtos/model/produto_model.dart';
import 'package:erp_alianca_dev/features/produtos/view/produtos_view.dart';
import 'package:erp_alianca_dev/features/produtos/viewmodel/produtos_viewmodel.dart';
import 'package:erp_alianca_dev/shared/models/base_state.dart';
import 'package:erp_alianca_dev/shared/models/paginated_result.dart';
import 'package:erp_alianca_dev/shared/services/empresa_service.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';

import '../../../helpers/fake_services.dart';

Widget _buildApp(ProdutosViewModel vm) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        height: 600,
        child: ChangeNotifierProvider<ProdutosViewModel>.value(
          value: vm,
          child: const ProdutosView(),
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

  testWidgets('ProdutosView exibe campo de busca', (tester) async {
    final vm = ProdutosViewModel(FakeProdutoService());

    await tester.pumpWidget(_buildApp(vm));
    await tester.pumpAndSettle();

    expect(find.text('Buscar produtos por nome...'), findsOneWidget);
  });

  testWidgets('ProdutosView exibe erro quando listagem falha', (tester) async {
    final service = FakeProdutoService();
    service.erroAoListar =
        const AppException(message: 'Erro ao carregar produtos');
    final vm = ProdutosViewModel(service);

    await tester.pumpWidget(_buildApp(vm));
    await tester.pump();
    await tester.pump();

    expect(vm.state, ViewState.error);
    expect(find.text('Erro ao carregar produtos'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsOneWidget);
  });

  testWidgets('ProdutosView exibe contagem após carregar produtos', (tester) async {
    final service = FakeProdutoService();
    service.resultado = PaginatedResult(
      items: [
        const ProdutoModel(
          idProduto: 1,
          idEmpresa: 3,
          nome: 'Arroz',
          preco: 12,
          estoqueAtual: 10,
          status: 'ativo',
        ),
      ],
      page: 1,
      limit: 20,
      total: 1,
      hasMore: false,
    );
    final vm = ProdutosViewModel(service);
    await vm.loadProdutos();

    await tester.pumpWidget(_buildApp(vm));
    await tester.pumpAndSettle();

    expect(find.text('1 produto encontrado'), findsOneWidget);
  });

  testWidgets('ProdutosView exibe mensagem de lista vazia', (tester) async {
    final service = FakeProdutoService();
    service.resultado = PaginatedResult(
      items: const [],
      page: 1,
      limit: 20,
      total: 0,
      hasMore: false,
    );
    final vm = ProdutosViewModel(service);
    await vm.loadProdutos();

    await tester.pumpWidget(_buildApp(vm));
    await tester.pumpAndSettle();

    expect(find.text('Nenhum produto cadastrado.'), findsOneWidget);
  });
}
