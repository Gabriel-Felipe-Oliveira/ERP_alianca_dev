import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:erp_alianca_dev/core/errors/app_exception.dart';
import 'package:erp_alianca_dev/core/security/sensitive_data_sanitizer.dart';
import 'package:erp_alianca_dev/features/login/model/auth_session_model.dart';
import 'package:erp_alianca_dev/shared/services/auth_service.dart';
import 'package:erp_alianca_dev/shared/services/auth_storage_service.dart';
import 'package:erp_alianca_dev/shared/services/empresa_service.dart';
import 'package:erp_alianca_dev/shared/services/local_storage_service.dart';

import '../../helpers/mock_auth_dio.dart';
import '../../helpers/mock_auth_responses.dart';
import '../../helpers/test_auth_credentials.dart';

Future<({
  AuthService authService,
  AuthStorageService authStorage,
  LocalStorageService localStorage,
  EmpresaService empresaService,
})> createAuthTestHarness({
  Dio? authDio,
}) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  final localStorage = LocalStorageService();
  await localStorage.init();
  final authStorage = AuthStorageService(localStorage);
  final empresaService = EmpresaService();
  final authService = AuthService(
    authStorage: authStorage,
    empresaService: empresaService,
    localStorageService: localStorage,
    authDio: authDio,
  );
  return (
    authService: authService,
    authStorage: authStorage,
    localStorage: localStorage,
    empresaService: empresaService,
  );
}

void main() {
  group('AuthService', () {
    test('login salva sessão e define empresa', () async {
      final harness = await createAuthTestHarness(
        authDio: createRoutedMockDio((options) {
          expect(options.path, 'api/login.php');
          expect(options.data['email'], TestAuthCredentials.email);
          expect(options.data['senha'], TestAuthCredentials.senha);
          expect(options.data['device_name'], isNotEmpty);
          return MockAuthResponses.loginSuccess();
        }),
      );

      await harness.authService.login(
        email: TestAuthCredentials.email,
        senha: TestAuthCredentials.senha,
      );

      expect(harness.authService.isAuthenticated, isTrue);
      expect(
        harness.authService.accessToken,
        MockAuthResponses.accessToken,
      );
      expect(harness.authService.usuario?.email, TestAuthCredentials.email);
      expect(harness.empresaService.idEmpresa, 1);

      final persisted = harness.authStorage.loadSession();
      expect(persisted?.accessToken, MockAuthResponses.accessToken);
      expect(persisted?.idSession, 42);
    });

    test('login com ok:false lança AppException', () async {
      final harness = await createAuthTestHarness(
        authDio: createRoutedMockDio(
          (_) => MockAuthResponses.loginFailure(),
        ),
      );

      expect(
        () => harness.authService.login(
          email: 'errado@teste.com',
          senha: 'x',
        ),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            'Credenciais inválidas',
          ),
        ),
      );
      expect(harness.authService.isAuthenticated, isFalse);
    });

    test('tryRefreshAccessToken renova access token', () async {
      final harness = await createAuthTestHarness(
        authDio: createRoutedMockDio((options) {
          if (options.path == 'api/sessions.php' &&
              options.method == 'POST') {
            expect(options.data['action'], 'refresh');
            expect(
              options.data['refresh_token'],
              MockAuthResponses.refreshToken,
            );
            return MockAuthResponses.refreshSuccess();
          }
          return MockAuthResponses.loginSuccess();
        }),
      );

      await harness.authService.login(
        email: TestAuthCredentials.email,
        senha: TestAuthCredentials.senha,
      );

      final ok = await harness.authService.tryRefreshAccessToken();
      expect(ok, isTrue);
      expect(
        harness.authService.accessToken,
        MockAuthResponses.newAccessToken,
      );
    });

    test('logout revoga sessão na API e limpa local', () async {
      String? logoutToken;
      int? logoutSessionId;

      final harness = await createAuthTestHarness(
        authDio: createRoutedMockDio((options) {
          if (options.path == 'api/login.php') {
            return MockAuthResponses.loginSuccess();
          }
          if (options.path == 'api/sessions.php' &&
              options.method == 'PATCH') {
            logoutToken = options.headers['X-Access-Token'] as String?;
            logoutSessionId = options.data['id_session'] as int?;
            return MockAuthResponses.logoutSuccess();
          }
          return null;
        }),
      );

      await harness.authService.login(
        email: TestAuthCredentials.email,
        senha: TestAuthCredentials.senha,
      );
      await harness.authService.logout();

      expect(logoutToken, MockAuthResponses.accessToken);
      expect(logoutSessionId, 42);
      expect(harness.authService.isAuthenticated, isFalse);
      expect(harness.authStorage.loadSession(), isNull);
    });

    test('logoutLocal limpa sessão sem chamar API', () async {
      final harness = await createAuthTestHarness(
        authDio: createRoutedMockDio(
          (_) => MockAuthResponses.loginSuccess(),
        ),
      );

      await harness.authService.login(
        email: TestAuthCredentials.email,
        senha: TestAuthCredentials.senha,
      );
      await harness.authService.logoutLocal();

      expect(harness.authService.session, isNull);
      expect(harness.authStorage.loadSession(), isNull);
    });

    test('restoreSession carrega sessão persistida', () async {
      final harness = await createAuthTestHarness(
        authDio: createRoutedMockDio(
          (_) => MockAuthResponses.loginSuccess(),
        ),
      );

      await harness.authService.login(
        email: TestAuthCredentials.email,
        senha: TestAuthCredentials.senha,
      );

      final restoredAuth = AuthService(
        authStorage: harness.authStorage,
        empresaService: harness.empresaService,
        localStorageService: harness.localStorage,
      );
      await restoredAuth.restoreSession();

      expect(restoredAuth.isAuthenticated, isTrue);
      expect(
        restoredAuth.accessToken,
        MockAuthResponses.accessToken,
      );
    });
  });

  group('AuthSessionModel', () {
    test('toString não expõe tokens completos', () {
      final session = AuthSessionModel.fromLoginJson(
        MockAuthResponses.loginSuccess(),
        deviceName: 'Flutter Test',
      );

      final text = session.toString();
      expect(text, isNot(contains(MockAuthResponses.accessToken)));
      expect(text, isNot(contains(MockAuthResponses.refreshToken)));
      expect(text, contains(TestAuthCredentials.email));
      expect(text, contains(SensitiveDataSanitizer.redacted));
    });
  });
}
