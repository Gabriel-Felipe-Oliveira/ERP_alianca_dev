import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/core/theme/empresa_palettes.dart';
import 'package:erp_alianca_dev/features/home/model/home_model.dart';
import 'package:erp_alianca_dev/features/home/view/home_constants.dart';
import 'package:erp_alianca_dev/features/home/view/home_view.dart';
import 'package:erp_alianca_dev/features/home/viewmodel/home_viewmodel.dart';
import 'helpers/mock_dio_client.dart';
import 'package:erp_alianca_dev/core/network/dio_client.dart';
import 'package:erp_alianca_dev/shared/services/dashboard_service.dart';
import 'package:erp_alianca_dev/shared/services/empresa_service.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';

class FakeDashboardService extends DashboardService {
  FakeDashboardService() : super(DioClient(EmpresaService(), createTestAuthService(EmpresaService())));

  @override
  Future<DashboardResumoModel> buscarResumo() async => const DashboardResumoModel(
        idEmpresa: kDefaultIdEmpresa,
        totalClientes: 2,
        totalProdutos: 3,
        totalPedidosConcluidos: 4,
      );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AppColors.setCurrent(EmpresaPalettes.getById(kDefaultIdEmpresa));
  });

  testWidgets('HomeView monta e exibe título do dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<HomeViewModel>(
            create: (_) => HomeViewModel(FakeDashboardService()),
            child: const HomeView(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(HomeConstants.pageTitle), findsOneWidget);
  });
}
