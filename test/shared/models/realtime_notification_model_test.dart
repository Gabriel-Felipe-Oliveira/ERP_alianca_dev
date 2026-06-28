import 'package:flutter_test/flutter_test.dart';
import 'package:erp_alianca_dev/core/constants/realtime_constants.dart';
import 'package:erp_alianca_dev/shared/models/realtime_notification_model.dart';

void main() {
  group('RealtimeNotificationModel.isDestinadaAoUsuario', () {
    test('aniversário é visível para qualquer usuário logado', () {
      final n = RealtimeNotificationModel.fromPayload({
        'type': RealtimeConstants.eventAniversario,
        'mensagem': 'Parabéns',
        'id_cliente': 1,
      });

      expect(n.isDestinadaAoUsuario(4), isTrue);
      expect(n.isDestinadaAoUsuario(null), isTrue);
    });

    test('pedido em aberto só para o usuário destino', () {
      final n = RealtimeNotificationModel.fromPayload({
        'type': RealtimeConstants.eventPedidoAbertoLongo,
        'mensagem': 'Pedido antigo',
        'id_pedido': 501,
        'id_usuario': 4,
      });

      expect(n.isDestinadaAoUsuario(4), isTrue);
      expect(n.isDestinadaAoUsuario(99), isFalse);
      expect(n.isDestinadaAoUsuario(null), isFalse);
    });

    test('pedido sem id_usuario não exibe para ninguém', () {
      final n = RealtimeNotificationModel.fromPayload({
        'type': RealtimeConstants.eventPedidoAbertoLongo,
        'mensagem': 'Pedido antigo',
        'id_pedido': 501,
      });

      expect(n.isDestinadaAoUsuario(4), isFalse);
    });
  });
}
