import 'package:erp_alianca_dev/features/pedidos/model/pedido_model.dart';

/// Cálculos de totais do pedido (sem lógica de UI ou API).
class PedidoCalculator {
  PedidoCalculator._();

  /// Soma quantidade × preço unitário de cada item.
  static double totalItens(Iterable<PedidoItemModel> itens) {
    return itens.fold<double>(
      0.0,
      (s, i) => s + (i.quantidade * i.precoUnitario),
    );
  }
}
