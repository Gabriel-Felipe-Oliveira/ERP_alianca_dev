import 'package:flutter_test/flutter_test.dart';
import 'package:erp_alianca_dev/features/pedidos/model/pedido_model.dart';
import 'package:erp_alianca_dev/features/pedidos/utils/pedido_calculator.dart';

void main() {
  group('PedidoCalculator.totalItens', () {
    test('soma quantidade x preço unitário', () {
      const itens = [
        PedidoItemModel(
          idItem: 1,
          idPedido: 10,
          idEmpresa: 1,
          idProduto: 5,
          quantidade: 2,
          precoUnitario: 10.0,
          subtotal: 20.0,
        ),
        PedidoItemModel(
          idItem: 2,
          idPedido: 10,
          idEmpresa: 1,
          idProduto: 6,
          quantidade: 3,
          precoUnitario: 5.5,
          subtotal: 16.5,
        ),
      ];

      expect(PedidoCalculator.totalItens(itens), 36.5);
    });

    test('retorna 0 para lista vazia', () {
      expect(PedidoCalculator.totalItens(const []), 0.0);
    });
  });
}
