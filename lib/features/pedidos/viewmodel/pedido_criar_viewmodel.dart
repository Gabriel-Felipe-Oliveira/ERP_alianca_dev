import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/viewmodels/base_view_model.dart';
import 'package:erp_alianca_dev/features/pedidos/model/forma_pagamento_pedido.dart';
import 'package:erp_alianca_dev/features/pedidos/model/pedido_model.dart';
import 'package:erp_alianca_dev/features/pedidos/contracts/pedido_selecao_produtos_contract.dart';
import 'package:erp_alianca_dev/features/pedidos/viewmodel/mixins/pedido_criar_cliente_mixin.dart';
import 'package:erp_alianca_dev/features/pedidos/viewmodel/mixins/pedido_criar_itens_mixin.dart';
import 'package:erp_alianca_dev/features/pedidos/viewmodel/mixins/pedido_criar_produto_busca_mixin.dart';
import 'package:erp_alianca_dev/shared/services/cliente_service.dart';
import 'package:erp_alianca_dev/shared/services/empresa_service.dart';
import 'package:erp_alianca_dev/shared/services/pedido_service.dart';
import 'package:erp_alianca_dev/shared/services/produto_service.dart';

/// ViewModel do formulário de criação de pedido.
/// Cliente (busca), observação, itens (produto + quantidade). Salvar: criar pedido depois adicionar itens.
class PedidoCriarViewModel extends BaseViewModel
    with
        PedidoCriarClienteMixin,
        PedidoCriarItensMixin,
        PedidoCriarProdutoBuscaMixin
    implements PedidoSelecaoProdutosVm {
  PedidoCriarViewModel(
    this._clienteService,
    this._produtoService,
    this._pedidoService,
    this._empresaService,
  ) {
    initItensListeners();
    initProdutoBuscaListeners();
  }

  final ClienteService _clienteService;
  final ProdutoService _produtoService;
  final PedidoService _pedidoService;
  final EmpresaService _empresaService;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  bool get isVmDisposed => isDisposed;

  @override
  ClienteService get clienteService => _clienteService;

  @override
  ProdutoService get produtoService => _produtoService;

  // ─── Observação ──────────────────────────────────────────────────────

  final TextEditingController observacaoController = TextEditingController();

  // ─── Forma de Pagamento ─────────────────────────────────────────────

  String _formaPagamentoSelecionada = '';
  String get formaPagamentoSelecionada => _formaPagamentoSelecionada;

  set formaPagamentoSelecionada(String value) {
    if (_formaPagamentoSelecionada == value) return;
    _formaPagamentoSelecionada = value;
    if (!isDisposed) notifyListeners();
  }

  bool get _formaPagamentoValida =>
      FormaPagamentoPedido.internoValido(_formaPagamentoSelecionada);

  // ─── Estado geral ─────────────────────────────────────────────────────

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get podeCriar =>
      clienteSelecionado != null &&
      itens.isNotEmpty &&
      clienteSelecionado!.id != null &&
      _formaPagamentoValida;

  /// Lista de itens que faltam para poder criar o pedido.
  List<String> get camposFaltantes {
    final faltantes = <String>[];
    if (clienteSelecionado == null || clienteSelecionado!.id == null) {
      faltantes.add('Cliente');
    }
    if (itens.isEmpty) {
      faltantes.add('Adicione ao menos um produto');
    }
    if (!_formaPagamentoValida) {
      faltantes.add('Forma de Pagamento');
    }
    return faltantes;
  }

  @override
  void dispose() {
    disposeCliente();
    observacaoController.dispose();
    disposeProdutoBusca();
    disposeItens();
    super.dispose();
  }

  /// 1) POST api/pedidos.php → cria pedido como rascunho, retorna id_pedido.
  /// 2) Para cada item: POST api/pedido_itens.php com id_pedido, id_produto, quantidade.
  /// 3) PATCH api/pedidos.php (set_status) para alterar status para confirmado.
  /// Retorna true se sucesso. Em erro seta [errorMessage] e retorna false.
  Future<bool> salvar() async {
    final cliente = clienteSelecionado;
    if (cliente == null ||
        cliente.id == null ||
        itens.isEmpty ||
        !_formaPagamentoValida) {
      _errorMessage =
          'Selecione um cliente, uma forma de pagamento válida e adicione ao menos um produto.';
      if (!isDisposed) notifyListeners();
      return false;
    }

    _errorMessage = null;
    _isLoading = true;
    if (!isDisposed) notifyListeners();

    try {
      final idEmpresa = _empresaService.idEmpresa;

      final payload = PedidoCriarPayload(
        idEmpresa: idEmpresa,
        idCliente: cliente.id!,
        observacao: observacaoController.text.trim(),
        status: 'rascunho',
        pagamento: FormaPagamentoPedido.paraApi(_formaPagamentoSelecionada),
      );
      final idPedido = await _pedidoService.criarPedido(payload);

      final itensParaAdicionar = <PedidoItemPayload>[];
      for (final item in itens) {
        final idProduto = item.produto.idProduto;
        if (idProduto == null) continue;
        itensParaAdicionar.add(PedidoItemPayload(
          idPedido: idPedido,
          idEmpresa: idEmpresa,
          idProduto: idProduto,
          quantidade: item.quantidade,
          valorDesconto: item.valorEfetivo,
        ));
      }

      for (final itemPayload in itensParaAdicionar) {
        await _pedidoService.adicionarItem(itemPayload);
      }

      await _pedidoService.alterarStatusPedido(
        idPedido,
        idEmpresa,
        'confirmado',
      );

      _isLoading = false;
      if (!isDisposed) notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _mensagemErroAmigavel(e);
      if (!isDisposed) notifyListeners();
      return false;
    }
  }

  String _mensagemErroAmigavel(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('timeout') || msg.contains('connection')) {
      return 'Tempo esgotado. Verifique sua conexão.';
    }
    if (msg.contains('500') || msg.contains('servidor')) {
      return 'Erro no servidor. Tente novamente mais tarde.';
    }
    if (msg.contains('message') || e is Exception) {
      final str = e.toString();
      final match = RegExp(r'Exception:\s*(.+)').firstMatch(str);
      if (match != null) return match.group(1)!.trim();
    }
    return 'Erro ao criar pedido. Tente novamente.';
  }
}
