import 'package:erp_alianca_dev/core/constants/realtime_constants.dart';

/// Notificação push recebida via WebSocket (erp_realtime).
class RealtimeNotificationModel {  const RealtimeNotificationModel({
    required this.type,
    required this.mensagem,
    required this.payload,
  });

  final String type;
  final String mensagem;
  final Map<String, dynamic> payload;

  factory RealtimeNotificationModel.fromPayload(Map<String, dynamic> payload) {
    return RealtimeNotificationModel(
      type: payload['type'] as String? ?? '',
      mensagem: payload['mensagem'] as String? ?? '',
      payload: Map<String, dynamic>.from(payload),
    );
  }

  int? get idUsuarioDestino {
    final raw = payload['id_usuario'];
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  int? get idPedido {
    final raw = payload['id_pedido'];
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  int? get idCliente {
    final raw = payload['id_cliente'];
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  bool get isAniversario => type == RealtimeConstants.eventAniversario;

  bool get isPedidoAbertoLongo => type == RealtimeConstants.eventPedidoAbertoLongo;

  /// Pedido em aberto: só exibe para o usuário que cadastrou o pedido.
  bool isDestinadaAoUsuario(int? idUsuarioLogado) {
    if (isAniversario) return true;
    if (!isPedidoAbertoLongo) return false;

    final destino = idUsuarioDestino;
    if (destino == null || idUsuarioLogado == null) return false;
    return destino == idUsuarioLogado;
  }
}
