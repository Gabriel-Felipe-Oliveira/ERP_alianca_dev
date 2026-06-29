import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:erp_alianca_dev/core/constants/app_constants.dart';
import 'package:erp_alianca_dev/core/network/dio_client.dart';
import 'package:erp_alianca_dev/shared/services/auth_service.dart';
import 'package:erp_alianca_dev/shared/services/auth_storage_service.dart';
import 'package:erp_alianca_dev/shared/services/empresa_service.dart';
import 'package:erp_alianca_dev/shared/services/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/test_auth_credentials.dart';

/// Contexto compartilhado para testes de integração contra a API real.
class IntegrationTestContext {
  late LocalStorageService localStorage;
  late AuthStorageService authStorage;
  late EmpresaService empresaService;
  late AuthService authService;
  late DioClient dioClient;

  Future<void> setUp() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    HttpOverrides.global = null;
    SharedPreferences.setMockInitialValues({});
    localStorage = LocalStorageService();
    await localStorage.init();
    authStorage = AuthStorageService(localStorage);
    empresaService = EmpresaService();
    final dio = _createLiveDio();
    authService = AuthService(
      authStorage: authStorage,
      empresaService: empresaService,
      localStorageService: localStorage,
      authDio: dio,
    );
    dioClient = DioClient(empresaService, authService, dio: dio);
  }

  Future<void> login() async {
    await authService.login(
      email: TestAuthCredentials.email,
      senha: TestAuthCredentials.senha,
    );
  }

  Future<void> tearDown() async {
    if (authService.isAuthenticated) {
      await authService.logoutLocal();
    }
  }

  static Dio _createLiveDio() {
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
}
