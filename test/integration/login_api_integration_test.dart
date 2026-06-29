@Tags(['integration'])
library;

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:erp_alianca_dev/core/constants/app_constants.dart';
import 'package:erp_alianca_dev/core/security/sensitive_data_sanitizer.dart';
import 'package:erp_alianca_dev/shared/services/auth_service.dart';
import 'package:erp_alianca_dev/shared/services/auth_storage_service.dart';
import 'package:erp_alianca_dev/shared/services/empresa_service.dart';
import 'package:erp_alianca_dev/shared/services/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_auth_credentials.dart';

Dio _createLiveDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.connectionTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
  final adapter = dio.httpClientAdapter;
  if (adapter is IOHttpClientAdapter) {
    adapter.createHttpClient = () => HttpClient();
  }
  return dio;
}

/// Testes contra a API real. Credenciais: [TestAuthCredentials].
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = null;

  late Dio dio;
  late AuthService authService;
  late AuthStorageService authStorage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final localStorage = LocalStorageService();
    await localStorage.init();
    authStorage = AuthStorageService(localStorage);
    final empresaService = EmpresaService();
    dio = _createLiveDio();
    authService = AuthService(
      authStorage: authStorage,
      empresaService: empresaService,
      localStorageService: localStorage,
      authDio: dio,
    );
  });

  group('Login API (integração)', () {
    test('login com credenciais padrão retorna sessão válida', () async {
      await authService.login(
        email: TestAuthCredentials.email,
        senha: TestAuthCredentials.senha,
      );

      expect(authService.isAuthenticated, isTrue);
      expect(authService.usuario?.email, TestAuthCredentials.email);
      expect(authService.usuario?.perfil, 'admin');
      expect(authService.session?.accessToken, isNotEmpty);
      expect(authService.session?.refreshToken, isNotEmpty);
      expect(authService.session!.idSession, greaterThan(0));
      expect(authService.session!.empresa.idEmpresa, greaterThan(0));

      final persisted = authStorage.loadSession();
      expect(persisted, isNotNull);
      expect(persisted!.usuario.email, TestAuthCredentials.email);
    });

    test('toString da sessão não expõe tokens completos', () async {
      await authService.login(
        email: TestAuthCredentials.email,
        senha: TestAuthCredentials.senha,
      );

      final session = authService.session!;
      final text = session.toString();
      expect(text, isNot(contains(session.accessToken)));
      expect(text, isNot(contains(session.refreshToken)));
      expect(text, contains(SensitiveDataSanitizer.redacted));
    });

    test('refresh renova access token', () async {
      await authService.login(
        email: TestAuthCredentials.email,
        senha: TestAuthCredentials.senha,
      );
      final expiraAntes = authService.session!.accessExpiresAt;

      final ok = await authService.tryRefreshAccessToken();

      expect(ok, isTrue);
      expect(authService.accessToken, isNotEmpty);
      expect(
        authService.session!.accessExpiresAt.isAfter(expiraAntes) ||
            authService.session!.accessExpiresAt.isAtSameMomentAs(expiraAntes),
        isTrue,
      );
    });

    test('dashboard autenticado responde 200', () async {
      await authService.login(
        email: TestAuthCredentials.email,
        senha: TestAuthCredentials.senha,
      );

      final idEmpresa = authService.session!.empresa.idEmpresa;
      final response = await dio.get<Map<String, dynamic>>(
        'api/dashboard.php',
        queryParameters: {'id_empresa': idEmpresa},
        options: Options(
          headers: {'Authorization': 'Bearer ${authService.accessToken}'},
        ),
      );

      expect(response.statusCode, 200);
      expect(response.data?['ok'], isTrue);
      expect(response.data?['id_empresa'], idEmpresa);
    });

    test('logout limpa sessão local e revoga na API', () async {
      await authService.login(
        email: TestAuthCredentials.email,
        senha: TestAuthCredentials.senha,
      );

      await authService.logout();

      expect(authService.session, isNull);
      expect(authStorage.loadSession(), isNull);
    });
  });
}
