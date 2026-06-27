import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/pedidos/model/item_pedido_linha.dart';
import 'package:erp_alianca_dev/features/produtos/model/produto_model.dart';

/// Lista de itens, edição inline e total do pedido em criação.
mixin PedidoCriarItensMixin on ChangeNotifier {
  bool get isVmDisposed;

  final List<ItemPedidoLinha> _itens = [];
  List<ItemPedidoLinha> get itens => List.unmodifiable(_itens);

  /// Total do pedido: soma de (quantidade × valor unitário) de cada item.
  double get totalPedido {
    double t = 0;
    for (final item in _itens) {
      t += item.quantidade * item.valorEfetivo;
    }
    return t;
  }

  int? _itemEmEdicaoIndex;
  int? get itemEmEdicaoIndex => _itemEmEdicaoIndex;
  final TextEditingController quantidadeEdicaoController =
      TextEditingController();

  void initItensListeners() {
    quantidadeEdicaoController.addListener(() {
      if (_itemEmEdicaoIndex != null && !isVmDisposed) notifyListeners();
    });
  }

  void disposeItens() {
    quantidadeEdicaoController.dispose();
  }

  void adicionarItem(ProdutoModel produto, int quantidade) {
    if (quantidade < 1) return;
    _itens.add(ItemPedidoLinha(produto: produto, quantidade: quantidade));
    if (!isVmDisposed) notifyListeners();
  }

  /// Adiciona vários itens de uma vez (ex.: ao confirmar o modal de seleção).
  /// Mesmo produto já existente na lista tem a quantidade somada.
  Future<void> adicionarItens(List<ItemPedidoLinha> novos) async {
    for (final item in novos) {
      final id = item.produto.idProduto;
      final idx = id == null
          ? -1
          : _itens.indexWhere((e) => e.produto.idProduto == id);
      if (idx >= 0) {
        final existente = _itens[idx];
        _itens[idx] = ItemPedidoLinha(
          produto: existente.produto,
          quantidade: existente.quantidade + item.quantidade,
          valorDesconto: existente.valorDesconto,
        );
      } else {
        _itens.add(ItemPedidoLinha(
          produto: item.produto,
          quantidade: item.quantidade,
          valorDesconto: item.valorDesconto,
        ));
      }
    }
    if (!isVmDisposed) notifyListeners();
  }

  void removerItem(int index) {
    if (index >= 0 && index < _itens.length) {
      _itens.removeAt(index);
      if (_itemEmEdicaoIndex == index) {
        _itemEmEdicaoIndex = null;
      } else if (_itemEmEdicaoIndex != null && _itemEmEdicaoIndex! > index) {
        _itemEmEdicaoIndex = _itemEmEdicaoIndex! - 1;
      }
      if (!isVmDisposed) notifyListeners();
    }
  }

  void editarItem(int index) {
    if (index < 0 || index >= _itens.length) return;
    _itemEmEdicaoIndex = index;
    quantidadeEdicaoController.text = _itens[index].quantidade.toString();
    if (!isVmDisposed) notifyListeners();
  }

  void cancelarEdicaoItem() {
    _itemEmEdicaoIndex = null;
    if (!isVmDisposed) notifyListeners();
  }

  void confirmarEdicaoItem() {
    if (_itemEmEdicaoIndex == null) return;
    final index = _itemEmEdicaoIndex!;
    if (index >= _itens.length) {
      _itemEmEdicaoIndex = null;
      if (!isVmDisposed) notifyListeners();
      return;
    }
    final qtd = int.tryParse(quantidadeEdicaoController.text.trim()) ?? 0;
    if (qtd < 1) return;
    final item = _itens[index];
    _itens[index] = ItemPedidoLinha(
      produto: item.produto,
      quantidade: qtd,
      valorDesconto: item.valorDesconto,
    );
    _itemEmEdicaoIndex = null;
    if (!isVmDisposed) notifyListeners();
  }

  void atualizarQuantidadeItem(int index, int novaQuantidade) {
    if (index < 0 || index >= _itens.length || novaQuantidade < 1) return;
    final item = _itens[index];
    _itens[index] = ItemPedidoLinha(
      produto: item.produto,
      quantidade: novaQuantidade,
      valorDesconto: item.valorDesconto,
    );
    if (!isVmDisposed) notifyListeners();
  }

  /// Atualiza o valor unitário do item (salvo como valor_desconto ao persistir).
  void atualizarValorItem(int index, double novoValor) {
    if (index < 0 || index >= _itens.length || novoValor < 0) return;
    final item = _itens[index];
    _itens[index] = ItemPedidoLinha(
      produto: item.produto,
      quantidade: item.quantidade,
      valorDesconto: novoValor,
    );
    if (!isVmDisposed) notifyListeners();
  }
}
