import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:erp_alianca_dev/core/security/sensitive_data_sanitizer.dart';
import 'package:erp_alianca_dev/core/utils/app_logger.dart';

/// Logger HTTP que nunca imprime tokens, senhas ou headers de autenticação.
class SanitizedDioLogger extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      AppLogger.debug(
        '${options.method} ${options.uri}',
        tag: 'HTTP',
      );
      if (options.queryParameters.isNotEmpty) {
        AppLogger.debug(
          'Query: ${SensitiveDataSanitizer.sanitize(options.queryParameters)}',
          tag: 'HTTP',
        );
      }
      if (options.headers.isNotEmpty) {
        AppLogger.debug(
          'Headers: ${SensitiveDataSanitizer.sanitizeHeaders(options.headers)}',
          tag: 'HTTP',
        );
      }
      if (options.data != null) {
        AppLogger.debug(
          'Body: ${SensitiveDataSanitizer.sanitizeForLog(options.data)}',
          tag: 'HTTP',
        );
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      AppLogger.debug(
        '← ${response.statusCode} ${response.requestOptions.uri}',
        tag: 'HTTP',
      );
      if (response.data != null) {
        AppLogger.debug(
          'Response: ${SensitiveDataSanitizer.sanitizeForLog(response.data)}',
          tag: 'HTTP',
        );
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      AppLogger.error(
        'HTTP ${err.response?.statusCode ?? 'ERR'} ${err.requestOptions.uri}',
        error: SensitiveDataSanitizer.sanitizeForLog(err.response?.data),
      );
    }
    handler.next(err);
  }
}
