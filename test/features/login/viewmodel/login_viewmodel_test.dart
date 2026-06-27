import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:erp_alianca_dev/features/login/viewmodel/login_viewmodel.dart';
import 'package:erp_alianca_dev/shared/models/base_state.dart';
import 'package:erp_alianca_dev/shared/services/auth_service.dart';
import 'package:erp_alianca_dev/shared/services/auth_storage_service.dart';
import 'package:erp_alianca_dev/shared/services/empresa_service.dart';
import 'package:erp_alianca_dev/shared/services/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/mock_auth_dio.dart';
import '../../../helpers/mock_auth_responses.dart';
import '../../../helpers/test_auth_credentials.dart';

Future<AuthService> createLoginTestAuthService({
  required Object? Function(dynamic options) router,
}) async {
  SharedPreferences.setMockInitialValues({});
  final localStorage = LocalStorageService();
  await localStorage.init();
  return AuthService(
    authStorage: AuthStorageService(localStorage),
    empresaService: EmpresaService(),
    localStorageService: localStorage,
    authDio: createRoutedMockDio(router),
  );
}

Future<void> attachForm(LoginViewModel viewModel, WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Form(
        key: viewModel.formKey,
        child: const SizedBox.shrink(),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LoginViewModel', () {
    testWidgets('entrar com credenciais válidas retorna true e limpa senha',
        (tester) async {
      final authService = await createLoginTestAuthService(
        router: (_) => MockAuthResponses.loginSuccess(),
      );
      final viewModel = LoginViewModel(authService);
      addTearDown(viewModel.dispose);

      await attachForm(viewModel, tester);
      viewModel.emailController.text = TestAuthCredentials.email;
      viewModel.senhaController.text = TestAuthCredentials.senha;

      late bool ok;
      await tester.runAsync(() async {
        ok = await viewModel.entrar();
      });
      await tester.pump();

      expect(ok, isTrue);
      expect(viewModel.state, ViewState.success);
      expect(viewModel.senhaController.text, isEmpty);
      expect(authService.isAuthenticated, isTrue);
    });

    testWidgets('entrar com falha define mensagem de erro', (tester) async {
      final authService = await createLoginTestAuthService(
        router: (_) => MockAuthResponses.loginFailure(
          message: 'E-mail ou senha inválidos',
        ),
      );
      final viewModel = LoginViewModel(authService);
      addTearDown(viewModel.dispose);

      await attachForm(viewModel, tester);
      viewModel.emailController.text = 'errado@teste.com';
      viewModel.senhaController.text = 'errada';

      late bool ok;
      await tester.runAsync(() async {
        ok = await viewModel.entrar();
      });
      await tester.pump();

      expect(ok, isFalse);
      expect(viewModel.state, ViewState.error);
      expect(viewModel.errorMessage, 'E-mail ou senha inválidos');
      expect(authService.isAuthenticated, isFalse);
    });
  });
}
