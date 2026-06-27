import 'package:dio/dio.dart';
import 'package:erp_alianca_dev/core/security/sensitive_data_sanitizer.dart';

class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const AppException({
    required this.message,
    this.statusCode,
    this.data,
  });

  factory AppException.fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return const AppException(
          message: 'Tempo de conexão esgotado. Tente novamente.',
        );
      case DioExceptionType.receiveTimeout:
        return const AppException(
          message: 'Tempo de resposta esgotado. Tente novamente.',
        );
      case DioExceptionType.sendTimeout:
        return const AppException(
          message: 'Tempo de envio esgotado. Tente novamente.',
        );
      case DioExceptionType.badResponse:
        return AppException(
          message: _handleStatusCode(error.response?.statusCode),
          statusCode: error.response?.statusCode,
          data: SensitiveDataSanitizer.sanitize(error.response?.data),
        );
      case DioExceptionType.cancel:
        return const AppException(
          message: 'Requisição cancelada.',
        );
      case DioExceptionType.connectionError:
        return const AppException(
          message: 'Sem conexão com a internet. Verifique sua rede.',
        );
      default:
        // unknown: ainda tenta usar resposta do servidor se existir (ex.: 500 com body)
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        final String message;
        if (statusCode != null) {
          message = _handleStatusCode(statusCode);
        } else {
          message = _messageFromData(data) ?? 'Ocorreu um erro inesperado. Tente novamente.';
        }
        return AppException(
          message: message,
          statusCode: statusCode,
          data: SensitiveDataSanitizer.sanitize(data),
        );
    }
  }

  static String? _messageFromData(dynamic data) {
    if (data == null) return null;
    if (data is Map && data['message'] != null) return data['message'].toString();
    if (data is String && data.trim().isNotEmpty) return data.trim();
    return null;
  }

  static String _handleStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Requisição inválida.';
      case 401:
        return 'Não autorizado. Faça login novamente.';
      case 403:
        return 'Acesso negado.';
      case 404:
        return 'Recurso não encontrado.';
      case 500:
        return 'Erro interno do servidor.';
      default:
        return 'Ocorreu um erro inesperado. Tente novamente.';
    }
  }

  @override
  String toString() => 'AppException: $message (statusCode: $statusCode)';
}
