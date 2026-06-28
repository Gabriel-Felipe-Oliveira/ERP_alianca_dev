/// Eventos WebSocket emitidos pelo serviço erp_realtime (Phoenix Channels).
abstract class RealtimeConstants {
  static const String eventAniversario = 'cliente.aniversario';
  static const String eventPedidoAbertoLongo = 'pedido.aberto_longo';

  static const Set<String> notificationEvents = {
    eventAniversario,
    eventPedidoAbertoLongo,
  };
}
