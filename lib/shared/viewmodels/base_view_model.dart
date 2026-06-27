import 'package:flutter/foundation.dart';
import 'package:erp_alianca_dev/core/errors/app_exception.dart';
import 'package:erp_alianca_dev/core/utils/app_logger.dart';

/// Base para ViewModels com lifecycle seguro após [dispose].
abstract class BaseViewModel extends ChangeNotifier {
  bool _disposed = false;

  bool get isDisposed => _disposed;

  /// Mensagem segura para exibir na UI (prioriza [AppException.message]).
  static String userMessage(Object error, String fallback) {
    if (error is AppException) return error.message;
    return fallback;
  }

  /// Registra falha auxiliar (ex.: paginação) sem expor detalhe ao usuário.
  static void logFailure(Object error, {required String tag}) {
    AppLogger.debug(
      error is AppException ? error.message : error.toString(),
      tag: tag,
    );
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
