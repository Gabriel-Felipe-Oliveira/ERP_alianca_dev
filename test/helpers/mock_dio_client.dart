import 'package:dio/dio.dart';
import 'package:erp_alianca_dev/core/network/dio_client.dart';
import 'package:erp_alianca_dev/features/login/model/auth_session_model.dart';
import 'package:erp_alianca_dev/features/login/model/usuario_model.dart';
import 'package:erp_alianca_dev/shared/models/empresa_model.dart';
import 'package:erp_alianca_dev/shared/services/auth_service.dart';
import 'package:erp_alianca_dev/shared/services/auth_storage_service.dart';
import 'package:erp_alianca_dev/shared/services/empresa_service.dart';
import 'package:erp_alianca_dev/shared/services/local_storage_service.dart';

/// Dio que responde com [responseData] para qualquer request (testes de Service).
Dio createMockDio(Object? responseData, {int statusCode = 200}) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        handler.resolve(
          Response<Object?>(
            requestOptions: options,
            data: responseData,
            statusCode: statusCode,
          ),
        );
      },
    ),
  );
  return dio;
}

AuthService createTestAuthService(EmpresaService empresaService) {
  final storage = LocalStorageService();
  final authStorage = AuthStorageService(storage);
  final authService = AuthService(
    authStorage: authStorage,
    empresaService: empresaService,
    localStorageService: storage,
  );
  authService.debugSetSession(
    AuthSessionModel(
      accessToken: 'test-token',
      refreshToken: 'test-refresh',
      accessExpiresAt: DateTime.now().add(const Duration(hours: 1)),
      idSession: 1,
      deviceName: 'Flutter Test',
      empresa: EmpresaModel(
        idEmpresa: empresaService.idEmpresa,
        razaoSocial: empresaService.current.razaoSocial,
        nomeFantasia: empresaService.current.nomeFantasia,
        cnpj: '',
        email: '',
        telefone: '',
        cep: '',
        logradouro: '',
        numero: '',
        bairro: '',
        cidade: '',
        estado: '',
        status: 'ativa',
      ),
      usuario: const UsuarioModel(
        idUsuario: 1,
        idEmpresa: 1,
        nome: 'Teste',
        email: 'teste@teste.com',
        telefone: '',
        perfil: 'admin',
        status: 'ativo',
      ),
    ),
  );
  return authService;
}

DioClient createBareTestDioClient() {
  final empresaService = EmpresaService();
  return DioClient(
    empresaService,
    createTestAuthService(empresaService),
    dio: Dio(BaseOptions(baseUrl: 'http://test.local')),
  );
}

DioClient createTestDioClient(Object? responseData, {int statusCode = 200}) {
  final empresaService = EmpresaService();
  return DioClient(
    empresaService,
    createTestAuthService(empresaService),
    dio: createMockDio(responseData, statusCode: statusCode),
  );
}
