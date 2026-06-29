import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/core/errors/app_exception.dart';
import 'package:erp_alianca_dev/core/theme/empresa_palettes.dart';
import 'package:erp_alianca_dev/features/romaneio/model/romaneio_model.dart';
import 'package:erp_alianca_dev/features/romaneio/view/romaneio_view.dart';
import 'package:erp_alianca_dev/features/romaneio/viewmodel/romaneio_viewmodel.dart';
import 'package:erp_alianca_dev/shared/models/base_state.dart';
import 'package:erp_alianca_dev/shared/models/paginated_result.dart';
import 'package:erp_alianca_dev/shared/services/empresa_service.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';

import '../../../helpers/fake_services.dart';

Widget _buildApp(RomaneioViewModel vm) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        height: 600,
        child: ChangeNotifierProvider<RomaneioViewModel>.value(
          value: vm,
          child: const RomaneioView(),
        ),
      ),
    ),
  );
}

RomaneioModel _romaneio() {
  return RomaneioModel(
    id: 1,
    numero: 'ROM-00001',
    dataCriacao: DateTime(2026, 1, 1),
    status: RomaneioStatus.rascunho,
    tipoMotorista: TipoMotorista.proprio,
    observacao: '',
    listaPedidos: const [],
    valorTotal: 500,
    quantidadePedidos: 1,
    totalFaturado: 500,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AppColors.setCurrent(EmpresaPalettes.getById(kDefaultIdEmpresa));
  });

  testWidgets('RomaneioView exibe filtros de status', (tester) async {
    final vm = RomaneioViewModel(FakeRomaneioService());

    await tester.pumpWidget(_buildApp(vm));
    await tester.pumpAndSettle();

    expect(find.text('Em aberto'), findsOneWidget);
    expect(find.text('Concluído'), findsOneWidget);
    expect(find.text('Cancelado'), findsOneWidget);
  });

  testWidgets('RomaneioView exibe erro quando listagem falha', (tester) async {
    final service = FakeRomaneioService();
    service.erroAoListar =
        const AppException(message: 'Erro ao carregar romaneios');
    final vm = RomaneioViewModel(service);

    await tester.pumpWidget(_buildApp(vm));
    await tester.pump();
    await tester.pump();

    expect(vm.state, ViewState.error);
    expect(find.text('Erro ao carregar romaneios'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsOneWidget);
  });

  testWidgets('RomaneioView exibe contagem após carregar romaneios', (tester) async {
    final service = FakeRomaneioService();
    service.resultado = PaginatedResult(
      items: [_romaneio()],
      page: 1,
      limit: 20,
      total: 1,
      hasMore: false,
    );
    final vm = RomaneioViewModel(service);
    await vm.loadRomaneios();

    await tester.pumpWidget(_buildApp(vm));
    await tester.pumpAndSettle();

    expect(find.text('1 romaneio encontrado'), findsOneWidget);
  });
}
