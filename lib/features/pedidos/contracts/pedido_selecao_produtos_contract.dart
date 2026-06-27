import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/pedidos/model/item_pedido_linha.dart';
import 'package:erp_alianca_dev/features/produtos/model/produto_model.dart';
import 'package:erp_alianca_dev/shared/models/base_state.dart';

/// Contrato para o modal de seleção de produtos (criar pedido e editar pedido).
/// Estende [Listenable] para poder usar [ListenableProvider] e o modal reagir a atualizações.
abstract class PedidoSelecaoProdutosVm implements Listenable {
  TextEditingController get produtoQueryController;
  List<ProdutoModel> get todosProdutos;
  ViewState get stateBuscaProduto;
  void carregarTodosProdutos();
  Future<void> adicionarItens(List<ItemPedidoLinha> itens);
}
