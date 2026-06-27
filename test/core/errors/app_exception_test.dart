import 'package:flutter_test/flutter_test.dart';
import 'package:erp_alianca_dev/core/errors/app_exception.dart';
import 'package:dio/dio.dart';

void main() {
  group('AppException', () {
    test('fromDioException sanitiza data com tokens', () {
      final exception = AppException.fromDioException(
        DioException(
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 401,
            data: {
              'message': 'Não autorizado',
              'access_token': 'token-secreto-nao-expor',
            },
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(exception.message, 'Não autorizado. Faça login novamente.');
      final data = exception.data as Map<String, dynamic>;
      expect(data['access_token'], isNot('token-secreto-nao-expor'));
    });
  });
}
