import 'package:erp_alianca_dev/core/errors/app_exception.dart';

/// Mensagens de erro ao confirmar pedido (body da API ou genérica).
class PedidoConfirmacaoErro {
  PedidoConfirmacaoErro._();

  static String mensagem(Object e) {
    if (e is AppException) {
      final doBody = _mensagemDoBody(e.data);
      if (doBody != null) return doBody;
      return e.message;
    }
    if (e is Exception) {
      final msg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      if (msg.isNotEmpty && msg != e.toString()) return msg;
    }
    return 'Erro ao confirmar pedido. Tente novamente.';
  }

  static String? _mensagemDoBody(dynamic data) {
    if (data is! Map) return null;
    final error = data['error'];
    if (error is String && error.trim().isNotEmpty) return error.trim();
    final message = data['message'];
    if (message is String && message.trim().isNotEmpty) return message.trim();
    return null;
  }
}
