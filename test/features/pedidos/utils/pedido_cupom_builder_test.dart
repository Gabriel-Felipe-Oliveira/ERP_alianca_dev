import 'package:flutter_test/flutter_test.dart';
import 'package:erp_alianca_dev/features/pedidos/model/pedido_model.dart';
import 'package:erp_alianca_dev/features/pedidos/utils/pedido_cupom_builder.dart';
import 'package:erp_alianca_dev/shared/services/empresa_service.dart';

void main() {
  group('PedidoCupomBuilder.build', () {
    test('monta cupom com totais e nome do cliente', () {
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
      ];
      const pedido = PedidoListagemModel(
        idPedido: 10,
        idEmpresa: 1,
        idCliente: 3,
        status: 'confirmado',
        total: 20.0,
        pagamento: 'pix',
        createdAt: '2026-06-01 10:00:00',
      );
      final empresaService = EmpresaService();

      final cupom = PedidoCupomBuilder.build(
        idPedido: 10,
        itens: itens,
        nomeCliente: 'joao silva',
        enderecoCliente: 'Rua A, 100',
        idCliente: 3,
        pedido: pedido,
        statusAtual: 'confirmado',
        empresaService: empresaService,
        nomeProduto: (id) => 'Produto $id',
      );

      expect(cupom, isNotNull);
      expect(cupom!.clienteNome, 'Joao Silva');
      expect(cupom.clienteCod, '003');
      expect(cupom.itens.length, 1);
      expect(cupom.total, 20.0);
      expect(cupom.formaPagamento, 'pix');
    });

    test('retorna null quando não há itens', () {
      final cupom = PedidoCupomBuilder.build(
        idPedido: 1,
        itens: const [],
        nomeCliente: 'x',
        enderecoCliente: '',
        idCliente: 1,
        pedido: null,
        statusAtual: 'confirmado',
        empresaService: EmpresaService(),
        nomeProduto: (_) => 'P',
      );
      expect(cupom, isNull);
    });
  });
}
