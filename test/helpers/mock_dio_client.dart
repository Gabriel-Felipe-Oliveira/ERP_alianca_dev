import 'package:dio/dio.dart';
import 'package:erp_alianca_dev/core/network/dio_client.dart';
import 'package:erp_alianca_dev/shared/services/empresa_service.dart';

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

DioClient createTestDioClient(Object? responseData, {int statusCode = 200}) {
  return DioClient(
    EmpresaService(),
    dio: createMockDio(responseData, statusCode: statusCode),
  );
}
