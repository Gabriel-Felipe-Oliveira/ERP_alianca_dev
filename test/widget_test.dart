import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/core/theme/empresa_palettes.dart';
import 'package:erp_alianca_dev/features/home/utils/home_welcome_messages.dart';
import 'package:erp_alianca_dev/features/home/view/home_view.dart';
import 'package:erp_alianca_dev/shared/services/auth_service.dart';
import 'package:erp_alianca_dev/shared/services/empresa_service.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'helpers/mock_dio_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AppColors.setCurrent(EmpresaPalettes.getById(kDefaultIdEmpresa));
  });

  testWidgets('HomeView monta e exibe menu de navegação', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<AuthService>.value(
            value: createTestAuthService(EmpresaService()),
            child: const HomeView(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Olá, Teste!'), findsOneWidget);
    expect(find.text(HomeWelcomeMessages.subtitle), findsOneWidget);
    expect(find.text('Cliente'), findsOneWidget);
    expect(find.text('Cadastro'), findsNWidgets(2));
    expect(find.text('Listagem'), findsNWidgets(2));
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Comercial'), findsOneWidget);
  });
}
