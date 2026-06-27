import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/pedidos/model/forma_pagamento_pedido.dart';
import 'package:erp_alianca_dev/features/pedidos/model/pedido_model.dart';
import 'package:erp_alianca_dev/shared/services/empresa_service.dart';
import 'package:erp_alianca_dev/shared/services/pedido_service.dart';

/// Edição de itens e pagamento no detalhe do pedido.
mixin PedidoDetalheEdicaoMixin on ChangeNotifier {
  bool get isVmDisposed;
  PedidoService get pedidoService;
  EmpresaService get empresaService;
  int get pedidoId;
  String get statusAtualPedido;
  List<PedidoItemModel> get itensEditaveis;
  PedidoListagemModel? get pedidoAtual;
  set pedidoAtual(PedidoListagemModel? value);
  String get errorMessageEdicao;
  set errorMessageEdicao(String value);
  Future<void> reloadItens();
  void sairModoEdicao();

  bool _isEditMode = false;
  bool get isEditMode => _isEditMode;

  String _formaPagamentoEdicao = '';
  String get formaPagamentoEdicao => _formaPagamentoEdicao;

  set formaPagamentoEdicao(String value) {
    if (_formaPagamentoEdicao == value) return;
    _formaPagamentoEdicao = value;
    if (!isVmDisposed) notifyListeners();
  }

  final Map<int, int> _quantidadeAlterada = {};
  final Map<int, double> _valorAlterado = {};

  int? _itemEmEdicaoIdItem;
  int? get itemEmEdicaoIdItem => _itemEmEdicaoIdItem;
  final TextEditingController quantidadeEdicaoController =
      TextEditingController();

  bool _isSavingEdicao = false;
  bool get isSavingEdicao => _isSavingEdicao;

  void initEdicaoListeners() {
    quantidadeEdicaoController.addListener(() {
      if (_itemEmEdicaoIdItem != null && !isVmDisposed) notifyListeners();
    });
  }

  void disposeEdicao() {
    quantidadeEdicaoController.dispose();
  }

  void enterEditMode() {
    _isEditMode = true;
    _quantidadeAlterada.clear();
    _valorAlterado.clear();
    _formaPagamentoEdicao =
        FormaPagamentoPedido.internoDeApi(pedidoAtual?.pagamento);
    if (!isVmDisposed) notifyListeners();
  }

  void exitEditMode() {
    _isEditMode = false;
    _itemEmEdicaoIdItem = null;
    _quantidadeAlterada.clear();
    _valorAlterado.clear();
    _formaPagamentoEdicao = '';
    sairModoEdicao();
    if (!isVmDisposed) notifyListeners();
  }

  void limparAlteracoesPendentes() {
    _quantidadeAlterada.clear();
    _valorAlterado.clear();
  }

  void editarItem(PedidoItemModel item) {
    _itemEmEdicaoIdItem = item.idItem;
    quantidadeEdicaoController.text = item.quantidade.toString();
    if (!isVmDisposed) notifyListeners();
  }

  void cancelarEdicaoItem() {
    _itemEmEdicaoIdItem = null;
    if (!isVmDisposed) notifyListeners();
  }

  Future<void> confirmarEdicaoItem() async {
    final idItem = _itemEmEdicaoIdItem;
    if (idItem == null) return;
    final qtd = int.tryParse(quantidadeEdicaoController.text.trim()) ?? 0;
    if (qtd < 1) return;
    try {
      await pedidoService.atualizarQuantidadeItem(
        idItem,
        empresaService.idEmpresa,
        qtd,
      );
      _itemEmEdicaoIdItem = null;
      await reloadItens();
    } catch (_) {
      errorMessageEdicao = 'Erro ao atualizar quantidade. Tente novamente.';
      if (!isVmDisposed) notifyListeners();
    }
  }

  void atualizarQuantidadeItemPorIndex(int index, int novaQuantidade) {
    if (index < 0 ||
        index >= itensEditaveis.length ||
        novaQuantidade < 1) {
      return;
    }
    final item = itensEditaveis[index];
    itensEditaveis[index] = PedidoItemModel(
      idItem: item.idItem,
      idPedido: item.idPedido,
      idEmpresa: item.idEmpresa,
      idProduto: item.idProduto,
      quantidade: novaQuantidade,
      precoUnitario: item.precoUnitario,
      subtotal: item.precoUnitario * novaQuantidade,
    );
    _quantidadeAlterada[item.idItem] = novaQuantidade;
    if (!isVmDisposed) notifyListeners();
  }

  void atualizarValorItemPorIndex(int index, double novoValor) {
    if (index < 0 || index >= itensEditaveis.length || novoValor < 0) return;
    final item = itensEditaveis[index];
    itensEditaveis[index] = PedidoItemModel(
      idItem: item.idItem,
      idPedido: item.idPedido,
      idEmpresa: item.idEmpresa,
      idProduto: item.idProduto,
      quantidade: item.quantidade,
      precoUnitario: novoValor,
      subtotal: novoValor * item.quantidade,
    );
    _valorAlterado[item.idItem] = novoValor;
    if (!isVmDisposed) notifyListeners();
  }

  Future<void> confirmarEdicaoPedido() async {
    if (!FormaPagamentoPedido.internoValido(_formaPagamentoEdicao)) {
      errorMessageEdicao = 'Selecione uma forma de pagamento válida.';
      if (!isVmDisposed) notifyListeners();
      return;
    }

    final idsAlterados = <int>{
      ..._quantidadeAlterada.keys,
      ..._valorAlterado.keys,
    };
    final novoPagamentoApi =
        FormaPagamentoPedido.paraApi(_formaPagamentoEdicao);
    final pagamentoMudou = !FormaPagamentoPedido.mesmoPagamentoApi(
      novoPagamentoApi,
      pedidoAtual?.pagamento,
    );

    if (idsAlterados.isEmpty && !pagamentoMudou) {
      exitEditMode();
      await reloadItens();
      return;
    }

    _isSavingEdicao = true;
    errorMessageEdicao = '';
    if (!isVmDisposed) notifyListeners();
    try {
      for (final idItem in idsAlterados) {
        PedidoItemModel? item;
        for (final i in itensEditaveis) {
          if (i.idItem == idItem) {
            item = i;
            break;
          }
        }
        if (item == null) continue;
        await pedidoService.atualizarQuantidadeItem(
          idItem,
          empresaService.idEmpresa,
          item.quantidade,
          valorDesconto: item.precoUnitario,
        );
      }
      if (pagamentoMudou) {
        await pedidoService.atualizarPagamentoPedido(
          pedidoId,
          empresaService.idEmpresa,
          statusAtualPedido,
          novoPagamentoApi,
        );
        final atual = pedidoAtual;
        if (atual != null) {
          pedidoAtual = PedidoListagemModel(
            idPedido: atual.idPedido,
            idEmpresa: atual.idEmpresa,
            idCliente: atual.idCliente,
            status: atual.status,
            total: atual.total,
            volume: atual.volume,
            createdAt: atual.createdAt,
            pagamento: novoPagamentoApi,
          );
        }
      }
      _quantidadeAlterada.clear();
      _valorAlterado.clear();
      exitEditMode();
      await reloadItens();
    } catch (_) {
      errorMessageEdicao = 'Erro ao salvar alterações. Tente novamente.';
      if (!isVmDisposed) notifyListeners();
    } finally {
      _isSavingEdicao = false;
      if (!isVmDisposed) notifyListeners();
    }
  }

  Future<void> removerItem(int idItem) async {
    try {
      await pedidoService.removerItem(idItem, empresaService.idEmpresa);
      itensEditaveis.removeWhere((i) => i.idItem == idItem);
      _quantidadeAlterada.remove(idItem);
      _valorAlterado.remove(idItem);
      if (!isVmDisposed) notifyListeners();
    } catch (_) {
      errorMessageEdicao = 'Erro ao remover item. Tente novamente.';
      if (!isVmDisposed) notifyListeners();
    }
  }
}
