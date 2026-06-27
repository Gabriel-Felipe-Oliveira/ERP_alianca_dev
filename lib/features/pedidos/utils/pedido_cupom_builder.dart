import 'package:erp_alianca_dev/features/pedidos/model/pedido_model.dart';
import 'package:erp_alianca_dev/shared/pdf/cupom_pedido_data.dart';
import 'package:erp_alianca_dev/shared/services/empresa_service.dart';
import 'package:erp_alianca_dev/shared/utils/cliente_formatters.dart';

/// Monta [Pedido] para geração do cupom térmico (sem HTTP).
class PedidoCupomBuilder {
  PedidoCupomBuilder._();

  static Pedido? build({
    required int idPedido,
    required List<PedidoItemModel> itens,
    required String nomeCliente,
    required String enderecoCliente,
    required int idCliente,
    required PedidoListagemModel? pedido,
    required String statusAtual,
    required EmpresaService empresaService,
    required String Function(int idProduto) nomeProduto,
  }) {
    if (itens.isEmpty) return null;
    final total = itens.fold<double>(
      0.0,
      (s, i) => s + (i.quantidade * i.precoUnitario),
    );
    final emp = empresaService.current;
    final dataPedido = pedido?.createdAt != null
        ? DateTime.tryParse(pedido!.createdAt!) ?? DateTime.now()
        : DateTime.now();
    final codSemHash =
        idCliente > 0 ? idCliente.toString().padLeft(3, '0') : '';
    return Pedido(
      id: idPedido.toString(),
      data: dataPedido,
      clienteNome: capitalizeWords(nomeCliente),
      clienteTelefone: null,
      itens: itens
          .map(
            (i) => ItemPedido(
              nome: nomeProduto(i.idProduto),
              quantidade: i.quantidade,
              precoUnitario: i.precoUnitario,
              subtotalLinha: i.subtotal,
            ),
          )
          .toList(),
      subtotal: total,
      desconto: 0,
      total: total,
      formaPagamento: () {
        final p = pedido?.pagamento.trim() ?? '';
        if (p.isNotEmpty) return p;
        if (statusAtual == 'concluido') return 'Concluído';
        return 'A definir';
      }(),
      nomeEmpresa:
          emp.nomeFantasia.isNotEmpty ? emp.nomeFantasia : emp.razaoSocial,
      cnpjEmpresa: emp.cnpj,
      clienteCod: codSemHash,
      enderecoCliente: enderecoCliente,
    );
  }
}
